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
 
package net.abumarkub.core.proxy
{
	import net.abumarkub.core.data.AssetLoader;
	import net.abumarkub.core.data.AssetLoaderEvent;
	import net.abumarkub.core.data.LoadTask;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;

	/**
	 * @author abudaan
	 */
	public class Proxy extends EventDispatcher 
	{
		public static const ALLOW_CACHE:String 		= "ALLOW_CACHE";
		public static const CLEAR_CACHE:String 		= "CLEAR_CACHE";

		protected var _serverpath:String;
		protected var _cache:String;
		protected var _assetLoader:AssetLoader;
		protected var _bytesToBeLoaded:Number;

		protected var _loadFactor:Number			= 1;
		protected var _loaded:Number 				= 0;
		protected var _totalLoaded:Number			= 0;
		protected var _loadCounter:int 				= 0;
		protected var _numTasks:uint				= 0;

		protected var _currBytesLoaded:Number		= 0;
		protected var _currBytesTotal:Number		= 0;
		protected var _bytesTotal:Number			= 0;
		protected var _taskLoaded:Number			= 0;
		protected var _taskCounter:uint				= 0;
		protected var _loadingMessage:String;
		protected var _id:String					= "proxy";

		
		public function Proxy(path:String,cache:String=Proxy.ALLOW_CACHE,block:Boolean=false,bubbleIOError:Boolean=true,bubbleSecError:Boolean=true)
		{
			_serverpath							= path;
			_cache								= cache == "" || cache == Proxy.ALLOW_CACHE ? "" : "?" + new Date().time;

			_assetLoader 						= new AssetLoader();
			_assetLoader.blockOnError 			= block;
			_assetLoader.bubbleIOError 			= bubbleIOError;
			_assetLoader.bubbleSecurityError 	= bubbleSecError;

			_assetLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
			_assetLoader.addEventListener(IOErrorEvent.IO_ERROR,onIOError);						
//			_assetLoader.addEventListener(ProgressEvent.PROGRESS, onTaskProgress);
			_assetLoader.addEventListener(ProgressEvent.PROGRESS, onTotalProgress);
			_assetLoader.addEventListener(AssetLoaderEvent.TASK_DONE,onTaskDone);
			_assetLoader.addEventListener(AssetLoaderEvent.ALL_TASKS_DONE, allTasksDone);
			_assetLoader.addEventListener(AssetLoaderEvent.TOTALBYTES_CALCULATED, onTotalBytesCalculated);
		}
		
		public function init(... args):void
		{	
		}
		
		public function addTask(task:LoadTask):void
		{
			_assetLoader.addLoadTask(task);			
		}

		public function addPriorityTask(task:LoadTask):void
		{
			_assetLoader.addPriorityLoadTask(task);
		}

		protected function onTaskDone(event:Event):void
		{
			dispatchEvent(new Event(AssetLoaderEvent.TASK_DONE));
		}

		protected function allTasksDone(event:Event):void
		{
			dispatchEvent(new Event(AssetLoaderEvent.ALL_TASKS_DONE));
		}

		protected function onTotalBytesCalculated(e:Event):void
		{
			_bytesToBeLoaded = _assetLoader.bytesTotal;
			_assetLoader.startQueue();
		}

		protected function onTaskProgress(e:ProgressEvent):void
		{
			_taskLoaded = Math.round((e.bytesLoaded/e.bytesTotal) * 100);
			//trace(_taskLoaded);
		}
		
		protected function onTotalProgress(e:ProgressEvent):void
		{
//			trace(_id,_totalLoaded,_loaded,_numTasks,e.bytesLoaded,e.bytesTotal);
			var p:Number = e.bytesTotal == 0 ? 0 : (e.bytesLoaded/e.bytesTotal);
			_totalLoaded = _loaded + (p * (1/_numTasks) * _loadFactor);

			if(e.bytesLoaded == e.bytesTotal && e.bytesTotal != 0)
			{
				_loadCounter++;
//				if(_loadCounter > _numTasks)
//				{
//					return;
//				}
				_loaded += (1/_numTasks) * _loadFactor;
//				trace("	------>",_assetLoader.currentTask.id);
				//trace("--->",_loadCounter,_loaded,"("+_id+"|"+_assetLoader.currentTask.id+")");
			}
			else
			{
				//trace("    ",_totalLoaded,e.bytesLoaded,e.bytesTotal,(e.bytesLoaded/e.bytesTotal));
			}
			
			//trace(_loadFactor,_loadCounter,_numTasks,_loaded,_totalLoaded);
			//trace(_loadCounter,((e.bytesLoaded/e.bytesTotal) * (1/_numTasks) * _loadFactor));
			//trace(_id,_totalLoaded);
			dispatchEvent(new Event(AssetLoaderEvent.LOAD_PROGRESS));
		}		

		public function get serverpath():String
		{
			return _serverpath;
		}
		
		public function get totalLoaded():Number
		{
			return _totalLoaded;
		}

		public function get taskLoaded():Number
		{
			return _taskLoaded;
		}
		
		public function get loadingMessage():String
		{
			return _loadingMessage;
		}
				
		protected function onSecurityError(event:SecurityErrorEvent):void
		{
			trace("[SECURITY ERROR]:" + event.text);
			if(!_assetLoader.blockOnError)dispatchEvent(new Event(AssetLoaderEvent.ALL_TASKS_DONE));
		}

		protected function onIOError(event:IOErrorEvent):void
		{
			trace("[IO ERROR]:" + event.text);
			if(!_assetLoader.blockOnError)dispatchEvent(new Event(AssetLoaderEvent.ALL_TASKS_DONE));
		}
	}
}
