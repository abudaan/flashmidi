package net.abumarkub.synth
{
	import flash.events.IEventDispatcher;
	import net.abumarkub.midi.MidiData;
	import net.abumarkub.midi.MidiEvent;
	/**
	 * @author abudaan
	 */
	public interface ISynth extends IEventDispatcher
	{
		function handleMidiEvent(event:MidiEvent):void
		function handleMidiData(data:MidiData):void
		function allNotesOff():void
		function init():void
		function get initialized():Boolean
		function get id():uint
		function set id(value:uint):void
		function get description():String
	}
}
