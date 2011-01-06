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

package net.abumarkub.midi.system.air
{
	import net.abumarkub.midi.MidiData;
	import net.abumarkub.midi.system.IMidiConnection;
	import net.abumarkub.midi.system.MidiConfig;
	import net.abumarkub.midi.system.MidiConnection;
	import net.abumarkub.midi.system.event.MidiConnectionEvent;

	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.utils.Timer;

	/**
	 * @author abudaan
	 * 
	 * The is the air version of the MidiConnection. It start the commandline version of the midibridge as a NativeProcess. 
	 * All data that is sent to the standard out of the NativeProcess arrives here. 
	 * This class also sends commands to the standard input of the NativeProcess.
	 *
	 * Commands can be:
	 * - change the midi in and/or midi out device
	 * - start/stop the commandline service
	 * - send AS3 MidiEvents
	 * 
	 */
	public class MidiConnectionAir extends MidiConnection implements IMidiConnection
	{		
		private static var _instance:MidiConnectionAir 	= null;

		private var _midiService:NativeProcess;
		private var _startupInfo:NativeProcessStartupInfo;
		private var _keepAliveTimer:Timer;
		private var _checkIfRunningTimer:Timer;
				
		public function MidiConnectionAir()
		{
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, exit);

			/*
			 * the keepAliveTimer pings every 10 sec to the midiservice to keep it alive
			 * if the Air app crashes for whatever reason, the midiservice dies gracefully
			 */
			_keepAliveTimer 		= new Timer(9500);
			_keepAliveTimer.addEventListener(TimerEvent.TIMER, handleTimerEvent);
			
			/*
			 * the checkIfRunningTimer gets in action after the user has stopped the midiservice
			 * because it might take some time before the midiservice has actually stopped
			 */
			_checkIfRunningTimer 	= new Timer(20);
			_checkIfRunningTimer.addEventListener(TimerEvent.TIMER, handleTimerEvent);
		}

		public static function getInstance():MidiConnectionAir
		{
			if(_instance == null)
			{
				_instance = new MidiConnectionAir();
			}
			return _instance;
		}				
		
		public function start():void
		{
			if(!NativeProcess.isSupported)
			{
				//trace("MidiService::init() native process not supported");
				dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.ERROR, "Could not start midi service: native process not supported"));
			}
			else
			{
				_startupInfo 				= new NativeProcessStartupInfo();
				//_startupInfo.executable 	= new File(File.applicationDirectory.nativePath + "/midiservice.exe");
				//trace(Capabilities.os);
				var args:Vector.<String>	= new Vector.<String>();
				if(Capabilities.os.indexOf("Windows") != -1)
				{
					_startupInfo.executable 	= new File("C:/Windows/System32/cmd.exe");
					args[0]						= "/C";
					args[1]						= "java -jar";
					args[2]						= File.applicationDirectory.nativePath + "/midiservice.jar";
				}
				else
				{
					_startupInfo.executable 	= new File("/usr/bin/java");
					args[0]						= "-jar";
					args[1]						= File.applicationDirectory.nativePath + "/midiservice.jar";
				}
				_startupInfo.arguments		= args;					
				startService();
			}			
		}
		
		private function startService():void
		{	
			if(!_keepAliveTimer.running)
			{
				_keepAliveTimer.start();
			}			

			_midiService 					= new NativeProcess();				
			_midiService.addEventListener(Event.STANDARD_ERROR_CLOSE, onErrorClose);
			_midiService.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData); 
			_midiService.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onErrorIOError); 
			
			_midiService.addEventListener(Event.STANDARD_INPUT_CLOSE, onInputClose);
			_midiService.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onInputIOError);
			_midiService.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, onInputProgress);
			
			_midiService.addEventListener(Event.STANDARD_OUTPUT_CLOSE, onOutputClose);
			_midiService.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			_midiService.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onOutputIOError); 

			_midiService.addEventListener(NativeProcessExitEvent.EXIT, exitHandler); 
			_midiService.start(_startupInfo);
		}

		private function onErrorClose(event:Event):void
		{
			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.MESSAGE, event.type));
		}

		private function onErrorData(event:ProgressEvent):void
		{
			var s:String = _midiService.standardError.readUTFBytes(_midiService.standardError.bytesAvailable);
			if(s == ""){return;}
			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.ERROR, event.type + " " + s));
		}

		private function onErrorIOError(event:IOErrorEvent):void
		{
			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.ERROR, event.type));
		}

		private function onInputClose(event:Event):void
		{
			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.MESSAGE, event.type));
		}

		private function onInputIOError(event:IOErrorEvent):void
		{
			var s:String = _midiService.standardError.readUTFBytes(_midiService.standardError.bytesAvailable);
			if(s == ""){return;}
			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.ERROR, event.type + " " + s));
		}

		private function onOutputClose(event:Event):void
		{
			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.MESSAGE, event.type));
		}

		private function onOutputIOError(event:IOErrorEvent):void
		{
			var s:String = _midiService.standardError.readUTFBytes(_midiService.standardError.bytesAvailable);
			if(s == ""){return;}
			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.ERROR, event.type + " " + s));
		}

		private function exitHandler(event:NativeProcessExitEvent):void
		{
			_checkIfRunningTimer.stop();
			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.MIDI_CONNECTION_STOPPED, "process exit 0"));
		}

		private function onInputProgress(e:ProgressEvent):void
		{
			//trace(e);
		}
		
		private function onOutputData(e:ProgressEvent):void
		{
			var s:String = _midiService.standardOutput.readUTFBytes(_midiService.standardOutput.bytesAvailable);
			//parsing is done in the super class MidiBridge
			parseData(s);
		}
		
		private function handleTimerEvent(event:TimerEvent):void 
		{			
			switch(event.target)
			{
				case _keepAliveTimer:
					//trace("aliveTimer:",_midiService.running);
					if(!_midiService.running)
					{
						return;
					}
					//_midiService.standardInput.writeMultiByte(KEEP_ALIVE + "\n", "utf-8");
					input(KEEP_ALIVE);	
					break;
				
				case _checkIfRunningTimer:
					//trace("runningTimer:",_midiService.running);
					if(!_midiService.running)
					{
						_checkIfRunningTimer.stop();
						dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.MIDI_CONNECTION_STOPPED, "process exit 1"));
						break;	
					}
					break;
			}
		}
		
		private function reset():void
		{
			_midiInDeviceId  		= -1;
			_midiOutDeviceId 		= _midiOutDeviceId >= MidiConfig.INTERNAL_SYNTHS_START_ID ? _midiOutDeviceId : -1;				
			_configData  			= null;
		}
		
		/*
		 * inputs arguments to the process
		 */
		private function input(args:String):void
		{
			if(args.indexOf(SEND_MIDI_DATA) != 0)
			{
				dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.COMMAND_SENT, args));
			}
			if(!_midiService.running)
			{
				return;
			}
