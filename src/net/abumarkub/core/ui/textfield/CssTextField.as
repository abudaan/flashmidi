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
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author abudaan
	 */
	public class CssTextField extends TextField 
	{
		private var _text:String;
		private var _cssClass:String;
		
		public function CssTextField(css:StyleSheet,cssClass:String,width:Number,height:Number,multiline:Boolean,autoSize:String=TextFieldAutoSize.NONE,selectable:Boolean=false,embed:Boolean=true)
		{
			super();

			super.styleSheet	= css;
			super.multiline 	= multiline;
			super.wordWrap		= multiline;
				
			super.autoSize		= autoSize;
			super.width			= width;
			super.height		= height;
				
			_cssClass  			= cssClass;
						
			super.border		= false;
			super.embedFonts	= embed;
			super.mouseEnabled	= false;
			super.selectable	= selectable;
			super.antiAliasType	= AntiAliasType.ADVANCED;			
		}
		
		public function set cssText(text:String):void
		{
			_text 			= text;
			super.htmlText 	= "<span class='" + _cssClass + "'>" + text + "</span>";
		}

		override public function appendText(text:String):void
		{
			_text 		   += text;
			super.htmlText 	= "<span class='" + _cssClass + "'>" + _text + "</span>";
		}

		public function changeCssClass(cssClass:String,text:String=""):void
		{
			if(text != "")
			{
				_text = text;
			}
			super.htmlText 	= "<span class='" + cssClass + "'>" + _text + "</span>";
		}
		
		override public function set selectable(b:Boolean):void
		{
			super.selectable 	= b;
			super.mouseEnabled	= b;
		}	
	}
}
