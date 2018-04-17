package aiGamer.extra
{
	import flash.display.Stage;
	
	import aiApp.web.StageWebViewBridge;
	import aiApp.web.WebViewBase64;
	
	import aiService.SaeChannelProxy;
	
	public class AirWebViewExtend extends AirWebViewBridg
	{
		 
		private var channel:SaeChannelProxy;
		
		public function AirWebViewExtend(inviewstage:Stage, xpos:uint=0, ypos:uint=0, w:uint=400, h:uint=400, autoUpdateProps:Boolean=true)
		{
			super(inviewstage, xpos, ypos, w, h, autoUpdateProps);
			
			
			
		}
		
		override protected function onCloseWebview(...args):void
		{
			// TODO Auto Generated method stub
			super.onCloseWebview(args);
			
			if(onCloseView){
				onCloseView()
			}
			
		}
		
		
		/*private var as3CallfunObj:Object;
		public function addAs3Call(callname:String,callfun:Function):void{
			
			if(as3CallfunObj==null){
				as3CallfunObj=new Object();
			}
			
			as3CallfunObj[callname]=callfun;
		}*/
		
		/*public function onAs3Call(callfunname:String,funarg:Object):void{
			
			if(as3CallfunObj.hasOwnProperty(callfunname)){
				var callfun:Function=as3CallfunObj[callfunname];
				if(funarg==null){
					callfun()
				}
				else{
					
					callfun(funarg);
				}
			}
			else{
				trace("[Warning] no funname:"+callfunname)
			}
		}*/
		
	
		
		override protected function onDomReady(...args):void
		{
			super.onDomReady.apply(null,args)
			// TODO Auto Generated method stub
//			if(beDomReady)return;
//			
//			super.onDomReady(obj);
//			
			if(onDomReadyCall){
				trace("[INFO]onDomReady");
				onDomReadyCall();
			}
//			
////			jsAlert("hi i am flash")
//			if(channel.url==null)return;
//			channel.doDocumentReady();
		}
		
		public var onDomReadyCall:Function;
		public var onCloseView:Function
		
	
		
		
		
	}
}