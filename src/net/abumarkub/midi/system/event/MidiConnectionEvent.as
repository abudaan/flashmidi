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
 
 package net.abumarkub.midi.system.event
{
	import flash.events.Event;
	
	public class MidiConnectionEvent extends Event
	{	
		//incoming events from applet or service
		public static const MIDI_CONNECTION_STARTED:String		= "midi-connection-started";
		public static const MIDI_CONNECTION_STOPPED:String		= "midi-connection-stopped";
		public static const MIDI_IN_CHANGED:String				= "midi-in";
		public static const MIDI_OUT_CHANGED:String				= "midi-out";
		public static const MIDI_DATA_RECEIVED:String			= "midi-data";
		public static const CONFIG:String						= "config";
		public static const ERROR:String						= "error";
		public static const WARNING:String						= "warning";
		public static const MESSAGE:String						= "message";
		
		//outgoing command, used to update the log of the MidiConfigUI whenever an instruction is send to the applet or the service
		public static const COMMAND_SENT:String					= "command-sent";

		private var _message:String;
		
		public function MidiConnectionEvent(type:String, message:String = "", bubbles:Boolean=true, cancelable:Boolean=false)
		{
			_message = message;
			super(type, bubbles, cancelable);
		}

		public override function clone():Event
		{
			return new MidiConnectionEvent(type,_message);
		}
		
		public function get message():String
		{
			return _message;
		}		  
	}
}