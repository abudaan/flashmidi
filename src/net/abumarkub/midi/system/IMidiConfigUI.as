package net.abumarkub.midi.system
{
	import flash.events.IEventDispatcher;
	/**
	 * @author abudaan
	 */
	public interface IMidiConfigUI extends IEventDispatcher
	{
		function updateDevices(devices:MidiDevices):void
		function setMidiIn(port:int):void
		function setMidiOut(port:int):void
		function writeLog(msg:String):void
		function show():void
		function hide():void
	}
}
