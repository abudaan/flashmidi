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


package net.abumarkub.midi.system.web 
{
	import net.abumarkub.core.liveconnection.LiveConnection;
	import net.abumarkub.core.liveconnection.LiveConnectionData;
	import net.abumarkub.core.liveconnection.LiveConnectionEvent;
	import net.abumarkub.midi.MidiData;
	import net.abumarkub.midi.system.IMidiConnection;
	import net.abumarkub.midi.system.MidiConfig;
	import net.abumarkub.midi.system.MidiConnection;
	import net.abumarkub.midi.system.event.MidiConnectionEvent;

	/**
	 * @author abudaan
	 * 
	 * The is the web version of the MidiConnection. It sets up a LiveConnection to Javascript. LiveConnection is a handy wrapper class for ExternalInterface.
	 * All data that comes from the applet arrives here. Also commands to the applet are sent from here.
	 *
	 * Commands can be:
	 * - change the midi in and/or midi out device
	 * - start/stop the applet
	 * - send AS3 MidiEvents
	 * 
	 */
	public class MidiConnectionWeb extends MidiConnection implements IMidiConnection
	{
		private static var _instance:MidiConnectionWeb	= null;
		
		private var _liveConnection:LiveConnection;
		
		public function MidiConnectionWeb()
		{
			_liveConnection 		= new LiveConnection("executeASMethod", "talkToJava");
			_liveConnection.addEventListener(LiveConnectionEvent.LIVECONNECTION,handleLiveConnectionEvent);
		}

		public static function getInstance():MidiConnectionWeb
		{
			if(_instance == null)
			{
				_instance = new MidiConnectionWeb();
			}
			return _instance;
		}				
	
		/**
		 * listen for events from the hardware midi system
		 */
		private function handleLiveConnectionEvent(event:LiveConnectionEvent):void
		{
			var data:LiveConnectionData = _liveConnection.data;
			//trace(data.method,data.value);

			switch(event.state)
			{
				case LiveConnectionEvent.ERROR:
				case LiveConnectionEvent.SECURITY_ERROR:
					dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.ERROR, data.params));
					break;
				
				case LiveConnectionEvent.READY:
					dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.MESSAGE, "LiveConnection established"));
					_liveConnection.call(MidiConnection.GET_DEVICES);
					_running = true;
					break;
				
				case LiveConnectionEvent.DATA:
					//parsing is done in the super class MidiBridge
					parseData(data.params);
					break;
			}
		}
		
		/**
		 * sends midi events that are generated in AS3 to the hardware midi system
		 * @param data: the data to be sent to the hardware midi system 
		 * @see MidiData
		 */
		public function sendMidiData(data:MidiData):void
		{
			_liveConnection.call(MidiConnection.SEND_MIDI_DATA,new String(data.command + "," + data.channel + "," + data.data1 + "," + data.data2));				
//			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.COMMAND_SENT, MidiConnection.SEND_MIDI_DATA + " " + data.command + "," + data.channel + "," + data.data1 + "," + data.data2));				
			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.COMMAND_SENT, data.toString()));				
		}

		public function setInput(id:int):void
		{
			//trace("setInput:",id,_midiInDeviceId);
			if(_midiInDeviceId != id)
			{
				_liveConnection.call(MidiConnection.SET_MIDI_IN, new String(id));
				dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.COMMAND_SENT, MidiConnection.SET_MIDI_IN + " " + id));				
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
				_liveConnection.call(MidiConnection.SET_MIDI_OUT, new String(id));				
				dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.COMMAND_SENT, MidiConnection.SET_MIDI_OUT + " " + id));				
			}
		}

		public function getMidiConfig():void
		{
			if(!_running)
			{
				start();
				return;
			}
			//trace(_liveConnection.ready,MidiConnection.GET_DEVICES);
			_liveConnection.call(MidiConnection.GET_DEVICES);				
			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.COMMAND_SENT, MidiConnection.GET_DEVICES));				
		}
		
		public function start():void
		{
			if(!_liveConnection.ready)
			{
				_liveConnection.init();
				return;
			}
			_liveConnection.call(MidiConnection.START);						
			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.COMMAND_SENT, MidiConnection.START));				
			_running 	= true;				
		}

		public function stop():void
		{
			_liveConnection.call(MidiConnection.STOP);						
			dispatchEvent(new MidiConnectionEvent(MidiConnectionEvent.COMMAND_SENT, MidiConnection.STOP));
			_running 			= false;
			_midiInDeviceId 	= -1;
			_midiOutDeviceId 	= _midiOutDeviceId >= MidiConfig.INTERNAL_SYNTHS_START_ID ? _midiOutDeviceId : -1;				
		}
	}
}
