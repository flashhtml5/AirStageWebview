(function(window)
{
	window.AirWebViewBridge = (function()
	{

        var checker =
            {
                deskwin:navigator.userAgent.match(/(Windows)/) === null ? false:true,
                airsim:navigator.userAgent.match(/(MSIE)/) === null ? false:true,
                iphone: navigator.userAgent.match(/(iPhone|iPod|iPad)/) === null ? false:true,
                chrome: navigator.userAgent.match(/(Chrome)/) === null ? false:true,
                android: navigator.userAgent.match(/Android/) === null ? false: navigator.platform.match(/Linux/) == null ? false:true

            };

        /* Used to determine the "protocol" to do the comm with AS3 */
        var getProtocol=function(){
            var out="tuoba:";
            if(checker.airsim){
                out="about:"
            }
            else if(checker.iphone){
                out="about:"
            }
            else if(checker.deskwin){
                out="tuoba:"
            }
            if(checker.android){
                out="about:"
            }
            return out;
        }


		/* Return public methods */
        var fundict={};
        var sendingProtocol = getProtocol();

		var on=function(eventtype,eventHandle){
            eventtype=eventtype.toLowerCase();
		    fundict[eventtype]=eventHandle;
		    // alert("eventtype"+eventtype+fundict[eventtype])
        };

        var triggle=function(eventtype){
            eventtype=eventtype.toLowerCase();
		    var eventfun=fundict[eventtype];

		    if(eventfun!=null){
		        eventfun();
            }
            else{
		        jslog("[INFO]triggle skip undef fun:"+eventtype);
            }
        };

        var doCall = function( jsonArgs )
        {
            // alert(jsonArgs)
            setTimeout(function() { deferredDoCall(jsonArgs); },0 );
        };


        /* Used internally to parse call funcions from AS3 */
        var deferredDoCall = function( jsonArgs )
        {
            var jsonstr= atob( jsonArgs );
            jsonstr=unescape(jsonstr);
            // alert(jsonstr);
            var _serializeObject = JSON.parse(jsonstr );
            var method = _serializeObject.method;

            targetFunction = window[ method ];
            if(_serializeObject.arguments==null){
                targetFunction()
            }
            else{

                targetFunction.apply(null, _serializeObject.arguments );
            }

            return;
            // var returnValue = true;
            if( method.indexOf('[]')==-1 )
            {
                var targetFunction;
                if( method.indexOf('.')==-1)
                {
                    targetFunction = window[ method ];
                }
                else
                {
                    var splitedPath = method.split('.');
                    targetFunction=window;
                    for( var i=0; i<splitedPath.length; i++ )
                    {
                        targetFunction = targetFunction[ splitedPath[ i ] ];
                    };
                };
                returnValue = targetFunction.apply(null, _serializeObject.arguments );
            }
            else
            {
                var targetFunction = callBacks[ method ];
                returnValue = targetFunction.apply(null, _serializeObject.arguments );
            };


        };





        var mindelay=100;
        var lastcalltime=0;
        var call=function(calleventy,callargsay){
            var nowtime=new Date().getTime();
            var calldiff=nowtime-lastcalltime;
            // var calldelay=calldiff>mindelay?mindelay:
            var calldelay=mindelay;

            var argumentsArray = [];
            var _serializeObject = {};
            _serializeObject.method = arguments[ 0 ];
            _serializeObject.arguments=arguments[1];
            _serializeObject.timestamp=nowtime;
            var jsonstr=JSON.stringify( _serializeObject );
            var locstr=window.location.href=sendingProtocol+'[JSCall]'+btoa( jsonstr );

            var changfun=function(){
                jslog("[INFO]Call command:"+locstr)
                window.location.assign(locstr)
            };
            setTimeout(changfun,calldelay)
            lastcalltime=nowtime;
        }

        var loadComplete = function()
        {
            window.removeEventListener('load', loadComplete, false );
            // call('___getFilePaths', onGetFilePaths );
            // jslog("loadComplete")
            triggle("window.load")
        };
        var callDOMContentLoaded = function()
        {
            document.removeEventListener('DOMContentLoaded', callDOMContentLoaded, false );
            // call('___getFilePaths', onGetFilePaths );
            // jslog("callDOMContentLoaded")
            triggle("document.DOMContentLoaded")
        };

        // alert(window)
        /* Listen for page load complete */
        window.addEventListener( 'load', loadComplete, false );

        /* Listen for DOMContentLoaded */
        document.addEventListener('DOMContentLoaded', callDOMContentLoaded, false );


		return {
		    on:on,
            call:call,
            doCall:doCall,


		};
	})();
})(window);


function jslog(str) {
    // alert(str);
    // alert(typeof("console"));
    if (window.console){
        console.log(str)
    }
    else{

        // StageWebViewBridge.as3trace("(JSconsole)"+str)
    }
}

		