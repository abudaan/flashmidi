package net.abumarkub.midi.system
{
	import flash.events.IEventDispatcher;
	import net.abumarkub.midi.MidiData;
	/**
	 * @author abudaan
	 */
	public interface IMidiConnection extends IEventDispatcher
	{
		function start():void
		function stop():void
		
		function setInput(id:int):void
		function setOutput(id:int):void
		function sendMidiData(data:MidiData):void
		function getMidiConfig():void
		
		function get configData():XML
		function get midiInDeviceId():int
		function get midiOutDeviceId():int
		function get running():Boolean
	}
}
