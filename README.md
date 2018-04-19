# AirStageWebview
AirStageWebview 用法

1,把js加入html中
<script type="text/javascript" src="/i/extra/AirWebViewBridge.js"></script>


2,绑定初始化事件回调 

var aleready=function(){
    alert("domready")
}

var AS_EventType_DomReady="domready";



var EventType_DomReady="document.DOMContentLoaded";
var EventType_PageAllLoad="window.load";


AirWebViewBridge.on(EventType_DomReady,aleready);

3,as里侦听事件

var webview:AirWebViewExtend=new AirWebViewExtend(gamemain.cureentScen.view.stage,0,0,0,0);
				webview.addEventListener(StageWebViewBridge.EventType_CloseWebView,onCloseWebview);
				
//				webview.setSAEChannelUrl(null);
				
				webview.onDomReadyCall=doWebDomReady;
				
				gamemain.cureentScen.addViewChild(webview);
				
				webview.viewPort=new Rectangle(0,0,aiGameStatic.Runtime_ScreenWidth,aiGameStatic.Runtime_ScreenHeight);
				scen_webview=webview;
        
        
        


