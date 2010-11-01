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
 
package net.abumarkub.core.ui.textfield 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;	

	/**
	 * @author abudaan
	 */
	public class CssInputTextField extends Sprite 
	{
		private var _tf:TextField;
		private var _width:Number;
		private var _height:Number;
		private var _bgAlpha:Number;
		private var _bgColor:Number;
		private var _bgOutline:Number;
		private var _bgErrorColor:Number;
		private var _hasError:Boolean;

		public function CssInputTextField(css:StyleSheet,cssClass:String,width:Number,height:Number,multiline:Boolean,bgColor:Number=-1,bgErrorColor:Number=-1,bgAlpha:Number=1,bgOutline:Number=-1,paddingH:Number=0,paddingV:Number=0)
		{
			_width					= width;
			_height					= height;
			_bgAlpha				= bgAlpha;
			_bgColor				= bgColor;
			_bgOutline				= bgOutline;
			_bgErrorColor			= bgErrorColor;
			
			drawBackground(_bgColor);
			
			var tfmt:TextFormat 	= new TextFormat();
			var style:Object		= css.getStyle("."+cssClass);
			tfmt.font				= style.fontFamily;
			tfmt.size				= parseInt(style.fontSize.substring(0,style.fontSize.length-2));
			tfmt.color				= style.color;
			tfmt.align				= style.textAlign;
			
			_tf						= new TextField();
			_tf.defaultTextFormat 	= tfmt;
			_tf.x					= paddingH;
			_tf.y					= paddingV;
			_tf.type 				= TextFieldType.INPUT;
			_tf.multiline 			= multiline;
			_tf.wordWrap			= multiline;
				
			_tf.width				= width - (2*paddingH);
			_tf.height				= height - (2*paddingV);
				
			//border				= true;
			_tf.embedFonts			= true;
			//_tf.addEventListener(Event.CHANGE,handleTextEvent);
			addChild(_tf);
		}
		
		private function handleTextEvent(event:Event):void
		{
			if(_hasError)
			{
				drawBackground(_bgColor);
			}
		}

		private function drawBackground(color:Number):void
		{
			graphics.clear();

			if(_bgOutline != -1)
			{
				graphics.lineStyle(1,_bgOutline);
			}
			if(_bgColor != -1)
			{
				graphics.beginFill(color,_bgAlpha);
				graphics.drawRect(0,0,_width,_height);
				graphics.endFill();
			}
		}

		public function set text(text:String):void
		{
			_tf.text = text;
		}

		public function get text():String
		{
			return _tf.text;
		}
		
		public function set error(b:Boolean):void
		{
			_hasError = b;
			drawBackground(b ? _bgErrorColor : _bgColor);	
			//trace("error:" + _bgErrorColor);		 
		}
	}
}
