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
	import net.abumarkub.midi.harmony.Note;

	/**
	 * @author abudaan
	 */
	public class MidiData 
	{
		
		public var channel:uint;
		public var command:uint;
		public var status:uint;
		public var noteNumber:uint;
		public var velocity:uint;
		public var data1:uint;//same as notenumber
		public var data2:uint;//same as velocity
		
		
		public function MidiData(command:uint = 0,status:uint = 0,channel:uint = 0,noteNumber:uint = 0,velocity:uint = 0)
		{
			this.command	= command;
			this.status		= status;
			this.channel	= channel;
			this.noteNumber	= this.data1 = noteNumber;//note number
			this.velocity	= this.data2 = velocity;//velocity
		}
		
		public function noteName(mode:String):String
		{
			return Note.getName(noteNumber, mode);
		}
		
		public function toString():String
		{
			if(command == MidiCommand.NOTE_ON || command == MidiCommand.NOTE_OFF)
			{
				return "note:" + noteName(Note.FLAT) + " channel:" + channel + " command:" + command + " status:" + status + " number:" + noteNumber + " velocity:" + velocity + "";
			}
			else
			{
				return "channel:" + channel + " command:" + command + " status:" + status + " data1:" + data1 + " data2:" + data2 + "";
			}
		}
	}
}
