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
package net.abumarkub.midi
{
	import fl.controls.ComboBox;

	import net.abumarkub.core.liveconnection.LiveConnection;
	import net.abumarkub.core.liveconnection.LiveConnectionData;
	import net.abumarkub.core.liveconnection.LiveConnectionEvent;
	import net.abumarkub.core.ui.button.ButtonEvent;
	import net.abumarkub.core.ui.button.LabelButton;
	import net.abumarkub.core.ui.textfield.CssTextField;
	import net.abumarkub.midi.harmony.Note;
	import net.abumarkub.synth.Fluidsynth;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author abudaan
	 * 
	 * The MidiConfig handles all communication forth and back to the midi applet: 
	 * - you can rescan for new hardware. 
	 * - you can select a midi in and a midi out device and save these devices as the default devices
	 * - you can send midi events that are generated in as3 to the applet
	 * - all midi events from the applet arrive via the LiveConnection and are processed here
	 * 
	 */
	public class MidiConfig extends Sprite 
	{
		public static const COLLAPSED:String 	= "COLLAPSED";
		public static const EXPANDED:String 	= "EXPANDED";
		public static const FLUIDSYNTH_ID:uint 	= 99;
		
		private static var _instance:MidiConfig = null;

		private var _comboInputs:ComboBox;
		private var _comboOutputs:ComboBox;
		private var _currMidiInDeviceId:int		= -1;
		private var _currMidiOutDeviceId:int 	= -1;
		private var _currXmlConfig:XML;
		private var _output:CssTextField;
		private var _btnSave:LabelButton;
		private var _btnRestart:LabelButton;
		private var _btnRefresh:LabelButton;
		private var _btnClear:LabelButton;
		private var _inputDevices:Vector.<MidiDeviceDVO>;
		private var _outputDevices:Vector.<MidiDeviceDVO>;
		private var _midiSettings:MidiSettings 	= null;
		private var _buttonPadding:Number		= 38;
		private var _state:String;
		private var _liveConnection:LiveConnection;
		private var _fluidsynth:Fluidsynth;
		private var _useInternalSynth:Boolean	= false;
		private var _firstRun:Boolean 			= true;
		/*
		 * if the midi service runs for the first time _firstRun is set to true
		 * which means that the service sets the midi in- and outport according to the configfile (shared object)
		 *
		 * if _firstRun is false, the midi service does not change the midi in- and outport after
		 * the devices are rescanned
		 */

		public function MidiConfig(config:XML,css:StyleSheet)
		{									
			graphics.lineStyle(.1,0xbbbbbb);
			graphics.beginFill(0xeeeeee,1);
			graphics.drawRect(0, 0, 555, 270);
			graphics.endFill();	

			var label:CssTextField;
			
			label			 		= new CssTextField(css,"label",100,20,true,TextFieldAutoSize.NONE,true,false);
			label.cssText 			= "midi in:";
			label.x					= 20;
			label.y					= 5;
			addChild(label);
			
			_comboInputs 			= new ComboBox();
			_comboInputs.x 			= 20;
			_comboInputs.y 			= 25;
			_comboInputs.width		= 250;
			_comboInputs.height		= 22;
			_comboInputs.addEventListener(Event.CHANGE, handleComboboxEvent);
			addChild(_comboInputs);

			label			 		= new CssTextField(css,"label",100,20,true,TextFieldAutoSize.NONE,true,false);
			label.cssText			= "midi out:";
			label.x					= _comboInputs.x + _comboInputs.width + 20;
			label.y					= 5;
			addChild(label);

			_comboOutputs 			= new ComboBox();
			_comboOutputs.x 		= _comboInputs.x + _comboInputs.width + 20 + 1;
			_comboOutputs.y 		= 25;
			_comboOutputs.width		= 250;
			_comboOutputs.height	= 22;
			_comboOutputs.addEventListener(Event.CHANGE, handleComboboxEvent);
			addChild(_comboOutputs);
			
			label			 		= new CssTextField(css,"label",250,20,true,TextFieldAutoSize.NONE,true,false);
			label.cssText			= "event log:";
			label.x					= 20;
			label.y					= _comboOutputs.y + _comboOutputs.height + 10;
			addChild(label);

			_output					= new CssTextField(css,"log",520,150,true,TextFieldAutoSize.NONE,true,false);
			_output.background		= true;
			_output.backgroundColor	= 0x222222;
			_output.border			= true;
			_output.selectable		= true;
			_output.x				= 20;
			_output.y				= _comboOutputs.y + _comboOutputs.height + 30;
			_output.cssText 		= "";
			addChild(_output);
			
					
			_btnRestart				= new LabelButton("service","start service",css,"button",10,20,false,TextFieldAutoSize.LEFT,false,false);
			_btnRestart.x			= 20;
			_btnRestart.y			= _output.y + _output.height + 11;
			_btnRestart.addEventListener(ButtonEvent.DOWN, handleButtonEvent);
//			addChild(_btnRestart);

			_btnRefresh				= new LabelButton("rescan devices","rescan devices",css,"button",10,20,false,TextFieldAutoSize.LEFT,false,false);
			_btnRefresh.x			= 20;//_btnRestart.x + _btnRestart.width + _buttonPadding;
			_btnRefresh.y			= _output.y + _output.height + 11;
			_btnRefresh.addEventListener(ButtonEvent.DOWN, handleButtonEvent);
			addChild(_btnRefresh);

			_btnSave				= new LabelButton("save settings","save settings",css,"button",10,20,false,TextFieldAutoSize.LEFT,false,false);
			_btnSave.x				= _btnRefresh.x + _btnRefresh.width + _buttonPadding;
			_btnSave.y				= _output.y + _output.height + 11;
			_btnSave.addEventListener(ButtonEvent.DOWN, handleButtonEvent);
			addChild(_btnSave);			

			_btnClear				= new LabelButton("clear","clear event log",css,"button",10,20,false,TextFieldAutoSize.LEFT,false,false);
			_btnClear.x				= _btnSave.x + _btnSave.width + _buttonPadding;
			_btnClear.y				= _output.y + _output.height + 11;
			_btnClear.addEventListener(ButtonEvent.DOWN, handleButtonEvent);
			addChild(_btnClear);			

			_fluidsynth				= new Fluidsynth(config.samples);	
			_fluidsynth.addEventListener(Fluidsynth.SAMPLES_LOADED,handleSynthEvent);		
		}

		public static function getInstance(config:XML,css:StyleSheet):MidiConfig
		{
			if(_instance == null)
			{
				_instance = new MidiConfig(config,css);
			}
			return _instance;
		}
		
		/*
		 * Method init checks if a midi settings config file is present
		 * After the config file is read, the midi service is started in the event handler
		 * Also when a config file could be read or found, the midi service is started in the event handler
		 */
		public function init(initExpanded:Boolean = false):void
		{	
			initExpanded ? show() : hide();

			if(_midiSettings == null)
			{
				_midiSettings		= new MidiSettings();
				_midiSettings.addEventListener(MidiSettingsEvent.COULD_NOT_READ_CONFIG_FILE,handleMidiSettingsEvent);	
				_midiSettings.addEventListener(MidiSettingsEvent.CONFIG_FILE_READ,handleMidiSettingsEvent);	
				_midiSettings.addEventListener(MidiSettingsEvent.CONFIG_FILE_WRITTEN,handleMidiSettingsEvent);	
				_midiSettings.readConfig();
				return;
			}			
			startConnection();
		}
		
		private function startConnection():void
		{
			_liveConnection 		= new LiveConnection("executeASMethod", "talkToJava");
			_liveConnection.addEventListener(LiveConnectionEvent.LIVECONNECTION,handleLiveConnectionEvent);
			_liveConnection.init();		
		}

		private function initComboBoxes():void
		{
			_inputDevices			= new Vector.<MidiDeviceDVO>();
			_outputDevices			= new Vector.<MidiDeviceDVO>();
			
			var index:int;
			var xml:XML;
			var device:MidiDeviceDVO;
			var inputs:XMLList 		= _currXmlConfig.device.(@type == "input");
			var outputs:XMLList 	= _currXmlConfig.device.(@type=="output");
			var synths:XMLList  	= _currXmlConfig.device.(@type=="synth");	
			var output:String 		= "[in] midi configuration:\n";
			
			index					= 0;
			_comboInputs.removeAll();
			_comboInputs.addItem({data:-1,label:"no input"});
			for each(xml in inputs)
			{
				device				= new MidiDeviceDVO(++index,xml.@id,xml.name.text());
				output 			   += "input " + device.id + " " + device.name + "\n";
				_comboInputs.addItem({data:device.id,label:device.name});												
				_inputDevices.push(device);
			}

			index					= 0;
			_comboOutputs.removeAll();
			_comboOutputs.addItem({data:-1, label:"no output"});
			if(_fluidsynth.ready)
			{
				device 				= new MidiDeviceDVO(++index, FLUIDSYNTH_ID, "Fluidsynth (internal)");
				output 			   += "output " + device.id + " " + device.name + "\n";
				_comboOutputs.addItem({data:device.id,label:device.name});			
				_outputDevices.push(device);
			}
			for each(xml in outputs)
			{
				device				= new MidiDeviceDVO(++index,xml.@id,xml.name.text());
				output 			   += "output " + device.id + " " + device.name + "\n";
				_comboOutputs.addItem({data:device.id,label:device.name});	
				_outputDevices.push(device);
			}
			for each(xml in synths)
			{
				device				= new MidiDeviceDVO(++index,xml.@id,xml.name.text());
				output 			   += "output " + device.id + " " + device.name + "\n";
				_comboOutputs.addItem({data:device.id,label:device.name});			
				_outputDevices.push(device);
			}
			
			writeOutput(output.substring(0,output.length - 2));
			
			
			//set default devices
			
			var id:int;
			var deviceDVO:MidiDeviceDVO;			

			deviceDVO = _firstRun ? getMidiInDeviceByName(_midiSettings.midiInDeviceName) : getMidiInDeviceById(_currMidiInDeviceId);
			id										= deviceDVO.id;
			if(id != _currMidiInDeviceId)
			{
				writeOutput("[out] " + MidiLiveConnectionMethods.SET_MIDI_IN + " " + id);
				_liveConnection.call(MidiLiveConnectionMethods.SET_MIDI_IN,new String(id));
			}
			else
			{
				_comboInputs.selectedIndex 			= deviceDVO.index;
			}
			
	
			if(_midiSettings.midiOutDeviceName != null && _midiSettings.midiOutDeviceName.indexOf("Fluidsynth") != -1 && !_fluidsynth.ready)
			{
				writeOutput("[warning] your default midi out device Fluidsynth is not yet loaded");
			}

			deviceDVO = _firstRun ? getMidiOutDeviceByName(_midiSettings.midiOutDeviceName) : getMidiOutDeviceById(_currMidiOutDeviceId);
			id										= deviceDVO.id;
			if(id != _currMidiOutDeviceId)
			{
				_useInternalSynth = id == FLUIDSYNTH_ID;
				id = _useInternalSynth ? -1 : id;
				writeOutput("[out] " + MidiLiveConnectionMethods.SET_MIDI_OUT + " " + id);
				_liveConnection.call(MidiLiveConnectionMethods.SET_MIDI_OUT,new String(id));
			}
			else
			{
				_comboOutputs.selectedIndex 		= deviceDVO.index;
			}
			_firstRun 								= false;
		}
		

		/**
		 * listen to the Applet thru Javascript
		 */
		private function handleLiveConnectionEvent(event:LiveConnectionEvent):void
		{
			var data:LiveConnectionData = _liveConnection.data;

			switch(event.state)
			{
				case LiveConnectionEvent.ERROR:
				case LiveConnectionEvent.SECURITY_ERROR:
					writeOutput("[error] " + data.value);
					break;
				
				case LiveConnectionEvent.READY:
					writeOutput("[msg] LiveConnection established");
					_liveConnection.call(MidiLiveConnectionMethods.MIDI_CONFIG_DATA);
					break;
				
				case LiveConnectionEvent.DATA:
					handleMidiData(data);				
					break;
			}
		}
		
		/**
		 * parse the messages that came from the Applet
		 */
		private function handleMidiData(data:LiveConnectionData):void
		{
			var xml:XML					= XML(data.value);
			var md:MidiData 			= new MidiData(xml.@command,xml.@status,xml.@channel,xml.@data1,xml.@data2);
			
			switch(data.method)
			{
				case MidiLiveConnectionMethods.MIDI_CONFIG_DATA:
					_currXmlConfig 		= xml.copy();
					initComboBoxes();
					break;
				
				case MidiLiveConnectionMethods.SET_MIDI_IN:
					_currMidiInDeviceId = xml.midi_in;
					_comboInputs.selectedIndex = getMidiInDeviceById(_currMidiInDeviceId).index;
					writeOutput("[in] inport set to " + _currMidiInDeviceId);
					break;
				
				case MidiLiveConnectionMethods.SET_MIDI_OUT:
					_currMidiOutDeviceId = _useInternalSynth ? FLUIDSYNTH_ID : xml.midi_out;
					_comboOutputs.selectedIndex = getMidiOutDeviceById(_currMidiOutDeviceId).index;
					writeOutput("[in] outport set to " + _currMidiOutDeviceId);
					break;
				
				case MidiLiveConnectionMethods.MIDI_DATA:
					writeOutput("[in] " + md.toString());
					if(_useInternalSynth)
					{
						_fluidsynth.handleMidiData(md);
					}
					//dispatchEvent(new MidiEvent(MidiCommand.getDescription(md.command),md));
					dispatchEvent(new MidiEvent(MidiEvent.ALL_EVENTS, md));
					break;
			}
		}
		
		private function handleMidiSettingsEvent(event:MidiSettingsEvent):void
		{
			//trace(event);
			switch(event.type)
			{
				case MidiSettingsEvent.COULD_NOT_READ_CONFIG_FILE:
					startConnection();
					break;
			
				case MidiSettingsEvent.COULD_NOT_WRITE_CONFIG_FILE:
					//shit happens
					writeOutput("[error] Could not read the midi settings config file");
					break;
			
				case MidiSettingsEvent.CONFIG_FILE_READ:
					startConnection();
					break;

				case MidiSettingsEvent.CONFIG_FILE_WRITTEN:
					//ok, cool!
					writeOutput("[msg] Midi settings successfully written to config file");
					break;
			
			}
		}
		
		private function handleButtonEvent(event:ButtonEvent):void 
		{
			var btn:LabelButton = event.target as LabelButton;
			switch(btn.label)
			{
				case "stop service":
					break;

				case "start service":
					break;

				case "rescan devices":
					writeOutput("[out] " + MidiLiveConnectionMethods.MIDI_CONFIG_DATA);
					_liveConnection.call(MidiLiveConnectionMethods.MIDI_CONFIG_DATA);
					break;

				case "save settings":
					_midiSettings.writeConfig(getMidiInDeviceById(_currMidiInDeviceId).name, getMidiOutDeviceById(_currMidiOutDeviceId).name);
					break;

				case "clear event log":
					_output.cssText 	= "";
					break;
			}
		}

		private function handleComboboxEvent(event:Event):void
		{
			var port:int = event.target.selectedItem.data;
			//trace("handleComboboxEvent",port);
			
			switch(true)
			{
				case event.target == _comboInputs:
					writeOutput("[out] " + MidiLiveConnectionMethods.SET_MIDI_IN + " " + port);
					_liveConnection.call(MidiLiveConnectionMethods.SET_MIDI_IN,new String(port));
					break;
				case event.target == _comboOutputs:
					_useInternalSynth = port == FLUIDSYNTH_ID;
					port = _useInternalSynth ? -1 : port;
					writeOutput("[out] " + MidiLiveConnectionMethods.SET_MIDI_OUT + " " + port);
					_liveConnection.call(MidiLiveConnectionMethods.SET_MIDI_OUT,new String(port));
					break;
			}
		}
		
		/*
		 * samples are loaded in to Fluidsynth, add this output to the dropdownbox by calling initComboBoxes again
		 */
		private function handleSynthEvent(event:Event):void
		{
			event;
			_firstRun = _midiSettings.midiOutDeviceName != null && _midiSettings.midiOutDeviceName.indexOf("Fluidsynth") != -1 && _currMidiOutDeviceId == -1;
			if(_firstRun)
			{
				writeOutput("[msg] Fluidsynth is loaded, it will be set as your output device");
			}
			initComboBoxes();
		}

		/*
		 * send a midi event that has been generated in actionscript to the applet
		 */
		public function sendMidiData(data:MidiData):void
		{
			//trace(_currMidiOutDeviceId ,(_currMidiOutDeviceId == FLUIDSYNTH_ID));
			if(_currMidiOutDeviceId == FLUIDSYNTH_ID)
			{
				writeOutput("[internal] " + data.command + "," + data.channel + "," + data.data1 + "," + data.data2 + " (" + Note.getName(data.data1, Note.FLAT) + ")");
				_fluidsynth.handleMidiData(data);				
			}
			else
			{
				writeOutput("[out] " + MidiLiveConnectionMethods.MIDI_DATA_OUT + " " + data.command + "," + data.channel + "," + data.data1 + "," + data.data2 + " (" + Note.getName(data.data1, Note.FLAT) + ")");
				_liveConnection.call(MidiLiveConnectionMethods.MIDI_DATA_OUT,new String(data.command + "," + data.channel + "," + data.data1 + "," + data.data2));				
			}
		}
		
		public function show():void
		{
			//_liveConnection.call(MidiLiveConnectionMethods.MIDI_CONFIG_DATA);			
			_state 					= EXPANDED;	
			visible 				= true;
		}
		
		public function hide():void
		{
			_state 					= COLLAPSED;	
			visible 				= false;
		}	
						
		public function get state():String
		{
			return _state;
		}
		
		
		//utility functions
		
		private function getMidiInDeviceByName(name:String):MidiDeviceDVO
		{
			for each(var d:MidiDeviceDVO in _inputDevices)
			{
				//trace("INPUT:",name,"-----",d.name,(d.name == name));
				if(d.name == name)
				{
					return d;				
				}
			}
			return new MidiDeviceDVO();
		}

		private function getMidiOutDeviceByName(name:String):MidiDeviceDVO
		{
			for each(var d:MidiDeviceDVO in _outputDevices)
			{
				//trace("OUTPUT:",name,"-----",d.name,(d.name == name));
				if(d.name == name)
				{
					return d;				
				}
			}			
			return new MidiDeviceDVO();
		}

		private function getMidiInDeviceById(id:int):MidiDeviceDVO
		{
			for each(var d:MidiDeviceDVO in _inputDevices)
			{
				//trace("INPUT:",id,"-----",d.id,(d.id == id));
				if(d.id == id)
				{
					return d;				
				}
			}
			return new MidiDeviceDVO();
		}

		private function getMidiOutDeviceById(id:int):MidiDeviceDVO
		{
			for each(var d:MidiDeviceDVO in _outputDevices)
			{
				//trace("OUTPUT:",id,"-----",d.id,(d.id == id));
				if(d.id == id)
				{
					return d;				
				}
			}			
			return new MidiDeviceDVO();
		}
				
		private function writeOutput(msg:String):void
		{
			if(!visible)
			{
				return;
			}
			msg = msg.replace(/\</g,"&lt;");
			msg = msg.replace(/\>/g,"&gt;");
			//msg = msg.replace(/\n/g,"");
			//msg = msg.replace(/\r/g,"");
			msg = msg.replace(/([[])([a-z]+)(])/,"<span class='prefix'>$1$2$3</span>");
			_output.appendText(msg + "\n");
			_output.scrollV		= _output.maxScrollV;					
		}
	}
}
