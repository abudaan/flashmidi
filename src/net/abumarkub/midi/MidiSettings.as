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
package net.abumarkub.midi
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;

	/**
	 * @author abudaan
	 * 
	 * MidiSettings stores and retrieves the default midi in and midi out device
	 * 
	 */
	public class MidiSettings extends EventDispatcher
	{
		private var _config:SharedObject		= null;
		private var _midiInDeviceName:String 	= "";
		private var _midiOutDeviceName:String 	= "";

		public function MidiSettings()
		{
		}

		public function readConfig():void
		{
			_config 				= SharedObject.getLocal("midibridge.cfg");
			_midiInDeviceName		= _config.data.midiIn;
			_midiOutDeviceName  	= _config.data.midiOut;
			//trace("in:",_midiInDeviceName);
			//trace("out:",_midiOutDeviceName);
			dispatchEvent(new MidiSettingsEvent(MidiSettingsEvent.CONFIG_FILE_READ));
		}

		public function writeConfig(inDeviceName:String, outDeviceName:String):void
		{
			_midiInDeviceName 		= inDeviceName;
			_midiOutDeviceName 		= outDeviceName;
			
			_config 				= SharedObject.getLocal("midibridge.cfg");
			_config.data.midiIn 	= _midiInDeviceName;
			_config.data.midiOut 	= _midiOutDeviceName;
			dispatchEvent(new MidiSettingsEvent(MidiSettingsEvent.CONFIG_FILE_WRITTEN));

//			_config.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
//			_config.flush(200);
		}

		public function get midiInDeviceName():String
		{
			return _midiInDeviceName;
		}

		public function get midiOutDeviceName():String
		{
			return _midiOutDeviceName;
		}

		private function onFlushStatus(event:NetStatusEvent):void
		{
			switch(event.info.code)
			{
				case "SharedObject.Flush.Success":
					_config.data.midiIn 	= _midiInDeviceName;
					_config.data.midiOut 	= _midiOutDeviceName;
					dispatchEvent(new MidiSettingsEvent(MidiSettingsEvent.CONFIG_FILE_WRITTEN));
					break;
				
				case "SharedObject.Flush.Failed":
					dispatchEvent(new MidiSettingsEvent(MidiSettingsEvent.COULD_NOT_WRITE_CONFIG_FILE));
					break;
			}

			_config.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
		}
	}
}
