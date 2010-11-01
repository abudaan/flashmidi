package net.abumarkub.midi.harmony
{
	/**
	 * @author abudaan
	 */
	public class Note
	{
		public static const SHARP:String 			= "SHARP";
		public static const FLAT:String 			= "FLAT";
		
		public static const noteNamesSharp:Array 	= new Array("C","C#","D","D#","E","F","F#","G","G#","A","A#","B");
		public static const noteNamesFlat:Array 	= new Array("C","D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B");
		
		
		public static function getName(noteNumber:uint,mode:String):String
		{
		 	var octave:uint			= Math.floor(((noteNumber)/12)-1); 
			var noteName:String 	= mode == SHARP ? noteNamesSharp[noteNumber % 12] : noteNamesFlat[noteNumber % 12];
			
			return noteName + "" + octave;			
		}
	}
}
