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
package net.abumarkub.midi.learn 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import net.abumarkub.core.ui.button.ButtonEvent;
	import net.abumarkub.core.ui.button.LabelButton;
	import net.abumarkub.core.ui.textfield.CssTextField;
	import net.abumarkub.midi.MidiCommand;
	import net.abumarkub.midi.MidiData;

	/**
	 * @author abudaan
	 */
	public class MidiLearnPopup extends Sprite 
	{
		private var _css:StyleSheet;
		private var _width:Number;
		private var _assigned:Boolean;
		private var _btnAssign:LabelButton;
		private var _btnUnassign:LabelButton;
		private var _btnCancel:LabelButton;
		private var _content:CssTextField;
		
		public function MidiLearnPopup(css:StyleSheet,w:Number)
		{
			_css			= css;
			_width			= w;
			visible 		= false;
						
			_content		= new CssTextField(css,"popup",_width - 10,10,true,TextFieldAutoSize.LEFT,false,false);
			_content.x		= 5;
			addChild(_content);
			
			_btnAssign 		= new LabelButton("assign","assign",css,"popup_button",10,10,false,TextFieldAutoSize.LEFT,false,false);
			_btnAssign.x	= 10; 
			_btnAssign.addEventListener(ButtonEvent.DOWN,handleButtonEvent);
			addChild(_btnAssign);

			_btnCancel 		= new LabelButton("cancel","cancel",css,"popup_button",10,10,false,TextFieldAutoSize.LEFT,false,false);
			_btnCancel.x	= _width - _btnCancel.width - 10; 			
			_btnCancel.addEventListener(ButtonEvent.DOWN,handleButtonEvent);
			addChild(_btnCancel);	

			_btnUnassign 	= new LabelButton("unassign","unassign",css,"popup_button",10,10,false,TextFieldAutoSize.LEFT,false,false);
			_btnUnassign.x	= (_btnAssign.x + _btnAssign.width) + ((_btnCancel.x - (_btnAssign.x + _btnAssign.width) - _btnUnassign.width)/2); 
			_btnUnassign.addEventListener(ButtonEvent.DOWN,handleButtonEvent);
			addChild(_btnUnassign);
		}
		
		private function layout():void
		{
			var h:Number	= _content.y + _content.height + 5;
			_btnAssign.y 	= _btnUnassign.y = _btnCancel.y = h;
			h   		   += _btnAssign.height + 5;
			
			graphics.clear();
			graphics.lineStyle(.1,0x000000);
			graphics.drawRect(0,0,_width,h);

			graphics.beginFill(0xFFFFE1);
			graphics.drawRect(0,0,_width,h);
			graphics.endFill();			

			filters 		= [new DropShadowFilter()];
		}

		public function show(position:Point,assigned:Boolean):void
		{
			this.x 					= position.x - _width/2;
			this.y 					= position.y;
			_assigned				= assigned;
			_btnUnassign.visible 	= _assigned;
			_content.cssText		= _assigned ? "Move the midi controller that you want to assign, or click 'unassign' to unassign the current controller" : "Move the midi controller that you want to assign";
			layout();
			visible 				= true;
			
			//@TODO check if popup fits on stage!
			//trace("[MidiLearnPopup::show]",this.getBounds(stage).right, stage.stageWidth);			
		}

		public function hide():void
		{
			visible = false;			
		}

		public function update(md:MidiData):void
		{
			if(!visible)
			{
				return;
			}
			var controller:String 	= MidiCommand.getDescription(md.command);
			controller			   += md.command == MidiCommand.NOTE_ON || md.command == MidiCommand.CONTROL_CHANGE || md.command == MidiCommand.PROGRAM_CHANGE ? " (#" + md.noteNumber + ")" : "";
			
			_content.cssText		= _assigned ? "Assign " + controller + "?<br />Click 'unassign' to unassign the current midi controller" :  "Assign " + controller + "?";
			layout();
		}

		private function handleButtonEvent(event:ButtonEvent):void 
		{
			switch(event.targetId)
			{
				case "cancel":
					hide();
					break;
				
				case "assign":
					hide();
					dispatchEvent(new Event(MidiLearnEvent.ASSIGN_CONTROLLER));
					break;

				case "unassign":
					hide();
					dispatchEvent(new Event(MidiLearnEvent.REMOVE_CONTROLLER));
					break;
			}
		}
	}
}
