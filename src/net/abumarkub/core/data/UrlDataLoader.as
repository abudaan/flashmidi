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
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;	

	/**
	 * @author abudaan
	 */
	public class UrlDataLoader extends EventDispatcher 
	{
		public static const VARIABLES:String 			= "VARIABLES";
		public static const BINARY:String 				= "BINARY";
		public static const TEXT:String 				= "TEXT";
		public static const XML:String 					= "XML";
		public static const WAV:String 					= "WAV";
		
		private static var _instance:UrlDataLoader;
		
		private var _urlLoader:URLLoader;
		private var _dataFormat:String;
		private var _callback:Function;
		private var _callbackArgs:Array;
		private var _checkTotalBytes:Boolean;

		public function UrlDataLoader()
		{
			_urlLoader = new URLLoader();
			_callback  = null;
			enableListeners(true);
		}

		public static function getInstance():UrlDataLoader
		{
			if(_instance == null)
			{
				_instance = new UrlDataLoader();
			}
			return _instance;
		}

		public function cleanUp():void
		{
			enableListeners(false);
		}

		public function loadVariables(url:String,data:URLVariables = null, callback:Function=null):void
		{
			_callback 	= callback;
			//trace(" -> " + _callback);
			//trace(" data: " + data.toString());
			//trace(" url: " + url);
			
			var request:URLRequest 		= new URLRequest(url);
			request.method				= URLRequestMethod.POST;
			request.data 				= data;
			_dataFormat 				= VARIABLES;		
			_urlLoader.load(request);			
		}
		
		public function loadText(url:String,callback:Function=null):void
		{
			_callback 	= callback;
			//trace(" -> " + _callback);
			
			var request:URLRequest 	= new URLRequest(url);
			_dataFormat 			= TEXT;
			_urlLoader.load(request);
			
		}

		public function loadXML(url:String,callback:Function=null):void
		{
			_callback 	= callback;
			//trace(" -> " + _callback);
			
			var request:URLRequest 	= new URLRequest(url);
			_dataFormat 			= XML;
			_urlLoader.load(request);
			
		}
		
		public function loadSWF(url:String,callback:Function=null):void
		{
			_callback 	= callback;
			//trace(" -> " + _callback);
			
			var request:URLRequest 	= new URLRequest(url);
			_dataFormat 			= BINARY;
			_urlLoader.load(request);
			
		}

		public function loadImage(url:String,callback:Function=null):void
		{
			_callback 	= callback;
			//trace(" -> " + _callback);
			
			var request:URLRequest 	= new URLRequest(url);
			_dataFormat 			= BINARY;
			_urlLoader.load(request);
			
		}

		public function loadWAV(url:String,callback:Function=null,args:Array=null):void
		{
			_callback 		= callback;
			_callbackArgs 	= args; 
			//trace(" -> " + _callback + " : " + url);
			
			var request:URLRequest 	= new URLRequest(url);
			_dataFormat 			= WAV;
			_urlLoader.dataFormat 	= URLLoaderDataFormat.BINARY;
			_urlLoader.load(request);
			
		}
		
		private function completeHandler(e:Event):void 
		{
            var loader:URLLoader = URLLoader(e.target);
            //trace("completeHandler: " + loader.data);
    		//trace(_dataFormat);
    		if(_dataFormat == VARIABLES)
    		{
	   			trace("hier:" + loader.data);
            	var vars:URLVariables;
            	try
            	{
            		vars = new URLVariables(loader.data);
            	}
            	catch(e:Error)
            	{
            		vars = new URLVariables("msg=Er is iets misgegaan, refresh de pagina en probeer het nog een keer.");
            	}
            	_callback(vars);
            	return;
    		}
    		else if(_dataFormat == WAV)
    		{
				//var a:Array = WavFormat.decode(loader.data).samples;
				//trace(_callback);
				_callback(loader.data, _callbackArgs);
				//trace(loader.data);
            	return;
    		}
    		else if(_dataFormat == BINARY)
			{
				_callback(loader.data, _callbackArgs);
				//trace(loader.data);
            	return;
    		}
    		else if(_dataFormat == TEXT)
			{
				_callback(String(loader.data), _callbackArgs);
				//trace(loader.data);
            	return;
    		}
          	if(_callback != null)
            {
            	_callback(loader.data);
            }
            //enableListeners(false);
        }

        private function openHandler(event:Event):void 
        {
           // trace("openHandler: " + event);
		}

        private function progressHandler(event:ProgressEvent):void 
        {
            //trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);

           	if(_checkTotalBytes)
           	{
				_urlLoader.close();
				//trace(event.bytesTotal);
				_callback(event.bytesTotal);
				return;
           	}           

            dispatchEvent(event);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void 
        {
            //trace("securityErrorHandler: " + event);
            dispatchEvent(event);
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void 
        {
           //trace("httpStatusHandler: " + event);
        }

        private function ioErrorHandler(event:IOErrorEvent):void 
        {
           	//trace("ioErrorHandler: " + event);
           	dispatchEvent(event);
        }
		
		
		private function enableListeners(b:Boolean):void
		{
			if(b)
			{
			    _urlLoader.addEventListener(Event.COMPLETE, completeHandler);
            	_urlLoader.addEventListener(Event.OPEN, openHandler);
            	_urlLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            	_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            	_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            	_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				return;
			}
		    _urlLoader.removeEventListener(Event.COMPLETE, completeHandler);
        	_urlLoader.removeEventListener(Event.OPEN, openHandler);
        	_urlLoader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
        	_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        	_urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        	_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		public function set checkTotalBytes(checkTotalBytes:Boolean):void
		{
			_checkTotalBytes = checkTotalBytes; 
		}
	}
}
