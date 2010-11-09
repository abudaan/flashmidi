package net.abumarkub.midi.system.event
{
	import net.abumarkub.midi.system.MidiDeviceDVO;

	import flash.events.Event;
	/**
	 * @author abudaan
	 */
	public class MidiSystemEvent extends Event
	{
		public static const STOP_SERVICE:String 	= "STOP_SERVICE";
		public static const START_SERVICE:String 	= "START_SERVICE";
		public static const GET_CONFIG:String 		= "GET_CONFIG";
		public static const WRITE_CONFIG:String 	= "WRITE_CONFIG";
		public static const SET_MIDI_IN:String 		= "SET_MIDI_IN";
		public static const SET_MIDI_OUT:String 	= "SET_MIDI_OUT";
		
		private var _midiInDevice:MidiDeviceDVO;
		private var _midiOutDevice:MidiDeviceDVO;

		public function MidiSystemEvent(type:String, midiIn:MidiDeviceDVO = null, midiOut:MidiDeviceDVO = null, bubbles:Boolean = false) 
		{
			super(type, bubbles);
			_midiInDevice = midiIn;
			_midiOutDevice = midiOut;
//			if(midiIn != null)
//			{
//				trace(midiIn.name);
//			}
//			if(midiOut != null)
//			{
//				trace(midiOut.name);
//			}
		}
		
	    public override function clone():Event
	    {
	        return new MidiSystemEvent(type, _midiInDevice, _midiOutDevice);
		}  

		public function get midiInDevice():MidiDeviceDVO
		{
			return _midiInDevice;
		}

		public function get midiOutDevice():MidiDeviceDVO
		{
			return _midiOutDevice;
		}		
	}
}
