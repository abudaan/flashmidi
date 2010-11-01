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
 

package net.abumarkub.core.liveconnection 
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;

	/**
	 * @author abudaan
	 */
	public class LiveConnection extends EventDispatcher
	{		
		private static var _instance:LiveConnection;
		
		private var _ready:Boolean;
		private var _data:LiveConnectionData;
		private var _methodIn:String;
		private var _methodOut:String;
		private var _readyTimer:Timer = new Timer(1, 1);

		public function LiveConnection(methodIn:String, methodOut:String)
		{
			super();
			_methodIn 	= methodIn;
			_methodOut 	= methodOut;
			//init();
		}
		
		public static function getInstance(methodIn:String, methodOut:String):LiveConnection
		{
			if(_instance == null)
			{
				_instance = new LiveConnection(methodIn, methodOut);
			}
			return _instance;
		}

		public function init(e:TimerEvent = null):void
		{	
            if(ExternalInterface.available) 
            {
            	try 
            	{
                    if(ExternalInterface.call("javaScriptReady"))
                    {
	                    ExternalInterface.addCallback(_methodIn, receivedFromJavaScript);

                    	_readyTimer.stop();
                    	_ready 	= true;
  						_data 	= new LiveConnectionData(LiveConnectionMethod.INIT,"ready");
						dispatchEvent(new LiveConnectionEvent(LiveConnectionEvent.READY));
 					}
                    else
                    {
                        _readyTimer = new Timer(100, 1);
                        _readyTimer.addEventListener(TimerEvent.TIMER, init);
                        _readyTimer.start();
                    }
                }
                catch(err1:SecurityError) 
                {
					_data = new LiveConnectionData(LiveConnectionMethod.INIT,err1.message);
                	dispatchEvent(new LiveConnectionEvent(LiveConnectionEvent.SECURITY_ERROR));
                } 
                catch(err2:Error) 
                {
					_data = new LiveConnectionData(LiveConnectionMethod.INIT,err2.message);
                	dispatchEvent(new LiveConnectionEvent(LiveConnectionEvent.ERROR));
                }
            }
            else 
            {
				_data = new LiveConnectionData(LiveConnectionMethod.INIT, "External interface is not available for this container.");
                dispatchEvent(new LiveConnectionEvent(LiveConnectionEvent.ERROR));
            }		
		}
		
		private function receivedFromJavaScript(method:String,value:String):void 
 		{
 			_data = new LiveConnectionData(method,value);
			dispatchEvent(new LiveConnectionEvent(LiveConnectionEvent.DATA));
        }
        
 		public function call(javaMethod:String, param:String=""):void
		{
			ExternalInterface.call(_methodOut, javaMethod, param);
		}
			
        public function get data():LiveConnectionData
        {
        	return _data;
        }  
        
        public function get ready():Boolean
        {
        	return _ready;
        }        		
	}	
}
