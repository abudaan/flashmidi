package net.abumarkub.midibridge
{
	import net.abumarkub.core.data.AssetLoaderEvent;
	import net.abumarkub.core.data.DataEvent;
	import net.abumarkub.core.proxy.Proxy;
	import net.abumarkub.core.ui.button.ButtonEvent;
	import net.abumarkub.core.ui.button.LabelButton;
	import net.abumarkub.midi.MidiCommand;
	import net.abumarkub.midi.MidiConfig;
	import net.abumarkub.midi.MidiEvent;
	import net.abumarkub.midi.MidiLearn;
	import net.abumarkub.midi.MidiLearnEvent;
	import net.abumarkub.midi.keyboard.MidiKeyboard;
	import net.abumarkub.midibridge.proxy.InitProxy;
	import net.abumarkub.midibridge.ui.BackgroundColor;
	import net.abumarkub.midibridge.ui.BoxesAnimation;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author abudaan
	 */
	[SWF(backgroundColor="#ffffff", frameRate="100")]
	  
	public class App extends Sprite
	{
		private var _initProxy:InitProxy;
		private var _cache:String 	= Proxy.ALLOW_CACHE;
		private var _keyboard:MidiKeyboard;//virtual keyboard
		private var _midiConfig:MidiConfig;
		private var _btnConfig:LabelButton;
		private var _btnMidiLearn:LabelButton;
		private var _backgroundColor:BackgroundColor;
		private var _boxesAnimation:BoxesAnimation;
		private var _midiLearn:MidiLearn;

		public function App()
		{
			var path:String			= stage.loaderInfo.parameters["path"];
			path 					= path == null ? "../" : path;
			var conf:String			= stage.loaderInfo.parameters["conf"];
			conf 					= conf == null ? "xml/config.xml" : conf;
			var css:String			= stage.loaderInfo.parameters["css"];
			css 					= css == null ? "css/app.css" : css;

			_initProxy				= InitProxy.getInstance(path,_cache);
			_initProxy.addEventListener(AssetLoaderEvent.ALL_TASKS_DONE,handleEvent);
			_initProxy.addEventListener(AssetLoaderEvent.LOAD_PROGRESS,handleEvent);
			_initProxy.init(conf,css);						
		}

		private function handleEvent(event:Event):void
		{
			switch(event.type)
			{
				case AssetLoaderEvent.ALL_TASKS_DONE:
					init();
					break;
			}
		}
		
		public function init():void
		{
			graphics.lineStyle(.1,0xbbbbbb);
			graphics.beginFill(0xeeeeee,1);
			graphics.drawRect(0, 0, 555, 30);
			graphics.endFill();	

			_backgroundColor		= new BackgroundColor(555, 270, 0x000000, _initProxy.css);
			_backgroundColor.y		= 30;
			_backgroundColor.addEventListener(MidiLearnEvent.SHOW_MIDI_LEARN_POPUP,handleDataEvent);

			_midiLearn				= new MidiLearn(_initProxy.css);
			
			_btnConfig 				= new LabelButton("config", "open midi configuration", _initProxy.css, "button",150,20,false,TextFieldAutoSize.NONE,false,false);
			_btnConfig.x 			= 20;
			_btnConfig.y 			= 5;
			_btnConfig.addEventListener(ButtonEvent.DOWN, handleButtonEvent);

			_btnMidiLearn 			= new LabelButton("midilearn", "open midi learn settings", _initProxy.css, "button",150,20,false,TextFieldAutoSize.NONE,false,false);
			_btnMidiLearn.x 		= _btnConfig.x + _btnConfig.width + 20;
			_btnMidiLearn.y 		= 5;
			_btnMidiLearn.addEventListener(ButtonEvent.DOWN, handleButtonEvent);

			_keyboard = new MidiKeyboard(21,108);
			_keyboard.addEventListener(MidiEvent.NOTE_ON, handleKeyboardEvent);
			_keyboard.addEventListener(MidiEvent.NOTE_OFF, handleKeyboardEvent);
			_keyboard.x 			= 19;
			_keyboard.y 			= 300;

			_boxesAnimation 		= new BoxesAnimation(_keyboard.width,250);
			_boxesAnimation.x		= _keyboard.x;
			_boxesAnimation.y 		= _keyboard.y - _boxesAnimation.height;

			_midiConfig 			= MidiConfig.getInstance(_initProxy.configData,_initProxy.css);
			_midiConfig.y			= 30;
			//_midiConfig.addEventListener(MidiEvent.NOTE_ON, handleMidiEvent);
			//_midiConfig.addEventListener(MidiEvent.NOTE_OFF, handleMidiEvent);
			_midiConfig.addEventListener(MidiEvent.ALL_EVENTS, handleMidiEvent);
			_midiConfig.init();


			addChild(_backgroundColor);
			addChild(_midiLearn);
			addChild(_keyboard);
			addChild(_boxesAnimation);
			addChild(_midiConfig);
			addChild(_btnConfig);
			addChild(_btnMidiLearn);
		}

		private function handleButtonEvent(event:ButtonEvent):void
		{
			switch(event.targetId)
			{
				case "config":
					if(_midiConfig.state == MidiConfig.COLLAPSED)
					{
						_backgroundColor.showMidiLearnButtons(false);
						_btnMidiLearn.label = "open midi learn settings";
						_midiConfig.show();
						_btnConfig.label = "close midi configuration";
						return;
					}
					_midiConfig.hide();
					_btnConfig.label = "open midi configuration";
					break;
				
				case "midilearn":
					if(_backgroundColor.state == BackgroundColor.CONFIG_HIDDEN)
					{
						_midiConfig.hide();
						_btnConfig.label = "open midi configuration";
						_backgroundColor.showMidiLearnButtons(true);
						_btnMidiLearn.label = "close midi learn settings";
						return;
					}
					_backgroundColor.showMidiLearnButtons(false);
					_btnMidiLearn.label = "open midi learn settings";
					break;
			}
		}

		private function handleDataEvent(event:DataEvent):void 
		{
			switch(event.type)
			{
				case MidiLearnEvent.SHOW_MIDI_LEARN_POPUP:
					_midiLearn.openPopup(event);
					break;
			}
		}
		
		/*
		 * receives midi events from the midi applet and passes them on to the virtual keyboard and other midi consumers
		 */
		private function handleMidiEvent(event:MidiEvent):void
		{
			_keyboard.handleMidiData(event.mididata);
			_boxesAnimation.update(event.mididata);
			_midiLearn.update(event.mididata);
		}
		
		/*
		 * receives midi events from the virtual keyboard and passes them on to the midi applet
		 */
		private function handleKeyboardEvent(event:MidiEvent):void
		{
			//trace("keyboard:" + event.mididata);
			_midiConfig.sendMidiData(event.mididata);
			_boxesAnimation.update(event.mididata);
			_midiLearn.update(event.mididata);
		}
	}
}
