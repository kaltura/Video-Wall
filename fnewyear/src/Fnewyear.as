package {
	import components.DataManager;
	import components.KDPLoader;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;

	[SWF(width="1070", height="700")]

	public class Fnewyear extends Sprite {
		
		[Embed(source="../assets/skin.swf", symbol="pointer_skin")]
		private var Pointer:Class;
		
		private const ROWS:int = 4;
		private const COLS:int = 4;
		private const OFFSET:Number = 10; 

		private var _vidWidth:int = 133;
		private var _vidHeight:int = 100;

		private var _players:Vector.<KDPLoader>;
		private var _numPlayers:int;
		private var _totalPlayers:int;
		private var _target:Sprite;
		private var _activePlayer:KDPLoader; 

		private var _entriesCopy:Vector.<String>;
		private var _entries:Vector.<String>;
		private var _dataManager:DataManager;
		
		

		public function Fnewyear() {
			Security.allowDomain("*");
			
			_vidWidth = (stage.stageWidth - 20) / COLS;
			_vidHeight = (stage.stageHeight - 20) / ROWS;
			
			
			KDPLoader.vidWidth = _vidWidth;
			KDPLoader.vidHeight = _vidHeight;
			_players = new Vector.<KDPLoader>();

			getEntries();
		}
		
		

		protected function getEntries():void {
			var params:Object = loaderInfo.parameters;
			_dataManager = new DataManager(params.partnerid, params.playlistid);
			_dataManager.addEventListener(DataManager.DATA_READY, onEntriesLoaded);
			_dataManager.getEntries();
		}


		protected function onEntriesLoaded(e:Event):void {
			var lst:XMLList = _dataManager.entries;
			_entries = new Vector.<String>();
			var l:int = lst.length();
			for (var i:int = 0; i < l; i++) {
				_entries.push(lst[i].text());
			}
			_totalPlayers = ROWS * COLS;
			addPlayer();
		}


		/**
		 * add video players and place them
		 * @param e
		 */
		protected function addPlayer(e:Event = null):void {
			if (e != null) {
				e.target.removeEventListener("playerLoaded", addPlayer);
			}
			if (_numPlayers >= _totalPlayers) {
				removeEventListener(Event.ENTER_FRAME, addPlayer);
				setMouse();
				return;
			}
			// reset arrays for randomization:
			if (_entries.length == 0) {
				_entries = _entriesCopy;
				_entriesCopy = null;
			}
			var rnd:int = Math.floor(Math.random() * _entries.length);
			// init copy array
			if (_entriesCopy == null) {
				_entriesCopy = new Vector.<String>();
			}
			
			var ldr:KDPLoader = new KDPLoader();
			ldr.addEventListener(KDPLoader.PLAYER_LOADED, addPlayer);
			ldr.init(_entries[rnd]);
			_entriesCopy.push(_entries[rnd]);
			_entries.splice(rnd, 1);
			var row:int = Math.floor(_numPlayers / ROWS);
			var col:int = _numPlayers % ROWS;
			ldr.x = col * _vidWidth + OFFSET;
			ldr.y = row * _vidHeight + OFFSET;
			addChild(ldr);
			_players.push(ldr);
			_numPlayers++;
		}

		protected function setMouse():void {
			_target = new Pointer();
			_target.x = 200;
			_target.y = 200;
			addChild(_target);
			addEventListener(Event.ENTER_FRAME, moveTarget);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		protected function moveTarget(e:Event):void {
			_target.x += (stage.mouseX - _target.x) / 10;
			_target.y += (stage.mouseY - _target.y) / 10;
		}


		protected function onEnterFrame(e:Event):void {
			// see on which video the target is
			var xx:Number = _target.x;
			var yy:Number = _target.y;
			var col:int = Math.floor(xx / _vidWidth);
			var row:int = Math.floor(yy / _vidHeight);
			var ind:int = COLS * row + col;
			// if this video is not playing, activate it
			if (ind >= _players.length) {
				return;
			}
			var player:KDPLoader = _players[ind];
			// remember it so we can turn it off.
			if (player != _activePlayer) {
				if (_activePlayer != null) {
					_activePlayer.stop();
				}
				_activePlayer = player;
				player.play();
			}
		}
	}
}