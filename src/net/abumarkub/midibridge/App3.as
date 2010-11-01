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

package net.abumarkub.midibridge 
{
	import net.abumarkub.core.data.AssetLoaderEvent;
	import net.abumarkub.core.data.DataEvent;
	import net.abumarkub.core.liveconnection.LiveConnection;
	import net.abumarkub.core.liveconnection.LiveConnectionData;
	import net.abumarkub.core.liveconnection.LiveConnectionEvent;
	import net.abumarkub.core.proxy.Proxy;
	import net.abumarkub.midi.MidiData;
	import net.abumarkub.midi.MidiLearn;
	import net.abumarkub.midi.MidiLearnAssignment;
	import net.abumarkub.midi.MidiLearnEvent;
	import net.abumarkub.midi.MidiLiveConnectionMethods;
	import net.abumarkub.midi.MidiSetup;
	import net.abumarkub.midibridge.proxy.InitProxy;
	import net.abumarkub.midibridge.ui.BackgroundColor;
	import net.abumarkub.midibridge.ui.BoxesAnimation;

	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author abudaan
	 */
	[SWF(backgroundColor="#ffffff", frameRate="31", width="1065", height="500")]

	public class App3 extends Sprite 
	{
		private var _liveConnection:LiveConnection;
		private var _debug:Boolean	= false;
		private var _midiSetup:MidiSetup;
		private var _midiLearn:MidiLearn;
		private var _boxesAnimation:BoxesAnimation;
		private var _backgroundColor:BackgroundColor;
		private var _initProxy:InitProxy;
		private var _cache:String 	= Proxy.ALLOW_CACHE;

		public function App3()
		{
			var path:String			= stage.loaderInfo.parameters["path"];
			path 					= path == null ? "../" : path;
			var conf:String			= stage.loaderInfo.parameters["conf"];
			conf 					= conf == null ? "xml/config.xml" : conf;
			var css:String			= stage.loaderInfo.parameters["css"];
			css 					= css == null ? "css/app.css" : css;
			//trace("conf:",conf,"css:",css,"path:",path);
			
			_initProxy				= InitProxy.getInstance(path,_cache);
			_initProxy.addEventListener(AssetLoaderEvent.ALL_TASKS_DONE,handleEvent);
			_initProxy.addEventListener(AssetLoaderEvent.LOAD_PROGRESS,handleEvent);
			_initProxy.init(conf,css);						
		}
		
		public function init():void
		{
			_liveConnection 		= new LiveConnection("executeASMethod", "talkToJava");
			_liveConnection.addEventListener(LiveConnectionEvent.LIVECONNECTION,handleLiveConnectionEvent);
			_liveConnection.init();
			
			_backgroundColor		= new BackgroundColor(1065, 500, 0x000000, _initProxy.css);
			_backgroundColor.addEventListener(MidiLearnEvent.SHOW_MIDI_LEARN_POPUP,handleDataEvent);
			addChild(_backgroundColor);
			
			_boxesAnimation			= new BoxesAnimation();
			addChild(_boxesAnimation);
			
			_midiSetup				= new MidiSetup(_initProxy.css);
			_midiSetup.addEventListener(MidiLiveConnectionMethods.SET_MIDI_IN,handleEvent);
			_midiSetup.addEventListener(MidiLiveConnectionMethods.SET_MIDI_OUT,handleEvent);
			addChild(_midiSetup);	
			
			_midiLearn				= new MidiLearn(_initProxy.css);	
			addChild(_midiLearn);
			
			//you can also assign midi controllers directly like so:
			var mla:MidiLearnAssignment	= new MidiLearnAssignment("red channel",_backgroundColor.setRedChannel,MidiCommands.PITCH_BEND);
			_midiLearn.assignController(mla);
			//and remove them again:
			_midiLearn.removeController(mla);
		}


		private function handleEvent(event:Event):void 
		{
			switch(event.type)
			{
				case AssetLoaderEvent.ALL_TASKS_DONE:
					init();
					break;

				case MidiLiveConnectionMethods.SET_MIDI_IN:
					_liveConnection.call(MidiLiveConnectionMethods.SET_MIDI_IN,new String(_midiSetup.midiIn));
					break;

				case MidiLiveConnectionMethods.SET_MIDI_OUT:
					_liveConnection.call(MidiLiveConnectionMethods.SET_MIDI_OUT,new String(_midiSetup.midiOut));
					break;
			}
		}

		private function handleDataEvent(event:DataEvent):void 
		{
			switch(event.type)
			{
				case MidiLearnEvent.SHOW_MIDI_LEARN_POPUP:
					_midiLearn.openPopup(event);
					break;
			}
		}

		/**
		 * listen to the Applet thru Javascript
		 */
		private function handleLiveConnectionEvent(event:LiveConnectionEvent):void
		{
			switch(event.state)
			{
				case LiveConnectionEvent.ERROR:
				case LiveConnectionEvent.SECURITY_ERROR:
					if(_debug)trace("[App] error at liveconnection:" + _liveConnection.data.value);
					break;
				case LiveConnectionEvent.READY:
					if(_debug)trace("[App] liveconnection ready");
					_liveConnection.call(MidiLiveConnectionMethods.MIDI_CONFIG_DATA);
					break;
				case LiveConnectionEvent.DATA:
					if(_debug)trace("[App] liveconnection data");
					handleMidiData();				
					break;
			}
		}
		
		private function handleMidiData():void
		{
			var data:LiveConnectionData = _liveConnection.data;
			var xml:XML					= XML(data.value);
			var md3:MidiData 			= new MidiData(xml);
			
			switch(data.method)
			{
				case MidiLiveConnectionMethods.MIDI_CONFIG_DATA:
					if(_debug)trace("[App] midi configuration recieved");
					_midiSetup.init(XML(xml));
					break;
				
				case MidiLiveConnectionMethods.SET_MIDI_IN:
					if(_debug)trace("[App] midi in connected");
					_midiSetup.update(xml);
					break;
				
				case MidiLiveConnectionMethods.SET_MIDI_OUT:
					if(_debug)trace("[App] midi out connected");
					_midiSetup.update(XML(data.value));
					break;
				
				case MidiLiveConnectionMethods.MIDI_DATA:
					if(_debug)trace("[App] midi data recieved");
					_boxesAnimation.update(md3);
					_midiLearn.update(md3);
					break;
			}
		}		
	}
}
