package net.abumarkub.midi.system
{
	import net.abumarkub.midi.MidiData;
	import net.abumarkub.synth.ISynth;

	import flash.events.IEventDispatcher;
	/**
	 * @author abudaan
	 */
	public interface IMidiSystem extends IEventDispatcher
	{
		function sendMidiData(md:MidiData):void
		function addSynth(synth:ISynth):void
		function showConfig():void
		function hideConfig():void
		function stop():void
		function init(initExpanded:Boolean = false):void
		function get state():String
		function get type():String
		function set x(val:Number):void
		function set y(val:Number):void
	}
}