//			_midiService.standardInput.writeMultiByte(args, "utf-8");
			_midiService.standardInput.writeUTFBytes(args + "\n");
		}
				
		/**
		 * sends midi events that are generated in AS3 to the hardware midi system
		 * @param data: the data to be sent to the hardware midi system 
		 * @see MidiData
		 */
		public function sendMidiData(data:MidiData):void
		{
			input(SEND_MIDI_DATA + " " + data.command + "," + data.channel + "," + data.noteNumber + "," + data.velocity);
			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.COMMAND_SENT, data.toString()));
		}
		
		public function getMidiConfig():void
		{
			//trace(_midiService,_midiService.running);
			if(_midiService == null)
			{
				return;
			}
			
			if(!_midiService.running)
			{
				startService();	
			}
			input(GET_DEVICES);				
		}
		
		public function disconnect():void
		{
			reset();
			
			if(_midiService == null || !_midiService.running)
			{
				return;
			}
			input(SET_MIDI_IN_OUT + " -1,-1");				
		}
		
		public function stop():void
		{
			_keepAliveTimer.stop();
			reset();

			if(!_midiService.running)
			{
				return;
			}
			_checkIfRunningTimer.start();
			input(STOP);				
		}
		
		private function exit(event:Event = null):void
		{
			_keepAliveTimer.stop();
			reset();

			if(_midiService == null || !_midiService.running)
			{
				return;
			}
			input(STOP);				
		}

		public function setInput(id:int):void
		{
			if(_midiInDeviceId != id)
			{
				input(SET_MIDI_IN + " " + id);
			}
		}
		
		public function setOutput(id:int):void
		{
			/**
			 * If the connection is not running, you are still able to choose one of the internal synths and play them with your virtual keyboard
			 * Also, you should be able to disconnect your internal synth (id = -1)
			 */
			if(!_running && (id >= MidiConfig.INTERNAL_SYNTHS_START_ID || (id == -1 && _midiOutDeviceId != -1)))
			{
				_midiOutDeviceId = id;
				dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.MIDI_OUT_CHANGED));	
				return;
			}
			
			/**
			 * If the connection is running, just pas the new output device id to the hardware midi system
			 */
			if(_midiOutDeviceId != id)
			{
				input(SET_MIDI_OUT + " " + id);
			}
		}
						
		override public function get running():Boolean
		{
			return _midiService.running;
		}		
	}
}