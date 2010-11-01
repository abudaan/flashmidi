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

package net.abumarkub.midi 
{
	import flash.events.Event;

	/**
	 * @author abudaan
	 */
	public class MidiEvent extends Event 
	{
		/*
		 * for an int representation of these event see MidiCommand
		 * values below are equal to *_VERBOSE values in MidiCommand
		 */
		public static const ALL_EVENTS:String  	 			= "ALL_EVENTS";
		public static const NOTE_OFF:String  	 			= "NOTE OFF";
		public static const NOTE_ON:String   				= "NOTE ON";
		public static const POLY_PRESSURE:String 			= "POLY PRESSURE";
		public static const CONTROL_CHANGE:String   		= "CONTROL CHANGE";
		public static const PROGRAM_CHANGE:String   		= "PROGRAM CHANGE";
		public static const CHANNEL_PRESSURE:String   		= "CHANNEL PRESSURE";
		public static const PITCH_BEND:String   			= "PITCH BEND";
		public static const SYSTEM_EXCLUSIVE:String   		= "SYSTEM EXCLUSIVE";
		
		private var _midiData:MidiData;
		
		public function MidiEvent(type:String, data:MidiData, bubbles:Boolean = true) 
		{
			super(type, bubbles);
			_midiData = data;
		}
		
		public function get channel():uint
		{
			return _midiData.channel;
		}

		public function get command():uint
		{
			return _midiData.command;
		}

		public function get status():uint
		{
			return _midiData.status;
		}

		public function get noteNumber():uint
		{
			return _midiData.noteNumber;
		}

		public function noteName(mode:String):String
		{
			return _midiData.noteName(mode);
		}

		public function get velocity():uint
		{
			return _midiData.velocity;
		}

		public function get mididata():MidiData
		{
			return _midiData;
		}

	    public override function clone():Event
	    {
	        return new MidiEvent(type, _midiData);
		}  
	}
}
