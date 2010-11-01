package net.abumarkub.midi.keyboard
{
	import flash.events.Event;
	/**
	 * @author abudaan
	 */
	public class MidiKeyboardEvent extends Event
	{
		public static const KEY_DOWN:String = "KEY_DOWN";
		public static const KEY_UP:String = "KEY_UP";
		
		private var _velocity:uint;
		private var _noteNumber:uint;
		private var _channel:uint;
		private var _command:uint;
		private var _status:uint;
		
		public function MidiKeyboardEvent(type:String, _noteNumber:uint,_velocity:uint, _command:uint, _channel:uint = 1, _status:uint = 0, bubbles:Boolean=true)
		{
			_noteNumber = noteNumber;
			_velocity 	= velocity;
			_command 	= command;
			_channel 	= channel;
			_status 	= status;
			super(type, bubbles);
		}

	    public function get noteNumber():uint
	    {
			return _noteNumber;
		}
		
		public function get velocity():uint
		{
			return _velocity;
		}		
	    
		public function get channel():uint
		{
			return _channel;
		}		
	    
		public function get command():uint
		{
			return _command;
		}		
	    
		public function get status():uint
		{
			return _status;
		}		
	    
	    public override function clone():Event
	    {
	        return new MidiKeyboardEvent(type,_noteNumber,_velocity, _command, _channel, _status, bubbles);
	    }  	
	}
}
