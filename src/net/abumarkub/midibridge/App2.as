package net.abumarkub.midibridge
{
	import net.abumarkub.midi.keyboard.MidiKeyboard;
	import net.abumarkub.midi.keyboard.MidiKeyboardEvent;

	import flash.display.Sprite;

	/**
	 * @author abudaan
	 */
	public class App2 extends Sprite
	{
		public function App2()
		{
			var kb:MidiKeyboard = new MidiKeyboard(21,108);
			kb.addEventListener(MidiKeyboardEvent.KEY_DOWN, handleKeyboardEvent);
			kb.addEventListener(MidiKeyboardEvent.KEY_UP, handleKeyboardEvent);
			addChild(kb);
			
			
			var s:String = "[out] aap is boos!";
			s = s.replace(/([[])([a-z]+)(])/,"<span class='prefix'>$2</span>");
			trace(s);
		}

		private function handleKeyboardEvent(event:MidiKeyboardEvent):void
		{
			//trace(event.type);
		}
	}
}
