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

	/**
	 * @author abudaan
	 */
	public class MidiLearnAssignment 
	{
		private var _id:String;
		private var _description:String;
		private var _controller:int;
		private var _data1:int;
		private var _closure:Function;
		
		public function MidiLearnAssignment(description:String,closure:Function,controller:int=-1)
		{
			_closure 		= closure;
			_description	= description;
			_controller		= controller;
		}

		public function set controller(value:int):void
		{
			_controller 	= value;
		}

		public function set data1(value:int):void
		{
			_data1	= value;
		}
		
		public function set id(value:String):void
		{
			_id	= value;
		}
		
		public function get controller():int
		{
			return _controller;
		}
		
		public function get data1():int
		{
			return _data1;
		}
		
		public function get id():String
		{
			return _id;
		}	
		
		public function get description():String
		{
			return _description;
		}	
		
		public function get closure():Function
		{
			return _closure;
		}	
	}
}
