package net.abumarkub.midi.system
{
	import net.abumarkub.midi.MidiData;
	import net.abumarkub.midi.MidiEvent;
	import net.abumarkub.midi.harmony.Note;
	import net.abumarkub.midi.system.event.MidiConnectionEvent;
	import net.abumarkub.midi.system.event.MidiSettingsEvent;
	import net.abumarkub.synth.ISynth;

	import flash.display.Sprite;

	/**
	 * @author abudaan
	 * 
	 * This is an abstract class: do not instantiate this class directly! 
	 * 
	 * Please get an instance of either subclass MidiSystemAir or subclass MidiSystemWeb
	 * 
	 * @see MidiSystemAir
	 * @see MidiSystemWeb
	 * 
	 * This class is the core of the AS3 midi system:
	 * 
	 * - MidiConnection sets up the connection to your hardware midi system
	 * - MidiSettings stores and retrieves the default midi in and midi out device
	 * - MidiConfig lets you choose between the available midi devices, and stop and start the connection
	 * 
	 * 
	 * The difference between the air and the web version is:
	 * - the way it connects to your hardware midi system
	 * - the way it stores default midi devices
	 * 
	 * The web version connects to your hardware midi system via an applet that is connected to Flash via the ExternalInterface
	 * The air version connects to your hardware midi system via a commandline program that is started by a NativeProcess
	 * 
	 * The web version stores the default midi devices in a SharedObject
	 * The air version stores the default midi devices in a File on your local harddrive
	 * 
	 * You can see that this class only instantiates the proper version of MidiSettings and MidiSystem, and for the rest all logic takes place
	 * in the super class MidiSystem. 
	 * 
	 * Note that MidiSystem, MidiSettings and MidiConnection do not implement the interfaces IMidiSystem, IMidiSettings and IMidiConnection respectively:
	 * this is done to make those classes 'abstract' and prevents you from instantiating and using these classes directly.
	 * 
	 * Whereas:
	 * - the classes MidiSystemWeb and MidiSystemAir both implement IMidiSystem
	 * - the classes MidiConnectionWeb and MidiConnectionAir both implement IMidiConnection
	 * - the classes MidiSettingsWeb and MidiSettingsAir both implement IMidiSettings
	 * 
	 */
	public class MidiSystem extends Sprite
	{
		public static const CONFIG_HIDDEN:String 		= "CONFIG_HIDDEN";
		public static const CONFIG_VISIBLE:String 		= "CONFIG_VISIBLE";

		public static const TYPE_AIR:String 			= "TYPE_AIR";
		public static const TYPE_WEB:String 			= "TYPE_WEB";
		
		protected static var _type:String 				= "";

		protected var _midiConfig:MidiConfig;
		protected var _midiConnection:IMidiConnection	= null;
		protected var _midiSettings:IMidiSettings		= null;
		
		
		/**
		 * @param configUI: the MidiConfigUI to be used. If you leave this parameter empty, the default MidiConfigUI will be used
		 * @see MidiConfigUI
		 */
		public function MidiSystem(configUI:IMidiConfigUI=null)
		{															
			if(configUI != null)
			{
				if(!configUI is IMidiConfigUI)
				{
					trace("The supplied MidiConfigUI does not implement IMidiConfigUI. Using the default MidiConfigUI instead.");
					configUI = new MidiConfigUI();
				}
			}						
			
			_midiConfig = new MidiConfig(configUI, _midiConnection, _midiSettings);
			
			/**
			 * statuses messages from MidiConnection
			 */
			_midiConnection.addEventListener(MidiConnectionEvent.CONFIG, handleMidiConnectionEvent);	
			_midiConnection.addEventListener(MidiConnectionEvent.MIDI_IN_CHANGED, handleMidiConnectionEvent);	
			_midiConnection.addEventListener(MidiConnectionEvent.MIDI_OUT_CHANGED, handleMidiConnectionEvent);	
			_midiConnection.addEventListener(MidiConnectionEvent.MIDI_CONNECTION_STARTED, handleMidiConnectionEvent);
			_midiConnection.addEventListener(MidiConnectionEvent.MIDI_CONNECTION_STOPPED, handleMidiConnectionEvent);
			_midiConnection.addEventListener(MidiConnectionEvent.COMMAND_SENT, handleMidiConnectionEvent);	
			_midiConnection.addEventListener(MidiConnectionEvent.ERROR, handleMidiConnectionEvent);	
			_midiConnection.addEventListener(MidiConnectionEvent.WARNING, handleMidiConnectionEvent);
			_midiConnection.addEventListener(MidiConnectionEvent.MESSAGE, handleMidiConnectionEvent);	
			
			/**
			 * midi events
			 */			
			_midiConnection.addEventListener(MidiEvent.NOTE_ON, handleMidiEvent);	
			_midiConnection.addEventListener(MidiEvent.NOTE_OFF, handleMidiEvent);	
			_midiConnection.addEventListener(MidiEvent.PITCH_BEND, handleMidiEvent);
			_midiConnection.addEventListener(MidiEvent.POLY_PRESSURE, handleMidiEvent);
			_midiConnection.addEventListener(MidiEvent.PROGRAM_CHANGE, handleMidiEvent);
			_midiConnection.addEventListener(MidiEvent.CONTROL_CHANGE, handleMidiEvent);
			_midiConnection.addEventListener(MidiEvent.CHANNEL_PRESSURE, handleMidiEvent);
			_midiConnection.addEventListener(MidiEvent.SYSTEM_EXCLUSIVE, handleMidiEvent);

			
			_midiSettings.addEventListener(MidiSettingsEvent.COULD_NOT_READ_CONFIG_FILE, handleMidiSettingsEvent);	
			_midiSettings.addEventListener(MidiSettingsEvent.CONFIG_FILE_READ, handleMidiSettingsEvent);	
			_midiSettings.addEventListener(MidiSettingsEvent.CONFIG_FILE_WRITTEN, handleMidiSettingsEvent);	
		}
		
		/**
		 * Method init checks if a midi settings config file is present
		 * After the config file is read, the midi service is started in the event handler
		 * Also when a config file could be read or found, the midi service is started in the event handler
		 * @param initWithConfigUI: when set to 'true' the MidiConfigUI is shown directly. defaults to false
		 */
		public function init(initWithConfigUI:Boolean = false):void
		{	
			initWithConfigUI ? showConfig() : hideConfig();
			_midiSettings.readConfig();
		}

		protected function startService():void
		{
			_midiConnection.start();
		}

		protected function handleMidiSettingsEvent(event:MidiSettingsEvent):void
		{
			//trace(event);
			switch(event.type)
			{
				case MidiSettingsEvent.COULD_NOT_READ_CONFIG_FILE:
					startService();
					break;
			
				case MidiSettingsEvent.COULD_NOT_WRITE_CONFIG_FILE:
					_midiConfig.writeLog("[error] Could not read the midi settings config file");
					break;
			
				case MidiSettingsEvent.CONFIG_FILE_READ:
					_midiConfig.writeLog("[msg] default midi in: " + _midiSettings.midiInDeviceName + "<br/>default midi out: " + _midiSettings.midiOutDeviceName,true);
					startService();
					break;

				case MidiSettingsEvent.CONFIG_FILE_WRITTEN:
					_midiConfig.writeLog("[msg] Midi settings successfully written to config file");
					break;
			
			}
		}
		
		protected function handleMidiConnectionEvent(event:MidiConnectionEvent):void 
		{			
			switch(event.type)
			{
				case MidiConnectionEvent.CONFIG:
				case MidiConnectionEvent.MIDI_IN_CHANGED:
				case MidiConnectionEvent.MIDI_OUT_CHANGED:
				case MidiConnectionEvent.MIDI_CONNECTION_STOPPED:
				case MidiConnectionEvent.MIDI_CONNECTION_STARTED:
					_midiConfig.updateUI(event);
					break;
					
				case MidiConnectionEvent.COMMAND_SENT:
					_midiConfig.writeLog("[out] "  + event.message);
					break;

				case MidiConnectionEvent.ERROR:
					_midiConfig.writeLog("[error] " + event.message);
					break;

				case MidiConnectionEvent.WARNING:
					_midiConfig.writeLog("[warning] " + event.message);
					break;

				case MidiConnectionEvent.MESSAGE:
					_midiConfig.writeLog("[msg] " + event.message);
					break;
			}
		}
		
		protected function handleMidiEvent(event:MidiEvent):void 
		{
			if(_midiConfig.internalSynth != null)
			{
				_midiConfig.internalSynth.handleMidiEvent(event);
			}
			_midiConfig.writeLog("[in] " + event.mididata.toString());
			dispatchEvent(event);		
		}		
		
		/**
		 * sends midi events that are generated in AS3 to the hardware midi system
		 * @param data: the data to be sent to the hardware midi system 
		 * @see MidiData
		 */
		public function sendMidiData(data:MidiData):void
		{
			if(_midiConfig.internalSynth != null)
			{
				_midiConfig.internalSynth.handleMidiData(data);
				var msg:String = "[internal] " + data.command + "," + data.channel + "," + data.data1 + "," + data.data2 + " (" + Note.getName(data.data1, Note.FLAT) + ")";
				_midiConfig.writeLog(msg);
				return;
			}
			_midiConnection.sendMidiData(data);
		}

		public function stop():void
		{
			_midiConnection.stop();
		}

		public function showConfig():void
		{
			_midiConfig.showConfigUI();
		}
		
		public function hideConfig():void
		{
			_midiConfig.hideConfigUI();
		}	
		
		public function addSynth(synth:ISynth):void
		{
			_midiConfig.addSynth(synth);
		}

		public function get state():String
		{
			return _midiConfig.state;
		}		

		public function get type():String
		{
			return _type;
		}			
	}
}
