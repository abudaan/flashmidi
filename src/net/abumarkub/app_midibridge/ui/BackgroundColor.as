/*
 * Copyright (c) 2010, abumarkub <abudaan at gmail.com>
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
	import net.abumarkub.midi.MidiData;
	import net.abumarkub.midi.learn.MidiLearnAssignment;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.StyleSheet;

	/**
	 * @author abudaan
	 */
	public class BackgroundColor extends Sprite 
	{
		public static const CONFIG_VISIBLE:String 	= "CONFIG_VISIBLE";
		public static const CONFIG_HIDDEN:String 	= "CONFIG_HIDDEN";
		
		private var _debug:Boolean = false;
		private var _bg:Shape;
		private var _popup:Shape;
		private var _width:uint;
		private var _height:uint;
		private var _color:Number;
		private var _red:uint;
		private var _green:uint;
		private var _blue:uint;
		private var _midiLearnButtons:MidiLearnButtons;
		private var _state:String;

		public function BackgroundColor(w:Number,h:Number,c:Number,css:StyleSheet)
		{
			_width				= w;
			_height 			= h;
			
			_red 				= c >> 16 & 0xFF;
			_green 				= c >> 8 & 0xFF;
			_blue				= c & 0xFF;	
			_color  			= c;
			if(_debug)trace("BackgroundColor",c,_red,_green,_blue);
			_bg 				= new Shape();
			addChild(_bg);			
			drawBackground();	
			
			_popup 				= new Shape();
			_popup.graphics.lineStyle(.1,0xbbbbbb);
			_popup.graphics.beginFill(0xeeeeee,1);
			_popup.graphics.drawRect(0, 0, 555, 90);
			_popup.graphics.endFill();	
			addChild(_popup);			

			var assignments:Object 		= new Object();
			assignments["redchannel"]	= new MidiLearnAssignment("red channel",setRedChannel);
			assignments["greenchannel"]	= new MidiLearnAssignment("green channel",setGreenChannel);
			assignments["bluechannel"]	= new MidiLearnAssignment("blue channel",setBlueChannel);
			
			_midiLearnButtons			= new MidiLearnButtons(assignments,css);
			_midiLearnButtons.y			= 20;
			_midiLearnButtons.x			= 0;
			addChild(_midiLearnButtons);	

			showMidiLearnButtons(false);
		}
		
		private function drawBackground():void
		{
			_bg.graphics.beginFill(_color);
			_bg.graphics.drawRect(0, 0, _width, _height);
			_bg.graphics.endFill();
		}
		
		public function setColor(r:uint,g:uint,b:uint):void
		{
			_red 	= r;
			_green	= g;
			_blue	= b; 
			_color 	= _red << 16 | _green << 8 | _blue;
			drawBackground();	
		}
		
		public function setRedChannel(md:MidiData):void
		{
			_red 	= ((md.velocity/127)) * 255;
//			_green 	= 0;//((md.velocity/127)) * 255;
//			_blue 	= 0;//((md.velocity/127)) * 255;
			if(_debug)trace("BackgroundColor::setRedChannel",md.velocity,_red,_green,_blue);
			_color 	= _red << 16 | _green << 8 | _blue;
			drawBackground();	
		}
		
		public function setGreenChannel(md:MidiData):void
		{
			_green	= ((md.velocity/127)) * 255;
			if(_debug)trace("BackgroundColor::setGreenChannel",md.velocity,_red,_green,_blue);
			_color 	= _red << 16 | _green << 8 | _blue;
			drawBackground();	
		}
		
		public function setBlueChannel(md:MidiData):void
		{
//			_red	= 0;//((md.velocity/127)) * 255;
//			_green	= 0;//((md.velocity/127)) * 255;
			_blue	= ((md.velocity/127)) * 255;
			if(_debug)trace("BackgroundColor::setBlueChannel",md.velocity,_red,_green,_blue);
			_color 	= _red << 16 | _green << 8 | _blue;
			drawBackground();	
		}
		
		public function showMidiLearnButtons(flag:Boolean):void
		{
			_midiLearnButtons.visible 	= flag;
			_state 						= flag ? CONFIG_VISIBLE : CONFIG_HIDDEN;	
			_popup.visible				= flag;		
		}
		
		public function get state():String
		{
			return _state;
		}
		
	}
}
