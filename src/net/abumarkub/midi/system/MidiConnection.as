package net.abumarkub.midi.system
{
	import net.abumarkub.midi.MidiCommand;
	import net.abumarkub.midi.MidiData;
	import net.abumarkub.midi.MidiEvent;
	import net.abumarkub.midi.system.event.MidiConnectionEvent;

	import flash.events.EventDispatcher;
	/**
	 * @author abudaan
	 * 
	 * This is an abstract class: do not instantiate this class directly! 
	 * 
	 * Please get an instance of either MidiConnectionAir or MidiConnectionWeb
	 * 
	 * @see MidiConnectionAir
	 * @see MidiConnectionWeb
	 * 
	 */ 
	public class MidiConnection extends EventDispatcher
	{			
		//commands that are sent to the applet or the commandline service
		public static const KEEP_ALIVE:String			= "keep-alive";
		public static const GET_DEVICES:String			= "get-devices";
		public static const START:String				= "start";
		public static const STOP:String					= "stop";
		public static const SET_MIDI_IN:String			= "midi-in";
		public static const SET_MIDI_OUT:String			= "midi-out";
		public static const SET_MIDI_IN_OUT:String		= "midi-in-out";
		public static const SEND_MIDI_DATA:String		= "as3-midi-event";

		protected var _configData:XML;
		protected var _midiInDeviceId:int				= -1;
		protected var _midiOutDeviceId:int				= -1;
		protected var _running:Boolean					= false;
		
		protected function parseData(s:String):void
		{
			//trace(s);
			var data:XML;
			var midiData:MidiData;
			var xml:XML;
			
			try
			{
				data = new XML("<data>" + s + "</data>");
			}
			catch(e:TypeError)
			{
				// load not yet complete
				dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.ERROR, e.errorID + " " + e.message));
				return;
			}


			for each(xml in data.children())
			{
				var type:String = xml.name();
				//trace("+++++",type);
				
				switch(type)
				{
					case MidiConnectionEvent.CONFIG:
						_configData = xml[0].copy();
						dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.CONFIG));
						break;
						
					case MidiConnectionEvent.MIDI_IN_CHANGED:
						_midiInDeviceId = xml[0];			
						dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.MIDI_IN_CHANGED));
						break;
						
					case MidiConnectionEvent.MIDI_OUT_CHANGED:
						_midiOutDeviceId = xml[0];			
						dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.MIDI_OUT_CHANGED));
						break;
	
					case MidiConnectionEvent.MIDI_DATA_RECEIVED:
						midiData = new MidiData(xml.@command, xml.@status, xml.@channel, xml.@data1, xml.@data2);
						if(midiData.command == MidiCommand.NOTE_ON && midiData.velocity == 0)
						{
							midiData.command = MidiCommand.NOTE_OFF;
						}
						dispatchEvent(new MidiEvent(MidiCommand.getDescription(midiData.command),midiData));						
						break;
						
					case MidiConnectionEvent.MIDI_CONNECTION_STARTED:
						dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.MIDI_CONNECTION_STARTED, "midi connection started"));
						break;

					case MidiConnectionEvent.MIDI_CONNECTION_STOPPED:
						dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.MIDI_CONNECTION_STOPPED, "midi connection stopped"));
						break;

					case MidiConnectionEvent.ERROR:
						dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.ERROR, xml.text() + " @" + xml.@id));
						break;
	
					case MidiConnectionEvent.WARNING:
						dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.WARNING, xml.text() + " @" + xml.@id));
						break;
								
					default:
						dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.WARNING, s));
				}
			}
		}
		
		public function get configData():XML
		{
			return  _configData;
		}

		public function get midiInDeviceId():int
		{
			return _midiInDeviceId;
		}
		
		public function get midiOutDeviceId():int
		{
			return _midiOutDeviceId;
		}
		
		public function get running():Boolean
		{
			return _running;
		}		
	}
}
