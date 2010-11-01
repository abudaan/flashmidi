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
 
package net.abumarkub.core.data 
{

	/**
	 * @author abudaan
	 */
	public class LoadTask 
	{
		private var _id:String;
		private var _url:String;
		private var _type:String;
		private var _callback:Function;
		private var _initMethod:Function;
		private var _callbackArgs:Array;
		private var _message:String;
		
		public function LoadTask(id:String,url:String,type:String,callback:Function=null,initMethod:Function=null,callbackArgs:Array=null,message:String="loading")
		{
			_id				= id;
			_url 			= url;
			_type 			= type;
			_callback 		= callback;
			_initMethod 	= initMethod;
			_callbackArgs 	= callbackArgs;
			_message 		= message;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get url():String
		{
			return _url;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get callback():Function
		{
			return _callback;
		}

		public function get initMethod():Function
		{
			return _initMethod;
		}

		public function get callbackArgs():Array
		{
			return _callbackArgs;
		}
		
		public function get message():String
		{
			return _message;
		}
	}
}
