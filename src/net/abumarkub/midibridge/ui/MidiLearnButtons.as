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
package net.abumarkub.midibridge.ui 
{
	import net.abumarkub.core.data.DataEvent;
	import net.abumarkub.core.ui.button.ButtonEvent;
	import net.abumarkub.core.ui.button.LabelButton;
	import net.abumarkub.core.ui.textfield.CssTextField;
	import net.abumarkub.midi.MidiLearnAssignment;
	import net.abumarkub.midi.MidiLearnEvent;

	import flash.display.Sprite;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author abudaan
	 */
	public class MidiLearnButtons extends Sprite 
	{
		private var _assignments:Object;

		public function MidiLearnButtons(assignments:Object,css:StyleSheet)
		{
			_assignments 		= assignments;
			
			var label:CssTextField;		
			label			 	= new CssTextField(css,"label",480,10,true,TextFieldAutoSize.LEFT,false,false);
			label.cssText		= "Assign midi controllers to the color channels of the background by clicking on the channels below:";
			label.x				= 20;
			label.y				= 0;
			addChild(label);

			var btn:LabelButton;
			var ass:MidiLearnAssignment;
			var cssClass:String;
			var newX:Number 	= 100;
			var newY:Number 	= label.y + label.height + 4;
			for(var vars:String in _assignments)
			{
				cssClass 		= vars.indexOf("red") == 0 ? "button_red" : vars.indexOf("green") == 0 ? "button_green" : "button_blue";				
				ass				= _assignments[vars];
				btn 			= new LabelButton(vars,ass.description,css,cssClass,10,10,false,TextFieldAutoSize.LEFT,false,false);
				btn.x 			= newX; 
				btn.y 			= newY; 
				newX   	   	   += btn.width + 20;
				btn.addEventListener(ButtonEvent.DOWN,handleButtonEvent);
				addChild(btn);
			}
		}

		private function handleButtonEvent(e:ButtonEvent):void 
		{
			e.stopImmediatePropagation();
			//trace(e.target.x,e.target.y,e.position);
			dispatchEvent(new DataEvent(MidiLearnEvent.SHOW_MIDI_LEARN_POPUP,{assignment:_assignments[e.targetId],position:e.position}));
		}
	}
}
