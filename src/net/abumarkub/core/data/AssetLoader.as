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
	import net.abumarkub.core.data.LoadTask;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLVariables;	

	/**
	 * @author abudaan
	 */
	public class AssetLoader extends EventDispatcher 
	{
//Loader
		public static const SWF:String 		= "swf";
		public static const JPG:String 		= "jpg";
		public static const GIF:String 		= "gif";
		public static const PNG:String 		= "png";
		public static const IMG:String 		= "image";
//URLLoader		
		public static const WAV:String 		= "wav";
		public static const XML:String 		= "xml";
		public static const TEXT:String 	= "text";
		public static const IMG_BIN:String 	= "image binary";
		public static const VARS:String 	= "vars";
//SoundLoader	
		public static const MP3:String 		= "mp3";

		private static var _instance:AssetLoader;
		private var _isRunning:Boolean;

		private var _urlDataLoader:UrlDataLoader;
		private var _dataLoader:DataLoader;
		private var _soundLoader:SoundLoader;
		private var _tasks:Object;
		private var _tasksQueue:Array;
		private var _loadFunctions:Object;
		private var _checkBytesTotal:Boolean;
		private var _bytesTotal:Number = 0;
		private var _callback:Function;
		private var _currentTask:LoadTask;
		private var _currentTaskId:String;
//		private var _currentCallback:Function;
//		private var _currentCallbackArgs:Array;
		private var _currentLoadFunction:Function;
		private var _error:Event;
		private var _blockOnError:Boolean			= true;
		private var _bubbleIOError:Boolean			= true;
		private var _bubbleSecurityError:Boolean	= true;

		public function AssetLoader()
		{
			_dataLoader 			= new DataLoader();//DataLoader.getInstance();
			_urlDataLoader 			= new UrlDataLoader();//UrlDataLoader.getInstance();
			_soundLoader 			= new SoundLoader();//SoundLoader.getInstance();
			
			addListeners(true);			
			
			_tasks 					= new Object();
			_tasksQueue 			= new Array();
			_loadFunctions  		= new Object();
//Loader			
			_loadFunctions[SWF] 	= loadSWF;
			_loadFunctions[IMG] 	= loadImage;
			_loadFunctions[PNG] 	= loadImage;
			_loadFunctions[JPG] 	= loadImage;
			_loadFunctions[GIF] 	= loadImage;
//URLLoader			
			_loadFunctions[XML] 	= loadXML;
			_loadFunctions[TEXT] 	= loadText;
			_loadFunctions[WAV] 	= loadWAV;
			_loadFunctions[VARS] 	= loadVariables;
			_loadFunctions[IMG_BIN] = loadImageBinary;
//SoundLoader			
			_loadFunctions[MP3] 	= loadMp3;
		}
		
		private function addListeners(b:Boolean):void
		{
			var a:Array = [_dataLoader,_urlDataLoader,_soundLoader];
			var loader:Object;
			for(var i:uint = 0; i < a.length; i++)
			{
				loader = a[i];	
				if(b)
				{
					loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
					loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
					loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
				}
				else
				{
					loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
					loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
					loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
				}
			}
		}

		public function cleanUp():void
		{
			_dataLoader.cleanUp();
			_urlDataLoader.cleanUp();

			addListeners(false);
			_isRunning = false;			
			//_currentCallback = null;
		}

		private function onProgress(e:ProgressEvent):void
		{
 			//trace("progressHandler loaded:" + e.bytesLoaded + " total: " + e.bytesTotal);
 			dispatchEvent(e);
		}

		private function onIOError(e:IOErrorEvent):void
		{
			if(_bubbleIOError)dispatchEvent(e);
			if(!_blockOnError)nextTask();
 		}

		private function onSecurityError(e:SecurityErrorEvent):void
		{
			if(_bubbleSecurityError)dispatchEvent(e);
 			if(!_blockOnError)nextTask();
 		}

		public static function getInstance():AssetLoader
		{
			if(_instance == null)
			{
				_instance = new AssetLoader();
			}
			return _instance;
		}
		
		public function addLoadTask(task:LoadTask):void
		{
			_tasks[task.id] = task;
			_tasksQueue.push(task.id);
			//trace(_tasks.length);
			//trace(task.url,task.initMethod);
		}
		
		public function addPriorityLoadTask(task:LoadTask):void
		{
			_tasks[task.id] = task;
			_tasksQueue.unshift(task.id);
		}
		
		public function getTotalBytes():void
		{
			_bytesTotal						= 0;
			_checkBytesTotal 				= true;
			_dataLoader.checkTotalBytes 	= _checkBytesTotal;
			_urlDataLoader.checkTotalBytes 	= _checkBytesTotal;

			performTask();
		}

		public function startQueue():void
		{
			_isRunning 						= true;		
			_checkBytesTotal 				= false;
			_dataLoader.checkTotalBytes 	= _checkBytesTotal;
			_urlDataLoader.checkTotalBytes 	= _checkBytesTotal;
			
			performTask();
		}
		
		public function set onTasksDone(f:Function):void
		{
			_callback = f;
		}
		
		private function performTask():void
		{
			//trace(_tasksQueue);
			_currentTaskId 			= _tasksQueue.shift();
			_currentTask			= _tasks[_currentTaskId];
			//trace("loading:" + _currentTask.url + " type:" + _currentTask.type + " function:" + _loadFunctions[_currentTask.type] + " id:" + _currentTaskId);
			dispatchEvent(new Event(AssetLoaderEvent.NEXT_TASK));
			try
			{
				_currentLoadFunction 	= _loadFunctions[_currentTask.type];
			}
			catch(e:Error)
			{
				trace("loading:" + _currentTask.url + " type:" + _currentTask.type + " function:" + _loadFunctions[_currentTask.type] + " id:" + _currentTaskId);
			}
			_currentLoadFunction(_currentTask.url,generalCallback,_currentTask.initMethod,_currentTask.type);
		}

		private function generalCallback(data:* = null, args:Array = null):void
		{	
			args;
				
			if(_checkBytesTotal)
			{
				_bytesTotal   += data;
				if(_tasksQueue.length == 0)
				{
					dispatchEvent(new Event(AssetLoaderEvent.TOTALBYTES_CALCULATED));
					return;
				}
				performTask();
				return;
			}
			
			
			var currentCallback:Function 	= _currentTask.callback;
			var currentCallbackArgs:Array	= _currentTask.callbackArgs;
			
//			trace(currentCallback + ":" + currentCallbackArgs);
			
			if(currentCallback != null)
			{
				data != null ? currentCallbackArgs != null ? currentCallback(data,_currentTask.id,currentCallbackArgs) : currentCallback(data,_currentTask.id) 
				 			 : currentCallbackArgs != null ? currentCallback(_currentTask.id,currentCallbackArgs) 	  : currentCallback(_currentTask.id);
			}
			else
			{
				dispatchEvent(new Event(AssetLoaderEvent.TASK_DONE));
			}
			
			nextTask();
		}
		
		private function nextTask():void
		{
			/*
			trace("------------");
			for (var vars:String in _tasks) 
			{
				trace(vars + " : " + _tasks[vars]);
			}
			trace("+-+-+-+-+-+-+");
			*/
			
			//clean up
			delete _tasks[_currentTaskId];

			if(_tasksQueue.length == 0)
			{
				_isRunning = false;	
				if(_callback != null)
				{
					 _callback();
				}
				else
				{
					dispatchEvent(new Event(AssetLoaderEvent.ALL_TASKS_DONE));
				}
				return;
			}
			if(_tasks.length == 0)
			{
				return;
			}
			performTask();			
		}
		
//----- URL LOADER ----

//		public function loadText(url:String,callback:Function = null):void
		public function loadText(... args):void
		{
			_urlDataLoader.loadText(String(args[0]),args[1] as Function);
		}

//		public function loadXML(url:String,callback:Function = null):void
		public function loadXML(... args):void
		{
			_urlDataLoader.loadXML(String(args[0]),args[1] as Function);
		}

//		public function loadWAV(url:String,callback:Function=null,args:Array=null):void
		public function loadWAV(... args):void
		{
			//trace(_currentCallback);
			_urlDataLoader.loadWAV(String(args[0]),args[1] as Function,args[2] as Array);
		}

//		public function loadVariables(url:String,data:URLVariables = null, callback:Function = null):void//
		public function loadVariables(... args):void
		{
			_urlDataLoader.loadVariables(String(args[0]),args[1] as URLVariables,args[2] as Function);
		}

//----- SOUND LOADER ----

//		public function loadMp3(url:String,callback:Function = null):void
		public function loadMp3(... args):void
		{
			_soundLoader.loadSound(String(args[0]),args[1] as Function);
		}
		
//----- LOADER ----

//		public function loadSWF(url:String,callback:Function = null,initmethod:Function = null):void
		public function loadSWF(... args):void
		{
			_dataLoader.load(String(args[0]),args[1] as Function,args[2] as Function,String(args[3]));
			//_urlDataLoader.loadSWF(url,callback);
		}

//		public function loadImage(url:String,callback:Function = null, type:String = IMG):void
		public function loadImage(... args):void
		{
			_dataLoader.load(String(args[0]),args[1] as Function,null,String(args[3]));
		}

//		public function loadImageBinary(url:String,callback:Function = null, type:String = IMG):void
		public function loadImageBinary(... args):void
		{
			_urlDataLoader.loadImage(String(args[0]),args[1] as Function);
		}

		public function get bytesTotal():Number
		{
//			trace(_bytesTotal + ":" + 5312281);
			return _bytesTotal;
		}
		
		public function get numTasks():int
		{
			return _tasksQueue.length;
		}
		
		public function get currentTask():LoadTask
		{
			return _currentTask;
		}			
		
		public function get error():Event
		{
			return _error;
		}
		
		public function set blockOnError(value:Boolean):void
		{
			_blockOnError = value; 
		}	
		
		public function get blockOnError():Boolean
		{
			return _blockOnError;
		}
			

		public function set bubbleIOError(value:Boolean):void
		{
			_bubbleIOError = value; 
		}		

		public function set bubbleSecurityError(value:Boolean):void
		{
			_bubbleSecurityError = value; 
		}	
		
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
			

/*		
		public function load(url:String, type:String, callback:Function = null):void
		{
			switch(type)
			{
				case XML:
					_urlDataLoader.loadXML(url, callback);
					break;
				case SWF:
					_dataLoader.load(url, callback);
					break;
				case WAV:
					_urlDataLoader.loadWAV(url,callback);
					break;
			}
		}
*/		
	}
}
