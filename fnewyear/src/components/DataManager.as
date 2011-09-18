package components
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	[Event(name="dataReady",type="flash.events.Event")]
	public class DataManager extends EventDispatcher
	{
		
		public static const DATA_READY:String = "dataReady";
		
		private const sessionservice:String = "http://www.kaltura.com/api_v3/?service=session&action=startwidgetsession";
		private const playlistservice:String = "http://www.kaltura.com/api_v3/index.php?service=playlist&action=execute";
		
		private var _getWidgetSession:URLLoader;
		private var _executePlaylist:URLLoader;
		
		private var _entries:XMLList;
		private var _ks:String;
		
		private var _pid:String;
		private var _plid:String;
		
		public function DataManager(partnerID:String, playlistId:String) {
			_pid = partnerID;
			_plid = playlistId;
		}
		
		public function getEntries():void {
			var rq:URLRequest = new URLRequest(sessionservice);
			var variables:URLVariables = new URLVariables();
			variables.widgetId = "_" + _pid;
			rq.data = variables;
			rq.method = URLRequestMethod.POST;
			_getWidgetSession = new URLLoader();
			_getWidgetSession.addEventListener(Event.COMPLETE, getPlaylist);
			_getWidgetSession.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fault);
			_getWidgetSession.addEventListener(IOErrorEvent.IO_ERROR, fault);
			_getWidgetSession.load(rq);
		}
		
		private function getPlaylist(e:Event):void {
			clearSessionListeners();
			var xml:XML = new XML(e.target.data);
			_ks = xml.result.ks.text();
			var rq:URLRequest = new URLRequest(playlistservice);
			var variables:URLVariables = new URLVariables();
			variables.ks = _ks;
			variables.id = _plid;//"1_8gzaz0iy";
			rq.data = variables;
			rq.method = URLRequestMethod.POST;
			_executePlaylist = new URLLoader();
			_executePlaylist.addEventListener(Event.COMPLETE, onPlaylistLoaded);
			_executePlaylist.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fault);
			_executePlaylist.addEventListener(IOErrorEvent.IO_ERROR, fault);
			_executePlaylist.load(rq);
		}
		
		
		private function onPlaylistLoaded(e:Event):void {
			clearPlaylistListeners();
			var data:XML = new XML(e.target.data);
			if (data.result.error.length() > 0) {
				fault();
			}
			else {
				_entries = data.result.item.id;
				dispatchEvent(new Event(DataManager.DATA_READY));
			}
		}
		
		
		private function clearPlaylistListeners():void {
			_executePlaylist.removeEventListener(Event.COMPLETE, onPlaylistLoaded);
			_executePlaylist.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, fault);
			_executePlaylist.removeEventListener(IOErrorEvent.IO_ERROR, fault);
		}
		
		private function clearSessionListeners():void {
			_getWidgetSession.removeEventListener(Event.COMPLETE, getPlaylist);
			_getWidgetSession.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, fault);
			_getWidgetSession.removeEventListener(IOErrorEvent.IO_ERROR, fault);
		}
		
		private function fault(e:Event = null):void {
			trace("error");
		}

		public function get entries():XMLList {
			return _entries;
		}

		
	}
}