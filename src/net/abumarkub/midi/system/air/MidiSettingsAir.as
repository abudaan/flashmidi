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
package net.abumarkub.midi.system.air
{
	import net.abumarkub.midi.system.IMidiSettings;
	import net.abumarkub.midi.system.event.MidiSettingsEvent;

	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	/**
	 * @author abudaan
	 * 
	 * MidiSettings stores and retrieves the default midi in and midi out device
	 * The air version store these settings in a file called midi.cfg
	 * 
	 */
	public class MidiSettingsAir extends EventDispatcher implements IMidiSettings
	{
		private var _midiInDeviceName:String	= "";
		private var _midiOutDeviceName:String 	= "";
		private var _configFile:File;
		private var _fileStream:FileStream;

		public function MidiSettingsAir()
		{
			_configFile					= new File(File.applicationDirectory.nativePath + "/midi.cfg");
		}
		
		public function readConfig():void
		{
			_fileStream					= new FileStream();		
			_fileStream.addEventListener(IOErrorEvent.IO_ERROR, onFileReadError);
			_fileStream.addEventListener(Event.COMPLETE, handleReadEvent);
			_fileStream.openAsync(_configFile, FileMode.READ);
		}

		public function writeConfig(inDeviceName:String,outDeviceName:String):void
		{
			_fileStream					= new FileStream();		
			_fileStream.addEventListener(IOErrorEvent.IO_ERROR, onFileReadError);
			_fileStream.open(_configFile, FileMode.WRITE);
			
			_midiInDeviceName 			= inDeviceName;
			_midiOutDeviceName 			= outDeviceName;			
			_fileStream.writeMultiByte(inDeviceName + "," + outDeviceName,"utf-8");
			_fileStream.close();
			dispatchEvent(new MidiSettingsEvent(MidiSettingsEvent.CONFIG_FILE_WRITTEN));			
		}
		
		private function onFileReadError(event:IOError):void 
		{
			event;
			dispatchEvent(new MidiSettingsEvent(MidiSettingsEvent.COULD_NOT_READ_CONFIG_FILE));
		}

		private function handleReadEvent(event:Event):void 
		{
    		var s:String 				= _fileStream.readMultiByte(_fileStream.bytesAvailable, "utf-8");		
			var a:Array 				= s.split(",");
			_midiInDeviceName 			= a[0];
			_midiOutDeviceName 			= a[1];
			//trace(_midiInDevice,_midiOutDevice);				
			_fileStream.close();
			dispatchEvent(new MidiSettingsEvent(MidiSettingsEvent.CONFIG_FILE_READ));
		}
				
		public function get midiInDeviceName():String
		{
			return _midiInDeviceName;
		}
		
		public function get midiOutDeviceName():String
		{
			return _midiOutDeviceName;
		}
		
		public function set midiInDeviceName(value:String):void
		{
			_midiInDeviceName 	= value; 
		}

		public function set midiOutDeviceName(value:String):void
		{
			_midiOutDeviceName 	= value; 
		}			
	}
}
