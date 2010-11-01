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


package net.abumarkub.midi 
{

	/**
	 * @author abudaan
	 */
	public class MidiCommand 
	{
		public static const NOTE_OFF:int  	 						= 0x80;//128
		public static const NOTE_ON:int   							= 0x90;//144
		public static const POLY_PRESSURE:int 						= 0xA0;//160
		public static const CONTROL_CHANGE:int   					= 0xB0;//176
		public static const PROGRAM_CHANGE:int   					= 0xC0;//192
		public static const CHANNEL_PRESSURE:int   					= 0xD0;//208
		public static const PITCH_BEND:int   						= 0xE0;//224
		public static const SYSTEM_EXCLUSIVE:int   					= 0xF0;//240


		public static const NOTE_OFF_VERBOSE:String  	 			= "NOTE OFF";
		public static const NOTE_ON_VERBOSE:String   				= "NOTE ON";
		public static const POLY_PRESSURE_VERBOSE:String 			= "POLY PRESSURE";
		public static const CONTROL_CHANGE_VERBOSE:String   		= "CONTROL CHANGE";
		public static const PROGRAM_CHANGE_VERBOSE:String   		= "PROGRAM CHANGE";
		public static const CHANNEL_PRESSURE_VERBOSE:String   		= "CHANNEL PRESSURE";
		public static const PITCH_BEND_VERBOSE:String   			= "PITCH BEND";
		public static const SYSTEM_EXCLUSIVE_VERBOSE:String   		= "SYSTEM EXCLUSIVE";
		
		private static const _commands:Array						= [NOTE_OFF,NOTE_ON,POLY_PRESSURE,CONTROL_CHANGE,PROGRAM_CHANGE,CHANNEL_PRESSURE,PITCH_BEND,SYSTEM_EXCLUSIVE];
		private static const _commandsVerbose:Array					= [NOTE_OFF_VERBOSE,NOTE_ON_VERBOSE,POLY_PRESSURE_VERBOSE,CONTROL_CHANGE_VERBOSE,PROGRAM_CHANGE_VERBOSE,CHANNEL_PRESSURE_VERBOSE,PITCH_BEND_VERBOSE,SYSTEM_EXCLUSIVE_VERBOSE];
		
		public static function getDescription(c:int):String
		{
			var descr:String;
			var hex:Number;
			for(var i:int = _commands.length; --i >= 0;)
			{
				hex = _commands[i];
				if((c & hex) == hex)
				{
					descr = _commandsVerbose[i];
					break;
				}
			}			
			return descr;
		}
	}
}
