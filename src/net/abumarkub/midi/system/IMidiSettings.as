package net.abumarkub.midi.system
{
	import flash.events.IEventDispatcher;
	/**
	 * @author abudaan
	 */
	public interface IMidiSettings extends IEventDispatcher
	{
		function readConfig():void
		function writeConfig(midiInDeviceName:String,midiOutDeviceName:String):void
		function get midiInDeviceName():String
		function get midiOutDeviceName():String
	}
}
