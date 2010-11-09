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
package net.abumarkub.app_midibridge.ui 
{
	import caurina.transitions.Tweener;

	import net.abumarkub.midi.MidiCommand;
	import net.abumarkub.midi.MidiData;
	import flash.display.Sprite;

	/**
	 * @author abudaan
	 */
	public class BoxesAnimation extends Sprite 
	{
		private var _height:Number;
		private var _boxes:Array = new Array();

		public function BoxesAnimation(w:Number,h:Number)
		{
			_height					= -h;
			
			var box:Box;
			var size:Number			= w/88;
			var posX:Number 		= size/2;
			var posY:Number 		= 0;
			var margin:uint 		= 0;

			for(var i:uint = 0; i < 88; i++)
			{
				box 				= new Box(0x0000ff,1,size,size);
				box.x 				= posX;
				box.y 				= posY;
				box.alpha			= 0;
				posX   			   += box.width + margin;
				addChild(box);
				_boxes.push(box);
			}
		}

		public function update(md:MidiData):void
		{
			if(md.command != MidiCommand.NOTE_ON && md.command != MidiCommand.NOTE_OFF)
			{
				return;
			}
			var no:uint 	= md.noteNumber - 21;
			if(_boxes[no] == null)
			{
				return;
			}
			
			if(md.velocity == 0 || md.command == MidiCommand.NOTE_OFF)
			{
				calculateColor(no);
				Tweener.addTween(_boxes[no],{time:1,y:0,transition:"easeInQuad",onUpdate:calculateColor,onUpdateParams:[no],onComplete:boxAnimDone,onCompleteParams:[no]});					
			}
			else
			{
				Tweener.removeTweens(_boxes[no]);
				_boxes[no].y	=  (md.velocity/127) * (_height);
				calculateColor(no);
			}
		}
		
		private function calculateColor(index:uint):void
		{
			_boxes[index].calculateColor(_boxes[index].y/(_height));
		}

		private function boxAnimDone(index:uint):void
		{
			_boxes[index].calculateColor(0);
		}
	}
}
