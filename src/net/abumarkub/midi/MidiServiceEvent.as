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
	
	public class MidiServiceEvent extends Event
	{
		public static const NATIVE_PROCESS_NOT_SUPPORTED:String = "handleNativeProcessNotSupportedError";
		public static const CONFIG_DATA_LOADED:String 			= "handleConfigData";
		public static const PROCESS_COULD_NOT_START:String 		= "handleProcessCouldNotStartError";
		public static const INPUT_ERROR:String 					= "handleInputError";
		public static const MIDI_IN_PORT_SET:String 			= "handleMidiInPortSet";
		public static const MIDI_OUT_PORT_SET:String 			= "handleMidiOutPortSet";
		public static const PROCESS_ENDED:String 				= "handleProcessEnded";
		public static const MIDI_DATA_OUT:String 				= "handleMidiDataOut";
		public static const ERROR:String 						= "handleMidiServiceError";
		public static const WARNING:String 						= "handleMidiServiceWarning";

		private var _message:String;
		
		public function MidiServiceEvent(type:String, message:String = "", bubbles:Boolean=true, cancelable:Boolean=false)
		{
			_message = message;
			super(type, bubbles, cancelable);
		}

		public override function clone():Event
		{
			return new MidiServiceEvent(type,_message);
		}
		
		public function get message():String
		{
			return _message;
		}		  
	}
}