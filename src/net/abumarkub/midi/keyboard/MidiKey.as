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
	import net.abumarkub.midi.harmony.Note;

	import flash.display.Shape;
	import flash.display.Sprite;

	/**
	 * @author abudaan
	 */
	public class MidiKey extends Sprite implements IMidiKey
	{
		public static const BLACK_KEY:String = "BLACK";
		public static const WHITE_KEY:String = "WHITE";
		
		private var _bg:Shape;
		private var _type:String;
		private var _noteNumber:uint;
		private var _velocity:uint;
		private var _keyLength:uint;
		private var _enabled:Boolean = true;
		private var _selected:Boolean = false;
		private var _keyWidth:Number;
		
		public function MidiKey(noteNumber:uint)
		{
			_noteNumber = noteNumber;
			setType();
			
			_bg = new Shape();
			addChild(_bg);			

			initUI();
		}

		private function initUI():void
		{
//			_keyLength 	= isBlack() ? 25 : 36;
//			_keyWidth 	= isBlack() ? 4.5 : 7;
			_keyLength 	= isBlack() ? 34 : 50;
			_keyWidth 	= isBlack() ? 6 : 9;
			keyUp();
		}

		private function setType():void
		{
			switch(true)
			{
				case _noteNumber % 12 == 1:
				case _noteNumber % 12 == 3:
				case _noteNumber % 12 == 6:
				case _noteNumber % 12 == 8:
				case _noteNumber % 12 == 10:
					_type = BLACK_KEY;
					break;
				default:
					_type = WHITE_KEY;
			}
			//trace(_noteNumber, isBlack());
		}
		
		private function drawKey(color:Number):void
		{
			_bg.graphics.clear();
			_bg.graphics.beginFill(color);
			_bg.graphics.drawRect(0,0,_keyWidth,_keyLength);
			_bg.graphics.endFill();			
			
			if(isBlack())
			{
				_bg.graphics.lineStyle(.001,color == 0x000000 ? 0xffffff : 0x000000,.8);
				_bg.graphics.moveTo(1,1);
				_bg.graphics.lineTo(1, _keyLength - 2);
				_bg.graphics.lineTo(_keyWidth - 2, _keyLength - 2);
			}
			else
			{
				_bg.graphics.lineStyle(.1,0x000000);
				_bg.graphics.lineTo(.1, _keyLength - .2);
				_bg.graphics.lineTo(_keyWidth - .2, _keyLength - .2);
				_bg.graphics.lineTo(_keyWidth - .2, 0.1);
				_bg.graphics.lineTo(0.1, 0.1);
			}
		}
		
		public function keyDown():void
		{
			drawKey(0xffc3c3);
		}
		
		public function keyUp():void
		{
			drawKey(isBlack() ? 0x000000 : 0xffffff);
		}
		
		public function processMidiData(data:MidiData):void
		{
			//some midi keyboards don't send note off (128) events, so check velocity (data2) as well
			if(data.command == MidiCommand.NOTE_OFF || data.velocity == 0)
			{
				keyUp();
				return;
			}
			keyDown();
		}
		
		public function isBlack():Boolean
		{
			return _type == BLACK_KEY;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function get noteNumber():uint
		{
			return _noteNumber;
		}
		
		public function noteName(mode:String):String
		{
			return Note.getName(_noteNumber, mode);
		}
		
		public function get velocity():uint
		{
			return _velocity;
		}

		public function calculateVelocity(localY:Number):uint
		{
			_velocity = Math.round((localY / _keyLength) * 127);
			return _velocity;
		}
	}
}
