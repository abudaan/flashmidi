package net.abumarkub.app_midibridge
{
	import fl.controls.Button;

	import net.abumarkub.midi.MidiEvent;
	import net.abumarkub.midi.keyboard.MidiKeyboard;
	import net.abumarkub.midi.system.IMidiSystem;
	import net.abumarkub.midi.system.MidiConfigUI;
	import net.abumarkub.midi.system.MidiSystem;
	import net.abumarkub.midi.system.web.MidiSystemWeb;
//	import net.abumarkub.synth.Fluidsynth;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

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
	 *  NOTE: FluidSynth does *not* work in CS4 !!!
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
	 
	public class SimpleSampleAppWebCS4 extends Sprite
	{
		private var _midiConfigBtn:Button;
		private var _midiConfigUI:MidiConfigUI;
		private var _midiSystem:IMidiSystem;
		private var _midiKeyboard:MidiKeyboard;
		
		public function SimpleSampleAppWebCS4()
		{
			_midiConfigBtn 			= new Button();
			_midiConfigBtn.label 	= "open midi config";
			_midiConfigBtn.y		= 4;
			_midiConfigBtn.addEventListener(MouseEvent.CLICK, handleEvent);
			addChild(_midiConfigBtn);
			
			_midiConfigUI			= new MidiConfigUI();
			_midiConfigUI.y			= 30;
			addChild(_midiConfigUI);
						
			_midiSystem 			= MidiSystemWeb.getInstance(_midiConfigUI);
			//FluidSynth does *not* work in CS4 !!!
			//_midiSystem.addSynth(new Fluidsynth("sound/LK_Piano.sf2"));

			_midiSystem.addEventListener(MidiEvent.NOTE_ON, handleMidiData);
			_midiSystem.addEventListener(MidiEvent.NOTE_OFF, handleMidiData);
			_midiSystem.addEventListener(MidiEvent.PITCH_BEND, handleMidiData);
			_midiSystem.addEventListener(MidiEvent.POLY_PRESSURE, handleMidiData);
			_midiSystem.addEventListener(MidiEvent.CONTROL_CHANGE, handleMidiData);
			_midiSystem.init();
			
			_midiKeyboard 			= new MidiKeyboard();
			_midiKeyboard.x			= 19;
			_midiKeyboard.y			= 300;
			_midiKeyboard.addEventListener(MidiEvent.NOTE_ON, handleMidiKeyboardEvent);
			_midiKeyboard.addEventListener(MidiEvent.NOTE_OFF, handleMidiKeyboardEvent);
			addChild(_midiKeyboard);
		}

		private function handleMidiKeyboardEvent(event:MidiEvent):void
		{
			_midiSystem.sendMidiData(event.mididata);
		}

		private function handleEvent(event:MouseEvent):void
		{
			if(_midiSystem.state == MidiSystem.CONFIG_HIDDEN)
			{
				_midiSystem.showConfig();
				_midiConfigBtn.label = "close midi config";
				return;
			}
			_midiSystem.hideConfig();
			_midiConfigBtn.label = "show midi config";
		}

		private function handleMidiData(event:MidiEvent):void
		{
			switch(event.type)
			{
				case MidiEvent.NOTE_ON:
				case MidiEvent.NOTE_OFF:
					_midiKeyboard.handleMidiData(event.mididata);
					break;
				default:
					trace(event.mididata.toString());
			}
		}
	}
}
