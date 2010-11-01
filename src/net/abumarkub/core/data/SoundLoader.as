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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;	

	/**
	 * @author abudaan
	 */
	public class SoundLoader extends EventDispatcher 
	{
		private static var _instance:SoundLoader;

		private var _id:String;
		private var _sound:Sound;
		private var _callback:Function;

		private var _bubbleIOError:Boolean			= true;
		private var _bubbleSecurityError:Boolean	= true;

		public function SoundLoader()
		{
			_callback  = null;
		}

		public static function getInstance():SoundLoader
		{
			if(_instance == null)
			{
				_instance = new SoundLoader();
			}
			return _instance;
		}

		public function loadSound(url:String,callback:Function=null,context:SoundLoaderContext=null,id:String=""):void
		{
			_callback 	= callback;
			//trace(" -> " + _callback);
			
			_id								= id;
			_sound							= new Sound();
			
			enableListeners(_sound, true);
			var context:SoundLoaderContext 	= context == null ? new SoundLoaderContext() : context;
        	context.checkPolicyFile 		= true;

			_sound.load(new URLRequest(url), context);			
		}
		
		private function completeHandler(e:Event):void 
		{
            //var sound:Sound = e.target.loader as Sound;
			enableListeners(_sound, false);

            if(_callback != null)
            {
//            	_callback(sound);
            	_callback(_sound);
            }
        }

        private function openHandler(event:Event):void 
        {
            //trace("openHandler: " + event);
            dispatchEvent(event);
        }

        private function progressHandler(event:ProgressEvent):void 
        {
            //trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
            dispatchEvent(event);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void 
        {
            //trace("securityErrorHandler: " + event);
			if(_bubbleSecurityError)dispatchEvent(event);
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void 
        {
           trace("httpStatusHandler: " + event);
        }

        private function ioErrorHandler(event:IOErrorEvent):void 
        {
           	//trace("ioErrorHandler: " + event);
           	if(_bubbleIOError)dispatchEvent(event);
        }
		
		
		private function enableListeners(sound:Sound, b:Boolean):void
		{
			if(b)
			{
			    sound.addEventListener(Event.COMPLETE, completeHandler);
            	sound.addEventListener(Event.OPEN, openHandler);
            	sound.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            	sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            	sound.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            	sound.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				return;

			}
		    sound.removeEventListener(Event.COMPLETE, completeHandler);
        	sound.removeEventListener(Event.OPEN, openHandler);
        	sound.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
        	sound.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        	sound.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        	sound.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		public function get sound():Sound
		{
			return _sound;
		}

		public function get id():String
		{
			return _id;
		}
	}
}
