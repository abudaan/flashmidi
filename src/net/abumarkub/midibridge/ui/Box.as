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
package net.abumarkub.midibridge.ui 
{
	import flash.display.Sprite;
	
	/**
	 * @author abudaan
	 */
	public class Box extends Sprite 
	{
		private var _color:Number;
		private var _alpha:Number;
		private var _red:Number;
		private var _green:Number;
		private var _blue:Number;
		private var _width:Number;
		private var _height:Number;
		
		public function Box(color:Number,alpha:Number,w:Number,h:Number)
		{
			_color 		= color;
			_red 		= _color >> 16 & 0xFF;
			_green 		= _color >> 8 & 0xFF;
			_blue		= _color & 0xFF;	
			
			_alpha 		= alpha;
			_width 		= w;
			_height		= h;
			
			draw();
		}
		
		private function draw():void
		{
			graphics.lineStyle(.5,0xffffff);
			graphics.drawRect(-(_width/2),-(_height/2),_width,_height);
			
			graphics.beginFill(_color,_alpha);
			graphics.drawRect(-(_width/2),-(_height/2),_width,_height);
			graphics.endFill();	
		}
		
		public function calculateColor(perc:Number):void
		{
			alpha		= perc;
			return;
			
			_red 		= perc * 255;
			_blue		= (1-perc) * 255;	
			
			_color 	= _red << 16 | _green << 8 | _blue;	
			draw();	
		}
	}
}
