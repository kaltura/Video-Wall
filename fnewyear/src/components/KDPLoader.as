package components
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	[Event(name="playerLoaded", type="flash.events.Event")]
	
	public class KDPLoader extends Sprite
	{
		
		public static const PLAYER_LOADED:String = "playerLoaded";
		
		public static var vidWidth:int = 133;
		public static var vidHeight:int = 100;
		
//		private const SRC:String = "assets/kdp3.swf";
		private const SRC:String = "http://www.kaltura.com/index.php/kwidget/cache_st/1283363043/wid/_346151/uiconf_id/2027241/entry_id/1_b3a3n5mx/nowrapper/1";
		
		private var _entryId:String = "1_0ew8yy0l";
		private var _loader:Loader;
		private var _isPlaying:Boolean;
		
		
		public function KDPLoader()	{
			
		}
		
		public function init(entryId:String = null):void {
			if (entryId != null) _entryId = entryId;
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, initPlayer);
			_loader.load(new URLRequest(SRC));
			addChild(_loader);
			this.mouseChildren = false;
		}
		
		public function play():void {
			if (!_isPlaying) {
				_loader.content["sendNotification"]("doPlay");
				_isPlaying = true;
			}
		}
		
		public function stop():void {
			if (_isPlaying) {
				_loader.content["sendNotification"]("doPause");
				_isPlaying = false;
			}
		}
		protected function initPlayer(e:Event):void {
			// create the flashvars object
			var params:Object = {
				sourceType:"entryId",
				host:"www.kaltura.com",
				autoPlay:true,
				cdnHost:"cdnbakmi.kaltura.com",
				entryId:_entryId,
				debugMode:false,
				autoPlay:true,
				fileSystemMode:false,
				uiConfId:"2027241",
				widgetId:"_346151",
				partnerId:"346151",
				subpId:"34615100",
//				pluginDomain:"assets/plugins/",
//				kml:"local",
				streamerType:"http",
				disableAlerts:false,
				externalInterfaceDisabled:true
			}
			_loader.content.width = vidWidth;
			_loader.content.height = vidHeight;
			// initialize the player.
			_loader.content.addEventListener("layoutReady", hideController);
			_loader.content["flashvars"] = params;
			_loader.content["init"]();
			var delayer:Timer = new Timer(1000, 1);
			delayer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete, false, 0, true);
			delayer.start();
			
		}
		
		protected function hideController(e:Event):void
		{
			// hide controls
			hideHelper(_loader.content as DisplayObjectContainer);
		}

		protected function hideHelper(clip:DisplayObjectContainer):void {
			var sub:DisplayObject;
			for (var i:int = clip.numChildren - 1; i>=0; i--) {
				sub = clip.getChildAt(i);
				if (sub.name == "controllersVbox") {
					sub.visible = false;
					return;
				}
				else if (sub is DisplayObjectContainer) {
					hideHelper(sub as DisplayObjectContainer);
				}
			}
		}
		
		private function onTimerComplete(event:TimerEvent):void {
			event.target.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete, false);
			dispatchEvent(new Event(KDPLoader.PLAYER_LOADED));
		}
	}
}