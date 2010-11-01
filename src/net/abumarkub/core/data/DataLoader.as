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
	import flash.display.AVM1Movie;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;	

	/**
	 * @author abudaan
	 */
	public class DataLoader extends EventDispatcher 
	{
		private static var _instance:DataLoader;
		
		private var _loader:Loader;
		private var _type:String;
		private var _callback:Function;
		private var _initMethod:Function;
		private var _checkTotalBytes:Boolean;

		public function DataLoader()
		{
			_loader 	= new Loader();
			_callback  	= null;
			_initMethod = null;
			enableListeners(true);
		}

		public static function getInstance():DataLoader
		{
			if(_instance == null)
			{
				_instance = new DataLoader();
			}
			return _instance;
		}
		
		public function cleanUp():void
		{
			enableListeners(false);
		}
		
		public function load(url:String, callback:Function = null, initmethod:Function = null, type:String = ""):void
		{
			//trace("load:" + url,type);
			//trace("load:", type);
			
			_loader  					= new Loader();
			enableListeners(true);
			
			_type	  	= type;
			_callback 	= callback;
			_initMethod = initmethod;
			
			var context:LoaderContext 	= new LoaderContext();
        	context.applicationDomain 	= ApplicationDomain.currentDomain;
        	context.checkPolicyFile 	= true;
						
			_loader.load(new URLRequest(url),context);
			//_loader.load(new URLRequest(url));
		}

		private function completeHandler(e:Event):void 
		{
          	//var data:LoaderInfo = LoaderInfo(e.target);
          	//var data:DisplayObject = LoaderInfo(e.target).content;
            //var data:*;
	        //trace("completeHandler: " + e.target);

    		
    		switch(_type)
    		{
    			case AssetLoader.IMG:
    			case AssetLoader.JPG:
    			case AssetLoader.GIF:
    			case AssetLoader.PNG:
					if(!e.target.loader.contentLoaderInfo.childAllowsParent)
					{
						dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR,false,false,"contentLoaderInfo.childAllowsParent is false!"));
						return;
					}
					var bmd:BitmapData		= Bitmap(e.target.loader.content).bitmapData;
//					var tmpBmp:BitmapData 	= bmd.clone();
//					var bmp:Bitmap 			= new Bitmap(tmpBmp, PixelSnapping.AUTO, true);
					var bmp:Bitmap 			= new Bitmap(bmd, PixelSnapping.AUTO, true);
					//trace("bmp:" + bmp, " callback:" + _callback);
					_callback(bmp);
//					_callback(e.target["loader"]);
					return;
					break;
    			case AssetLoader.SWF:
//    				if(e.target.loader.content is AVM1Movie)
//    				{
//						_callback(e.target.loader);   
//						return; 									
//    				}
//    				//trace("SWF:" + e.target.loader.content);
//					_callback(e.target.loader.content);    				
					
					/**
					* just return the and let the callback determine what to do with AVM1Movies
					*/
					_callback(e.target.loader);    				
					return;
    				break;
			}
    		
            if(_callback != null)
            {
            	_callback(LoaderInfo(e.target));
            }
            //enableListeners(false);
        }

        private function openHandler(event:Event):void 
        {
            //trace("openHandler: " + event);            
        }

        private function initHandler(event:Event):void 
        {
            //trace("initHandler: " + event,_initMethod);
            if(_initMethod != null)
            {
            	//trace("initHandler: " + _initMethod);
 	           _initMethod(event.target.content);
            }
        }

        private function unloadHandler(event:Event):void 
        {
            //trace("unloadHandler: " + event);
        }

        private function progressHandler(event:ProgressEvent):void 
        {
            //trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
           	if(_checkTotalBytes)
           	{
				_loader.close();
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
           //trace("httpStatusHandler: " + event.status);
        }

        private function ioErrorHandler(event:IOErrorEvent):void 
        {
           	//trace("ioErrorHandler: " + event);
           	dispatchEvent(event);
        }
		
		
		private function enableListeners(b:Boolean):void
		{
			var dispatcher:LoaderInfo = _loader.contentLoaderInfo;
			
			if(b)
			{
			    dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            	dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            	dispatcher.addEventListener(Event.INIT, initHandler);
            	dispatcher.addEventListener(Event.OPEN, openHandler);
            	dispatcher.addEventListener(Event.UNLOAD, unloadHandler);
            	dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            	dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            	dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				return;
			}
		    dispatcher.removeEventListener(Event.COMPLETE, completeHandler);
        	dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(Event.INIT, initHandler);
        	dispatcher.removeEventListener(Event.OPEN, openHandler);
        	dispatcher.addEventListener(Event.UNLOAD, unloadHandler);
        	dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        	dispatcher.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
        	dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		}

		public function set checkTotalBytes(checkTotalBytes:Boolean):void
		{
			_checkTotalBytes = checkTotalBytes; 
		}
	}
}
