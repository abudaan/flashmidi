/*
 * Copyright (c) 2009, abumarkub <abudaan at gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the abumarkub nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package net.abumarkub.midi.keyboard
{
	import net.abumarkub.midi.MidiCommand;
	import net.abumarkub.midi.MidiData;
	import net.abumarkub.midi.MidiEvent;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	/**
	 * @author abudaan
	 */
	public class MidiKeyboard extends Sprite
	{
//		private static const KEY_LENGTH:Number;
//		private static const KEY_WIDTH:Number;
	
		private var _startNote:uint;
		private var _endNote:uint;
		private var _keys:Dictionary;
		private var _keyPadding:Number = 1;
		
		public function MidiKeyboard(startNote:uint=21,endNote:uint=108)
		{
			_startNote 		= startNote;	
			_endNote 		= endNote;	
			_keys			= new Dictionary();
			
			var newX:Number = 0;
			var i:uint;
			var key:MidiKey;
			
			for(i = _startNote; i <= _endNote; i++) 
			{
				key 		= new MidiKey(i);
				_keys[i]	= key;
				key.x 		= key.isBlack() ? newX - key.width/2 : newX;				
				newX 	   += key.isBlack() ? 0 : _keyPadding + key.width;
				addChild(key);
			}
			
			//put all black keys on top of white keys
			for each(key in _keys) 
			{
				if(key.isBlack())
				{
					addChild(key);
				}
			}

			addEventListener(MouseEvent.MOUSE_DOWN,handleMouseEvent);
		}

		private function handleMouseEvent(event:MouseEvent):void
		{
			var midiData:MidiData;
			var key:MidiKey = event.target as MidiKey;
			var velocity:uint;
			
			if(key == null)
			{
				if(event.type == MouseEvent.MOUSE_UP)
				{
					removeEventListener(MouseEvent.MOUSE_UP,handleMouseEvent);
					removeEventListener(MouseEvent.MOUSE_OUT,handleMouseEvent);
					removeEventListener(MouseEvent.MOUSE_OVER,handleMouseEvent);
					stage.removeEventListener(MouseEvent.MOUSE_UP,handleMouseEvent);
				}	
				return;
			}
			//trace(key.noteName(Note.SHARP), event.type);
			
			switch(event.type)
			{
				case MouseEvent.MOUSE_DOWN:
					addEventListener(MouseEvent.MOUSE_UP,handleMouseEvent);
					addEventListener(MouseEvent.MOUSE_OUT,handleMouseEvent);
					addEventListener(MouseEvent.MOUSE_OVER,handleMouseEvent);
					stage.addEventListener(MouseEvent.MOUSE_UP,handleMouseEvent);

				case MouseEvent.MOUSE_OVER:
					key.keyDown();
					velocity 	= key.calculateVelocity(event.localY);
					midiData	= new MidiData(MidiCommand.NOTE_ON,0,0,key.noteNumber,velocity);
					dispatchEvent(new MidiEvent(MidiEvent.NOTE_ON, midiData));
					break;

				case MouseEvent.MOUSE_UP:
					removeEventListener(MouseEvent.MOUSE_UP,handleMouseEvent);
					removeEventListener(MouseEvent.MOUSE_OVER,handleMouseEvent);
					removeEventListener(MouseEvent.MOUSE_OUT,handleMouseEvent);
					stage.removeEventListener(MouseEvent.MOUSE_UP,handleMouseEvent);
					
				case MouseEvent.MOUSE_OUT:
					key.keyUp();
					velocity 	= 0;
					midiData	= new MidiData(MidiCommand.NOTE_OFF,0,0,key.noteNumber,velocity);
					dispatchEvent(new MidiEvent(MidiEvent.NOTE_OFF, midiData));
					break;
			}
		}

		public function handleMidiData(data:MidiData):void
		{
			/**
			 * check the command against values in MidiCommand because the command is sent as an int
			 * and MidiEvent stores commands verbose as a String!
			 */
			if(data.command != MidiCommand.NOTE_ON && data.command != MidiCommand.NOTE_OFF)
			{
				return;
			}
			var key:MidiKey = _keys[data.noteNumber];
			key.processMidiData(data);
		}
	}
}
