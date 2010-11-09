package net.abumarkub.app_midibridge
{
	import net.abumarkub.app_midibridge.proxy.InitProxy;
	import net.abumarkub.app_midibridge.ui.BackgroundColor;
	import net.abumarkub.app_midibridge.ui.BoxesAnimation;
	import net.abumarkub.core.data.AssetLoaderEvent;
	import net.abumarkub.core.data.DataEvent;
	import net.abumarkub.core.proxy.Proxy;
	import net.abumarkub.core.ui.button.ButtonEvent;
	import net.abumarkub.core.ui.button.LabelButton;
	import net.abumarkub.midi.MidiEvent;
	import net.abumarkub.midi.keyboard.MidiKeyboard;
	import net.abumarkub.midi.learn.MidiLearn;
	import net.abumarkub.midi.learn.MidiLearnEvent;
	import net.abumarkub.midi.system.IMidiSystem;
	import net.abumarkub.midi.system.MidiConfigUI;
	import net.abumarkub.midi.system.MidiSystem;
	import net.abumarkub.midi.system.air.MidiSystemAir;
	import net.abumarkub.synth.Fluidsynth;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author abudaan
	 * 
	 * The MidiSystem class is available in two types:
	 * 	
	 * 	- net.abumarkub.midi.system.web.MidiSystemWeb for apps that run on the web in combination with the applet version of the midibridge
	 * 	- net.abumarkub.midi.system.air.MidiSystemAir for AIR2.0+ apps that run in combination with the stand alone or service version of the midibridge
	 * 
	 * @see MidiSystemWeb
	 * @see MidiSystemAir 
	 * 
	 * You have to choose either of the types dependent on the type of app you're working on because the class MidiSystem itself should not be instantiated. 
	 * If i use the classname MidiSystem in the text below, you should read here the class name of the midi system type that you have to use in your app.
	 *
	 * 
	 * To make your app midi enabled:
	 * 
	 * - add an instance of MidiSystem to the stage
	 * - add listeners for midi events that are dispatched by the MidiSystem and that your app is interested in
	 *
	 * @see MidiEvent
	 * @see MidiCommand
	 * 
	 * 
	 * The MidiSystem class handles all communication from and to the midi system of your computer (hardware midi system).
	 * In general it should not be necessary to change anything in the MidiSystem class.
	 * 
	 * The MidiConfigUI class is the UI for the MidiConfig class and let users set or change the midi in and midi out ports,
	 * or rescan your midi system for new midi devices. 
	 * 
	 * You can easily change the look and feel of the class MidiConfigUI. Additionally, you can write your own UI class and pass an instance 
	 * of that class to the constructor of MidiConfig. Your custom class *must* implement IMidiConfigUI!
	 * 
	 * @see MidiConfigUI
	 * @see MidiConfig
	 * 
	 * 
	 * It is possible to add your own internal synthesizers to the MidiSystem. In this example i have added an instance of Fluidsynth, which is
	 * an AS3 port by Yoann Huiban of the original C++ version, see:
	 * 
	 * http://code.google.com/p/flash-midi-player/
	 * http://sourceforge.net/apps/trac/fluidsynth/
	 * 
	 * Fluidsynth is Soundfont 2.0 sampleplayer and you can choose your own sounds in Soundfont format. You can also write your own synths and add them to
	 * the MidiSystem. Your synths must implement ISytnh.
	 * 
	 * @see Fluidsynth
	 * @see ISynth 
	 * 
	 * 
	 * In this example i have also added an instance of MidiKeyboard; this is a virtual keyboard that generates midi events in actionscript.
	 * In actionscript midi events are instances of MidiEvent. Each MidiEvent instance contains an instance of MidiData where the actual 
	 * midi data is stored (command, status, channel, data1, data2).
	 * 
	 * The MidiSystem class has a method sendMidiData() that allows you to send actionscript midi events to the midi system of your computer; 
	 * this way your app behaves like a software midi inport to your computer's midi system (hardware midi system).
	 * 
	 * @see MidiKeyboard
	 * @see MidiData
	 * 
	 * 
	 */
	[SWF(backgroundColor="#ffffff", frameRate="100")]
	  
	public class AppAir extends Sprite
	{
		private var _initProxy:InitProxy;
		private var _cache:String 	= Proxy.ALLOW_CACHE;

		private var _keyboard:MidiKeyboard;//virtual keyboard
		private var _midiSystem:IMidiSystem;
		private var _midiConfigUI:MidiConfigUI;

		private var _btnConfig:LabelButton;
		private var _btnMidiLearn:LabelButton;
		private var _backgroundColor:BackgroundColor;
		private var _boxesAnimation:BoxesAnimation;
		private var _midiLearn:MidiLearn;

		public function AppAir()
		{
			_initProxy				= InitProxy.getInstance("",_cache);
			_initProxy.addEventListener(AssetLoaderEvent.ALL_TASKS_DONE,handleProxyEvent);
			_initProxy.addEventListener(AssetLoaderEvent.LOAD_PROGRESS,handleProxyEvent);
			_initProxy.init("config.xml","app.css");						
		}

		private function handleProxyEvent(event:Event):void
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
			

			_midiConfigUI			= new MidiConfigUI(_initProxy.css);
			_midiConfigUI.y			= 30;
						
			_midiSystem 			= MidiSystemAir.getInstance(_midiConfigUI);
			_midiSystem.addSynth(new Fluidsynth(_initProxy.configData.samples));

			_midiSystem.addEventListener(MidiEvent.NOTE_ON, handleMidiData);
			_midiSystem.addEventListener(MidiEvent.NOTE_OFF, handleMidiData);
			_midiSystem.addEventListener(MidiEvent.PITCH_BEND, handleMidiData);
			_midiSystem.addEventListener(MidiEvent.POLY_PRESSURE, handleMidiData);
			_midiSystem.addEventListener(MidiEvent.CONTROL_CHANGE, handleMidiData);
			_midiSystem.init();


			addChild(_backgroundColor);
			addChild(_midiLearn);
			addChild(_keyboard);
			addChild(_boxesAnimation);
			addChild(_midiConfigUI);
			addChild(_btnConfig);
			addChild(_btnMidiLearn);
		}

		private function handleButtonEvent(event:ButtonEvent):void
		{
			switch(event.targetId)
			{
				case "config":
					if(_midiSystem.state == MidiSystem.CONFIG_HIDDEN)
					{
						_backgroundColor.showMidiLearnButtons(false);
						_btnMidiLearn.label = "open midi learn settings";
						_midiSystem.showConfig();
						_btnConfig.label = "close midi configuration";
						return;
					}
					_midiSystem.hideConfig();
					_btnConfig.label = "open midi configuration";
					break;
				
				case "midilearn":
					if(_backgroundColor.state == BackgroundColor.CONFIG_HIDDEN)
					{
						_midiSystem.hideConfig();
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
		 * receives midi events from the midi service and passes them on to the virtual keyboard
		 */
		private function handleMidiData(event:MidiEvent):void
		{
			_keyboard.handleMidiData(event.mididata);
			_boxesAnimation.update(event.mididata);
			_midiLearn.update(event.mididata);
		}
		
		/*
		 * receives midi events from the virtual keyboard and passes them on to the midiservice
		 */
		private function handleKeyboardEvent(event:MidiEvent):void
		{
//			trace("keyboard:" + event.mididata);
			_midiSystem.sendMidiData(event.mididata);
			_boxesAnimation.update(event.mididata);
			_midiLearn.update(event.mididata);
		}
	}
}
