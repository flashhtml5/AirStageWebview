package  aiGamer.extra
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.LocationChangeEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	import aiApp.aiAppBase;
	import aiApp.web.StageWebViewBridgeExternal;
	import aiApp.web.WebViewBase64;
	
	import aiGamer.statics.aiGameStatic;
	
	public class AirWebViewBridg extends Bitmap
	{
		
		private static const _zeroPoint : Point = new Point( 0, 0 );
		
		/**
		 *在win下可以设为true使用ie 
		 */		
		public static var UseNative:Boolean;
		
		public static var SENDING_PROTOCOL : String 
		
		private var _viewPort : Rectangle;
		private var _view : StageWebView;
		
		protected var inviewstage:Stage;
		
		private var _autoUpdateProps : Boolean;
		
		private var _visible : Boolean = true;
		
		
//		public static var EventType_DomReady:String="document.DOMContentLoaded";
//		public static var EventType_PageAllLoad:String="window.load";

		public static var AS_EventType_DomReady:String="domready"
		public static var AS_EventType_CloseWebView:String="CloseWebView"
		
		public function AirWebViewBridg(inviewstage:Stage, xpos : uint = 0, ypos : uint = 0, w : uint = 400, h : uint = 400, autoUpdateProps : Boolean = true)
		{
			super();
			
			SENDING_PROTOCOL= aiGameStatic.isIOSDevice ?  "about:":"tuoba:";
			
			
			
			_viewPort = new Rectangle( 0, 0, w, h );
			
			
			
			_view = new StageWebView(UseNative);
			_view.viewPort = _viewPort;
			this.inviewstage=inviewstage
			_view.stage = inviewstage;
			_view.stage = null;
			
			
			
			_view.addEventListener(LocationChangeEvent.LOCATION_CHANGING,onLocationChangeing)
			_view.addEventListener( LocationChangeEvent.LOCATION_CHANGE, onLocationChangeing );
			_view.addEventListener(Event.COMPLETE,onLoadComp)
			x = xpos;
			y = ypos;
			setSize( w, h );
			cacheAsBitmap = true;
			cacheAsBitmapMatrix = transform.concatenatedMatrix;
			addEventListener( Event.ADDED_TO_STAGE, onAdded );
			
			parsedtimestamps=new Object();
			
				_callBacks=new Object();
				
			addCallBack(AirWebViewBridg.AS_EventType_DomReady,onDomReady);
			addCallBack(AirWebViewBridg.AS_EventType_CloseWebView,onCloseWebview);
				
		}
		
		protected function onCloseWebview(...args):void
		{
			// TODO Auto Generated method stub
			this.visible=false;
		}
		
		protected function onDomReady(...args):void{
			
			trace("[INFO]AirWebView onDomReady");
		}
		
		
		private var lastLocation:String;
		
		/**
		 * Controls LOCATION_CHANGING events for catching incomming data.
		 */
		private function onLocationChangeing( e : Event ) : void
		{
			SENDING_PROTOCOL=UseNative ?  "about:":"tuoba:";
			trace("[DEBUG] LocationEvent Type:",(e as LocationChangeEvent).type,(e as LocationChangeEvent).location);
			switch( true )
			{
				case e.type == LocationChangeEvent.LOCATION_CHANGING:
					var currLocation : String = unescape( (e as LocationChangeEvent).location );
					
					
					
					switch( true )
					{
						case currLocation.indexOf( SENDING_PROTOCOL + '[JSCall]' ) != -1:
							e.preventDefault();
							
							lastLocation=currLocation;
							var callData:String=currLocation.split( SENDING_PROTOCOL + '[JSCall]' )[1];
							parseCallData(callData );
//							_bridge.parseCallBack( currLocation.split( SENDING_PROTOCOL + '[SWVData]' )[1] );
							
							break;
						// javascript calls actionscript
						
						// load local pages
						case currLocation.indexOf( 'applink:' ) != -1:
						case currLocation.indexOf( 'doclink:' ) != -1:
							e.preventDefault();
							//							loadLocalURL( currLocation );
							break;
					}
					break;
				default:
					if ( hasEventListener( e.type ) ) dispatchEvent( e );
					break;
			}
		}
		
		private var parsedtimestamps:Object;
		
		private function parseCallData(callData:String):void
		{
			// TODO Auto Generated method stub
			var _serializeObject:Object;
			_serializeObject = JSON.parse( WebViewBase64.decode( callData ).toString() );
			var timestamp:Number=_serializeObject.timestamp;
			var funname:String= _serializeObject['method'];
			
			if(parsedtimestamps.hasOwnProperty(timestamp)==false){
				parsedtimestamps[timestamp]=true;
			}
			else{
				trace("[DEBUG] SKIP OLD timestemp funname:"+funname+" timestamp:"+timestamp)
				return;
			}
			
			
			var _callBackFunction:Function =getCallFun(funname);
			
			if(_callBackFunction==null){
				
				trace("[WARN]        ============== No Such Fun :"+funname+"   ============");
				return;
			}
			else{
				trace("[Debug]StageWebViewBridge Call Fun:"+funname);
			}
			
			if( _serializeObject['arguments'].length!=0 )
			{
				 _callBackFunction.apply(null, _serializeObject.arguments );
			}
			else
			{
				 _callBackFunction();
			}
			
		}		
		
		private function getCallFun(funname:String):Function
		{
			// TODO Auto Generated method stub
			
			return _callBacks[ funname];
		}
		
		private var _callBacks:Object;
		
		public function addCallBack(eventtype:String,eventfun:Function):void{
			
			
			
			_callBacks[eventtype]=eventfun;
			
		}
		
		
		/**
		 * On added to stage, initialize "real" position with
		 * localToGlobal and asign the new viewport
		 */
		private function onAdded( event : Event ) : void
		{
			if ( visible ) _view.stage = inviewstage;
			updatePosition();
			if ( _autoUpdateProps )
			{
				addEventListener( Event.EXIT_FRAME, checkVisibleState );
				addEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
			}
			removeEventListener( Event.ADDED_TO_STAGE, onAdded );
		}
		
		
		/**
		 * Fires when the bitmap is removed from stage
		 * Used to remove the autoVisibleUpdate feature  
		 */
		private function onRemoved( event : Event ) : void
		{
			_view.stage = null;
			removeEventListener( Event.EXIT_FRAME, checkVisibleState );
			removeEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
		}
		
		/**
		 * Recursively getting parents visivility
		 * @param t the displayobject to test
		 */
		private static function isParentVisible( t : DisplayObject ) : Boolean
		{
			if (t.stage == null) return false;
			var p : DisplayObjectContainer = t.parent;
			while (!(p is Stage))
			{
				if (!p.visible)
					return false;
				p = p.parent;
			}
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get x() : Number
		{
			return super.x;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set x( ax : Number ) : void
		{
			super.x = ax;
			_viewPort.x = localToGlobal( _zeroPoint ).x;
			viewPort = _viewPort;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get y() : Number
		{
			return super.y;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set y( ay : Number ) : void
		{
			super.y = ay;
			_viewPort.y = localToGlobal( _zeroPoint ).y;
			viewPort = _viewPort;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get visible() : Boolean
		{
			
			return _visible;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set visible( mode : Boolean ) : void
		{
			_visible = mode;
			if( _visible )
			{
			
					super.visible = false;
					_view.stage =  inviewstage;
				
			}
			else
			{
				super.visible = false;
				_view.stage = null;
			}
			
		}
		
		/* PROXING SOME PROPIERTIES */
		/**
		 * proxy from flash.media.StageWebView
		 */
		public function set viewPort( rectangle : Rectangle ) : void
		{
			_view.viewPort = rectangle;
		}
		
		/**
		 * proxy from flash.media.StageWebView
		 */
		public function get viewPort() : Rectangle
		{
			return _view.viewPort;
		}
		
		/**
		 * Check the visibility of the bitmap bassed on his parents visibility
		 */
		private function checkVisibleState( event : Event ) : void
		{
			if( isParentVisible( this ) )
			{
				if( _visible )
				{
					
						super.visible = false;
						_view.stage = inviewstage;
				}
				else
				{
					super.visible = false;
					_view.stage = null;
				}
			}
			else
			{
				_view.stage = null;
			}
			
			//updatePosition();	
		}
		
		/**
		 * Updates position acording to its parent
		 */
		private function updatePosition() : void
		{
			return;
//			_translatedPoint = localToGlobal( _zeroPoint );
//			_viewPort.x = _translatedPoint.x;
//			_viewPort.y = _translatedPoint.y;
//			viewPort = _viewPort;
		}
		
		/**
		 * Sets the size of the StageWebView Instance
		 * @param w The width in pixels of StageWebView
		 * @param h The heigth in pixels of StageWebView
		 */
		public function setSize( w : uint, h : uint ) : void
		{
			_viewPort.width = w;
			_viewPort.height = h;
			viewPort = _viewPort;
		}
		
		
		protected function onLoadComp(event:Event):void
		{
			// TODO Auto-generated method stub
			var webview:StageWebView=(event.currentTarget as StageWebView);
			
			trace("[DEBUG] -StaggeWebView- onLoadComp title:"+webview.title,"url:"+webview.location)
		}
		
		/**
		 * @param url The url to load
		 */
		public function loadURL( url : String ) : void
		{
			_view.loadURL( url );
			if(url.indexOf("javascript:")==-1){
				trace("LoadUrl:",url)
			}
		}
		
		public function loadHtml(htmlcode:String):void{
			
			_view.loadString(htmlcode);
			
		}
		
		/**
		 * Makes a call to a javascript function
		 * @param functionName Name of the function to call
		 * @param callback The callback function to execute when javascript call is processed
		 * @param arguments Coma separated arguments to pass to Javascript function
		 */
		public function call( functionName : String, arguments:Array) : void
		{
			var _serializeObject:Object;
			_serializeObject = {};  
			_serializeObject['method'] = functionName;
			_serializeObject['arguments'] = arguments;
			//			if( callback!=null )
			//			{
			//				addCallback('[SWVMethod]'+functionName, callback );
			//				_serializeObject['callBack'] = '[SWVMethod]'+functionName;
			//			}	
			_view.loadURL("javascript:AirWebViewBridge.doCall('"+WebViewBase64.encodeString( JSON.stringify( _serializeObject ) ) +"')");
		}
		
	}
}