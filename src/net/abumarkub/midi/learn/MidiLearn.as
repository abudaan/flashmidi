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
	import flash.text.StyleSheet;
	import net.abumarkub.core.data.DataEvent;
	import net.abumarkub.midi.MidiCommand;
	import net.abumarkub.midi.MidiData;

	/**
	 * @author abudaan
	 */
	public class MidiLearn extends Sprite
	{
		private var _index:uint;
		private var _debug:Boolean = false;
		private var _assignments:Object;
		private var _lastData1:int;
		private var _lastCommand:int;
		private var _currentAssignment:MidiLearnAssignment;
		private var _popup:MidiLearnPopup;
		
		public function MidiLearn(css:StyleSheet)
		{
			_assignments 		= new Object();
			_currentAssignment	= null;
			_index				= 0;
			_popup				= new MidiLearnPopup(css,230);
			_popup.addEventListener(MidiLearnEvent.ASSIGN_CONTROLLER,handleEvent);
			_popup.addEventListener(MidiLearnEvent.REMOVE_CONTROLLER,handleEvent);
			addChild(_popup);
		}

		public function update(md:MidiData):void
		{
			_lastData1 			= md.noteNumber;
			_lastCommand 		= md.command;
			_popup.update(md);

			var assignment:MidiLearnAssignment;
			var closure:Function;
			for each(assignment in _assignments)
			{
				if(_debug)trace("[MidiLearn::update]",assignment.description);
				if(assignment.controller == _lastCommand)
				{
					closure 	= assignment.closure;
					if(_lastCommand == MidiCommand.NOTE_ON 
					|| _lastCommand == MidiCommand.NOTE_OFF
					|| _lastCommand == MidiCommand.PROGRAM_CHANGE
					|| _lastCommand == MidiCommand.CONTROL_CHANGE)	
					{
						if(_lastData1 == assignment.data1) closure(md);						
					}
					else
					{
						closure(md);
					}
				}
			}
		}
		
		public function openPopup(e:DataEvent):void
		{
			_currentAssignment 		= e.data["assignment"];			
			var isAssigned:Boolean	= _assignments[_currentAssignment.id] != undefined;
			_popup.show(e.data["position"],isAssigned);
		}

		public function assignController(assignment:MidiLearnAssignment):void
		{
			var id:String 				= "assignment" + _index++;
			assignment.controller		= assignment.controller == -1 ? _lastCommand : assignment.controller;
						
			if(_lastCommand == MidiCommand.NOTE_ON 
			|| _lastCommand == MidiCommand.NOTE_OFF
			|| _lastCommand == MidiCommand.PROGRAM_CHANGE
			|| _lastCommand == MidiCommand.CONTROL_CHANGE)
			{
				assignment.data1		= _lastData1;
			}
			assignment.id				= id;
			_assignments[id] 			= assignment;
			if(_debug)trace("[MidiLearn::assignController]",id,assignment.description,assignment.controller,_lastCommand);
		}
		
		public function removeController(assignment:MidiLearnAssignment):void
		{
			delete _assignments[assignment.id];
		}

		private function handleEvent(event:Event):void 
		{
			switch(event.type)
			{
				case MidiLearnEvent.ASSIGN_CONTROLLER:
					if(_currentAssignment == null){break;}
					assignController(_currentAssignment);
					break;

				case MidiLearnEvent.REMOVE_CONTROLLER:
					removeController(_currentAssignment);
					break;				
			}
		}
	}
}
