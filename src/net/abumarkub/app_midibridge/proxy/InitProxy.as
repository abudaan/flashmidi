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
 
package net.abumarkub.app_midibridge.proxy
{
	import net.abumarkub.core.data.AssetLoader;
	import net.abumarkub.core.data.LoadTask;
	import net.abumarkub.core.proxy.Proxy;

	import flash.text.StyleSheet;

	/**
	 * @author abudaan
	 */
	public class InitProxy extends Proxy 
	{
		private static const LOAD_XML:String = "LOAD_XML";
		private static const LOAD_CSS:String = "LOAD_CSS";
		
		private static var _instance:InitProxy;

		private var _css:StyleSheet;
		private var _configData:XML;

		public function InitProxy(path:String,cache:String=Proxy.ALLOW_CACHE,block:Boolean=false,bubbleIOError:Boolean=true,bubbleSecError:Boolean=true)
		{
			super(path,cache,block,bubbleIOError,bubbleSecError);
			_id = "init";
		}
		
		public static function getInstance(path:String,cache:String=Proxy.ALLOW_CACHE,block:Boolean=false,bubbleIOError:Boolean=true,bubbleSecError:Boolean=true):InitProxy
		{
			if(_instance == null)
			{
				_instance = new InitProxy(path,cache,block,bubbleIOError,bubbleSecError);		
			}
			return _instance;
		}

		override public function init(... args):void
		{	
			var configUrl:String 	= _serverpath + args[0] + _cache;
			var cssUrl:String		= _serverpath + args[1] + _cache;
									
			_assetLoader.addLoadTask(new LoadTask(LOAD_XML,configUrl, AssetLoader.XML,configDataLoaded));	
			_assetLoader.addLoadTask(new LoadTask(LOAD_CSS,cssUrl, AssetLoader.TEXT, cssLoaded));

			_numTasks				= 2;

			_assetLoader.startQueue();			
		}
		
		private function configDataLoaded(data:Object,taskId:String):void
		{
			taskId;
			_configData				= XML(data);
		}

		private function cssLoaded(data:String,taskId:String):void
		{
			taskId;
			_css = new StyleSheet();			
			_css.parseCSS(data);
		}
		
		public function get css():StyleSheet
		{
			return _css;
		}		

		public function get configData():XML
		{
			return _configData;
		}		
	}
}
