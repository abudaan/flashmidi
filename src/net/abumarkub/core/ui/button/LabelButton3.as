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

package net.abumarkub.core.ui.button 
{
	import net.abumarkub.core.ui.button.BasicButton;
	import net.abumarkub.core.ui.textfield.CssTextField;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;	

	/**
	 * @author abudaan
	 */
	public class LabelButton3 extends BasicButton 
	{
		private var _cssClass:String;
		private var _labelTf:CssTextField;
		private var _label:String;

		public function LabelButton3(id:String, label:String, css:StyleSheet, cssClass:String, width:Number, height:Number, multiline:Boolean = false, autoSize:String=TextFieldAutoSize.LEFT, selectable:Boolean=false,embedFonts:Boolean=true)
		{
			_label				= label;
			_cssClass 			= cssClass;
			_labelTf 			= new CssTextField(css, cssClass, width, height, multiline,autoSize,selectable,embedFonts);
			_labelTf.cssText 	= label;
			
			var bg:Sprite		= new Sprite();
			bg.graphics.beginFill(0xff0000,0);
			bg.graphics.drawRect(0,0,_labelTf.width,_labelTf.height);
			bg.graphics.endFill(); 
			bg.addChild(_labelTf);
					
			super(bg,id,true,false);
		}

		override public function handleOver(e:MouseEvent=null):void
		{
			_labelTf.changeCssClass(_cssClass + "_over");
		}

		override public function handleOut(e:MouseEvent=null):void
		{
			_labelTf.changeCssClass(_cssClass);
		}
		
		public function get label():String
		{
			return _label;
		}
		
		override public function set selected(b:Boolean):void
		{
			super.selected 	= b;
			enabled 		= !b;
			if(b)handleOver(); 
			else handleOut(); 
		}
	}
}
