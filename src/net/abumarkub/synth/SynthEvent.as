package net.abumarkub.synth
{
	import flash.events.Event;

	/**
	 * @author abudaan
	 */
	public class SynthEvent extends Event
	{
		public static const INITIALIZED:String = "SYNTH_INITIALIZED";
		
		public function SynthEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}

	    public override function clone():Event
	    {
	        return new SynthEvent(type);
		}  
	}
}
