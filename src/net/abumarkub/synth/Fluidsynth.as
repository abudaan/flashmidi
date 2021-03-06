package net.abumarkub.synth
{
	import flash.events.IOErrorEvent;
	import cmodule.fluidsynth_swc.CLibInit;

	import net.abumarkub.midi.MidiCommand;
	import net.abumarkub.midi.MidiData;
	import net.abumarkub.midi.MidiEvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/*
	 * This class is based on the FluidsynthTest class written by Yoann Huiban, see:
	 * 
	 * http://code.google.com/p/flash-midi-player/
	 * 
	 * I have created a wrapper around his class to make it fit in my midi classes.
	 * 
	 * Fluidsynth makes it possible to load soundfont2.0 files into the flashplayer. A soundfont file consists of samples
	 * and these samples can be used in actionscript.
	 * 
	 * Unfortunately, the SampleDataEvent method is needed for this which means unacceptable latencies. Because the SampleDataEvent
	 * needs at least 2048 samples to process, and the SampleDataEvent expects the audio in 44.1 kHz sample rate, the latency will be 46ms
	 * 
	 * Calculation of latency: (1000/44100 * 2048 ≈ 46)
	 * 
	 * 
	 * In this example i have used a free soundfont of a Steinway grandpiano, see:
	 * 
	 * http://www.pianosounds.com/freesoundfont.htm
	 * 
	 */

	public class Fluidsynth extends EventDispatcher implements ISynth
	{
		public static const SAMPLES_LOADED:String = "SAMPLES_LOADED";
		
		private var _urlStream:URLStream;
		private var _sf2FileData:ByteArray;
		private var _cLibInit:CLibInit;
		private var _clib:Object;
		private var _sound:Sound = null;
		private var _channel:SoundChannel;
		private var _id:uint;
		private var _description:String = "Fluidsynth (internal)";
		private var _initialized:Boolean;
		private var _url:String;

		public function Fluidsynth(url:String = "")
		{			
			_url  = url == "" || url == null ? "LK_Piano.sf2" : url;

			_cLibInit 		= new CLibInit;
			_sf2FileData 	= new ByteArray();
		}
		
		public function init():void
		{
			_urlStream 		= new URLStream();
			_urlStream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_urlStream.addEventListener(Event.COMPLETE, completeHandler);
			_urlStream.load(new URLRequest(_url));
//			_urlStream.load(new URLRequest("./example.sf2"));			
		}

		private function errorHandler(event:IOErrorEvent):void
		{
			trace(event.text);
		}
		
		private function completeHandler(event:Event):void
		{
			_urlStream.readBytes(_sf2FileData, 0, _urlStream.bytesAvailable);
			_clib = _cLibInit.init();
			//_cLibInit.supplyFile("VintageDreamsWaves-v2.sf2", _sf2FileData);
			/*
			 * you do not need to have a physical file with the name example.sf2 (very weird)
			 */
			_cLibInit.supplyFile("./example.sf2", _sf2FileData);
			_clib.fluidsynth_init(0,0);
			_initialized = true;
			dispatchEvent(new SynthEvent(SynthEvent.INITIALIZED));
		}
		
		public function handleMidiEvent(event:MidiEvent):void
		{
			processMidiData(event.mididata);
		}
		
		public function handleMidiData(data:MidiData):void
		{
			processMidiData(data);
		}

		public function allNotesOff():void
		{
			if(_sound != null)
			{
				_sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, samplesGenerator);
				_channel.removeEventListener(Event.SOUND_COMPLETE, eventCompleteHandler);
				_sound = null;
			}
		}
		
		private function processMidiData(data:MidiData):void
		{
			if(data.command == MidiCommand.NOTE_OFF || data.velocity == 0)
			{
				//trace("note off fluidsynth");
				_clib.fluidsynth_noteoff(data.channel,data.noteNumber);
			}
			else if(data.command == MidiCommand.NOTE_ON)
			{
				//trace("note on fluidsynth",data.channel,data.noteNumber,data.velocity);
				_clib.fluidsynth_noteon(data.channel,data.noteNumber,data.velocity);				
			}
			
			start();		
		}
		
		private function start():void
		{
			if(_sound == null)
			{
				_sound = new Sound();
				_sound.addEventListener(SampleDataEvent.SAMPLE_DATA, samplesGenerator);
				_channel = _sound.play();
				_channel.addEventListener(Event.SOUND_COMPLETE, eventCompleteHandler);
			}
		}

		private function samplesGenerator(event:SampleDataEvent):void
		{
			var rawSampleData:ByteArray = new ByteArray();

			rawSampleData.endian = Endian.LITTLE_ENDIAN;

			// trace("sineWavGenerator:"+event.position);
			_clib.fluidsynth_getdata(rawSampleData);
			rawSampleData.position = 0;
			// trace("rawSampleData:"+rawSampleData.toString());
			// trace("rawSampleData.bytesAvailable:"+rawSampleData.bytesAvailable);
			for(var c:int = 0; c < 2048; c++ )
			{
				var sample:Number = rawSampleData.readFloat();
				// left channel
				event.data.writeFloat(sample);
				// right channel
				event.data.writeFloat(sample);
			}
		}

		private function eventCompleteHandler(event:Event):void
		{
			//trace("eventCompleteHandler");
			_sound = null;
		}
		
		public function get initialized():Boolean
		{
			return _initialized;
		}
		
		public function set id(value:uint):void
		{
			_id = value; 
		}
		
		public function get id():uint
		{
			return _id;
		}
		
		public function get description():String
		{
			return _description;
		}					
	}
}