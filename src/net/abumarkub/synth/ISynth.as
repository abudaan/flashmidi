package net.abumarkub.synth
{
	import net.abumarkub.midi.MidiData;
	import net.abumarkub.midi.MidiEvent;
	/**
	 * @author abudaan
	 */
	public interface ISynth
	{
		function handleMidiEvent(event:MidiEvent):void
		function handleMidiData(data:MidiData):void
		function allNotesOff():void
	}
}
