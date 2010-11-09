package net.abumarkub.midi.system
{
	import net.abumarkub.midi.system.event.MidiConnectionEvent;
	import net.abumarkub.midi.system.event.MidiSystemEvent;
	import net.abumarkub.synth.ISynth;
	import net.abumarkub.synth.SynthEvent;
	/**
	 * @author abudaan
	 * 
	 * This is a wrapper class for MidiConfigUI; it listens for events from MidiSettings and MidiConnnection and updates
	 * MidiConfigUI if necessary.
	 * 
	 * In fact it is a delegate for MidiSystem; by moving all logic that has to do with MidiConfigUI in a seperate class, MidiSystem
	 * is more well-organised
	 * 
	 * 
	 */
	public class MidiConfig
	{
		public static const INTERNAL_SYNTHS_START_ID:uint = 1000;

		private var _configUI:IMidiConfigUI;
		private var _midiConnection:IMidiConnection;
		private var _midiSettings:IMidiSettings;

		private var _internalSynths:Vector.<ISynth>		= new Vector.<ISynth>();
		private var _internalSynth:ISynth				= null;
		private var _configXML:XML						= <config/>;
		private var _midiDevices:MidiDevices			= null;
		private var _firstRun:Boolean					= true;
		private var _state:String;
		
		/**
		 * If _firstRun is true, the midi in- and outport are set to the default devices as read from the config file by MidiSettings
		 *
		 * If _firstRun is false, the midi in- and outport are not affected after a rescan for midi devices
		 * 
		 * Every time the MidiConnection is started, _firstRun is set to true
		 */
				
		
		public function MidiConfig(configUI:IMidiConfigUI,midiConnection:IMidiConnection,midiSettings:IMidiSettings)
		{
			_configUI 		= configUI;
			_midiConnection = midiConnection;
			_midiSettings 	= midiSettings;

			_configUI.addEventListener(MidiSystemEvent.GET_CONFIG, handleUIEvent);
			_configUI.addEventListener(MidiSystemEvent.SET_MIDI_IN, handleUIEvent);
			_configUI.addEventListener(MidiSystemEvent.SET_MIDI_OUT, handleUIEvent);
			_configUI.addEventListener(MidiSystemEvent.STOP_SERVICE, handleUIEvent);
			_configUI.addEventListener(MidiSystemEvent.START_SERVICE, handleUIEvent);
			_configUI.addEventListener(MidiSystemEvent.WRITE_CONFIG, handleUIEvent);
		}
		
		/**
		 * listen for events from MidiConfigUI
		 */		
		private function handleUIEvent(event:MidiSystemEvent):void
		{
			//trace(event.type);
			switch(event.type)
			{
				case MidiSystemEvent.GET_CONFIG:
					_midiConnection.getMidiConfig();
					break;

				case MidiSystemEvent.SET_MIDI_IN:
					_midiConnection.setInput(event.midiInDevice.id);
					break;

				case MidiSystemEvent.SET_MIDI_OUT:
					_midiConnection.setOutput(event.midiOutDevice.id);
					break;
					
				case MidiSystemEvent.START_SERVICE:
					_midiConnection.start();
					break;

				case MidiSystemEvent.STOP_SERVICE:
					_midiConnection.stop();
					break;
					
				case MidiSystemEvent.WRITE_CONFIG:
					_midiSettings.writeConfig(event.midiInDevice.name, event.midiOutDevice.name);
					break;
			}
		}		

		internal function updateUI(event:MidiConnectionEvent):void
		{	
			switch(event.type)
			{
				case MidiConnectionEvent.CONFIG:
					_configXML				= createConfigXML(_midiConnection.configData);						
					_midiDevices			= new MidiDevices(_configXML);
					//populate comboboxes									
					_configUI.updateDevices(_midiDevices);
					
					//set default devices
					if(_firstRun)
					{
						_midiConnection.setInput(_midiDevices.getMidiInDeviceByName(_midiSettings.midiInDeviceName).id);
						_midiConnection.setOutput(_midiDevices.getMidiOutDeviceByName(_midiSettings.midiOutDeviceName).id);
						_firstRun 			= false;
					}
					else
					{
						_configUI.setMidiIn(_midiDevices.getMidiInDeviceById(_midiConnection.midiInDeviceId).id);
						_configUI.setMidiOut(_midiDevices.getMidiOutDeviceById(_midiConnection.midiOutDeviceId).id);						
					}
					break;

				case MidiConnectionEvent.MIDI_IN_CHANGED:
					_configUI.setMidiIn(_midiConnection.midiInDeviceId);
					break;

				case MidiConnectionEvent.MIDI_OUT_CHANGED:
					if(_midiConnection.midiOutDeviceId >= INTERNAL_SYNTHS_START_ID)
					{
						_internalSynth = _internalSynths[_midiConnection.midiOutDeviceId - INTERNAL_SYNTHS_START_ID];
					}
					else
					{
						_internalSynth = null;
					}
					_configUI.setMidiOut(_midiConnection.midiOutDeviceId);
					break;
					
				case MidiConnectionEvent.MIDI_CONNECTION_STOPPED:
					_configXML				= createConfigXML(<config></config>);						
					_midiDevices			= new MidiDevices(_configXML);
					
					_configUI.updateDevices(_midiDevices);
					_configUI.writeLog("[in] " + event.message);
					_configUI.setMidiIn(-1);
					_configUI.setMidiOut(_internalSynth != null ? _internalSynth.id : -1);
					break;

				case MidiConnectionEvent.MIDI_CONNECTION_STARTED:
					_configUI.writeLog("[in] " + event.message);
					_firstRun 				= true;
					_midiConnection.getMidiConfig();
					break;
			}			
		}		
				
		internal function addSynth(synth:ISynth):void
		{
			synth.id = INTERNAL_SYNTHS_START_ID + _internalSynths.length;
			synth.addEventListener(SynthEvent.INITIALIZED,handleSynthEvent);
			synth.init();
			_internalSynths.push(synth);	
		}
		
		private function handleSynthEvent(event:SynthEvent):void
		{
			var synth:ISynth 	= event.target as ISynth;
			synth.removeEventListener(SynthEvent.INITIALIZED,handleSynthEvent);
			writeLog("[msg] " + synth.description + " loaded",true);
			_configXML			= createConfigXML(_configXML);
			_midiDevices 		= new MidiDevices(_configXML);	
			_configUI.updateDevices(_midiDevices);
			_configUI.setMidiIn(_midiDevices.getMidiInDeviceById(_midiConnection.midiInDeviceId).id);
			
			var currOutput:int 	= _midiDevices.getMidiOutDeviceById(_midiConnection.midiOutDeviceId).id;
			var defOutput:int 	= _midiDevices.getMidiOutDeviceByName(_midiSettings.midiOutDeviceName).id;
			if(defOutput >= INTERNAL_SYNTHS_START_ID && currOutput == -1)
			{
				_midiConnection.setOutput(defOutput);
			}
			else
			{
				_configUI.setMidiOut(currOutput);	
			}		
		}

		private function createConfigXML(xml:XML):XML
		{
			var synth:ISynth;
			for(var i:uint = 0; i < _internalSynths.length; i++)
			{
				synth = _internalSynths[i];
				//trace(synth.description,synth.initialized);
				if(synth.initialized)
				{
					xml.appendChild(<device id={synth.id} available="true" type="output"><name>{synth.description}</name></device>);
				}
			}
			return xml;
		}
		
		/**
		 * @param printAlways: when set to true, messages are printed when the UI is closed. If set to false, messages are only
		 * printed when the UI is opened
		 */
		internal function writeLog(msg:String,printAlways:Boolean = false):void
		{
			if(printAlways || _state == MidiSystem.CONFIG_VISIBLE)
			{
				_configUI.writeLog(msg);
			}				
		}

		internal function showConfigUI():void
		{
			_state = MidiSystem.CONFIG_VISIBLE;
			_configUI.show();
		}

		internal function hideConfigUI():void
		{
			_state = MidiSystem.CONFIG_HIDDEN;
			_configUI.hide();
		}
		
		internal function get internalSynth():ISynth
		{
			return _internalSynth;		
		}

		internal function get state():String
		{
			return _state;
		}		
	}
}
