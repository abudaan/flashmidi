package net.abumarkub.midi.system
{
	import fl.controls.ComboBox;

	import net.abumarkub.core.ui.button.ButtonEvent;
	import net.abumarkub.core.ui.button.LabelButton;
	import net.abumarkub.core.ui.textfield.CssTextField;
	import net.abumarkub.midi.system.event.MidiSystemEvent;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author abudaan
	 * 
	 * This is the default MidiConfigUI that will be used if you do not pass an instance of IMidiConfigUI in the construnctor of MidiSystem
	 * You can use this class for your own UI or create a new UI from scratch. Your custom UI must implement IMidiConfig
	 * 
	 * @see IMidiConfig
	 * 
	 */
	public class MidiConfigUI extends Sprite implements IMidiConfigUI
	{
		/**max number of characters in the output window, the number of characters has to be restricted because of performance concerns*/
		public static const MAX_OUTPUT_BUFFER:uint = 3000;

		private var _comboInputs:ComboBox;
		private var _comboOutputs:ComboBox;
		private var _output:CssTextField;
		private var _outputBuffer:String			= "<span class='log'>";
		private var _btnSave:LabelButton;
		private var _btnRestart:LabelButton;
		private var _btnRefresh:LabelButton;
		private var _btnClear:LabelButton;
		private var _buttonPadding:Number			= 38;
		private var _midiInDevice:MidiDeviceDVO;
		private var _midiOutDevice:MidiDeviceDVO;
		private var _midiDevices:MidiDevices;

		public function MidiConfigUI(css:StyleSheet = null)
		{
			if(css == null)
			{
				css = new StyleSheet();
				css.parseCSS(".button {  font-family: _sans;  font-size: 13px;  color: #0000bb;  text-align: left;  text-decoration: underline; }  .button_over {  font-family: _sans;  font-size: 13px;  color: #00aff0;  text-align: left;  text-decoration: underline; }  .label {  font-family: _sans;  font-size: 13px;  color: #333333;  text-align: left; }  .log{  font-family: Courier,_sans;  font-size: 10px;  color: #ffffff;  text-align: left; }  .prefix {  font-family: Courier,_sans;  font-size: 10px;  color: #54ff54;  text-align: left; }   .popup {  font-family: _sans;  font-size: 13px;  color: #222222;  text-align: left; }  .popup_button {  font-family: _sans;  font-size: 14px;  color: #0000ff;  text-align: left; }  .popup_button_over {  font-family: _sans;  font-size: 14px;  color: #19B7F1;  text-align: left; }  .button_red {  font-family: _sans;  font-size: 14px;  color: #ff0000;  text-align: left; }  .button_red_over {  font-family: _sans;  font-size: 14px;  color: #555555;  text-align: left; }  .button_green {  font-family: _sans;  font-size: 14px;  color: #00ff00;  text-align: left; }  .button_green_over {  font-family: _sans;  font-size: 14px;  color: #555555;  text-align: left; }  .button_blue {  font-family: _sans;  font-size: 14px;  color: #0000ff;  text-align: left; }  .button_blue_over {  font-family: _sans;  font-size: 14px;  color: #555555;  text-align: left; }");
			}

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
			//_comboOutputs.dropdown.setStyle("cellRenderer", MidiDevicesRenderer);
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
			
					
			_btnRestart				= new LabelButton("connection","start connection",css,"button",10,20,false,TextFieldAutoSize.LEFT,false,false);
			_btnRestart.x			= 20;
			_btnRestart.y			= _output.y + _output.height + 11;
			_btnRestart.addEventListener(ButtonEvent.DOWN, handleButtonEvent);
			addChild(_btnRestart);

			_btnRefresh				= new LabelButton("rescan devices","rescan devices",css,"button",10,20,false,TextFieldAutoSize.LEFT,false,false);
			_btnRefresh.x			= _btnRestart.x + _btnRestart.width + _buttonPadding;
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
			
			//_comboInputs.setStyle("cellRenderer",MidiDevicesRenderer);
			//_comboInputs.setStyle("cellRenderer",MidiDevicesRenderer);
		}
		
		public function updateDevices(devices:MidiDevices):void
		{
			_midiDevices		= devices;
			var i:uint;
			var device:MidiDeviceDVO;
										
			_comboInputs.removeAll();
			_comboInputs.addItem({data:-1, label:"no input"});
			for(i = 0; i < _midiDevices.inports.length; i++)
			{
				device = _midiDevices.inports[i];
				if(device.available)
				{
					_comboInputs.addItem({data:device.id, label:device.name, enabled:device.available});
				}
			}

			_comboOutputs.removeAll();
			_comboOutputs.addItem({data:-1, label:"no output"});
			for(i = 0; i < _midiDevices.outports.length; i++)
			{
				device				= _midiDevices.outports[i];
				if(device.available)
				{
					_comboOutputs.addItem({data:device.id, label:device.name, enabled:device.available});	
				}
			}

			if(_midiDevices.empty)
			{
				_btnRestart.label 		= "start connection";
				_comboInputs.enabled 	= false;
				//_comboOutputs.enabled = false;
			}
			else
			{
				_btnRestart.label 		= "stop connection";
				_comboInputs.enabled 	= true;
				_comboOutputs.enabled 	= true;
				writeLog(_midiDevices.toString());
			}
		}
 
		private function handleComboboxEvent(event:Event):void
		{
			var id:int = event.target.selectedItem.data;
			
			switch(true)
			{
				case event.target == _comboInputs:
					// trace("in",id);
					_midiInDevice = _midiDevices.getMidiInDeviceById(id);
					dispatchEvent(new MidiSystemEvent(MidiSystemEvent.SET_MIDI_IN, _midiInDevice, _midiOutDevice));
					break;
				case event.target == _comboOutputs:
					//trace("out",id);
					_midiOutDevice		= _midiDevices.getMidiOutDeviceById(id);
					dispatchEvent(new MidiSystemEvent(MidiSystemEvent.SET_MIDI_OUT, _midiInDevice, _midiOutDevice));
					break;
			}
		}

		private function handleButtonEvent(event:ButtonEvent):void 
		{
			var btn:LabelButton = event.target as LabelButton;
			switch(btn.label)
			{
				case "stop connection":
					// _output.text 	= "";
					dispatchEvent(new MidiSystemEvent(MidiSystemEvent.STOP_SERVICE));
					break;

				case "start connection":
					// _output.text 	= "";
					dispatchEvent(new MidiSystemEvent(MidiSystemEvent.START_SERVICE));
					break;

				case "rescan devices":
					//_output.text 	= "";
					dispatchEvent(new MidiSystemEvent(MidiSystemEvent.GET_CONFIG));
					break;

				case "save settings":
					dispatchEvent(new MidiSystemEvent(MidiSystemEvent.WRITE_CONFIG, _midiInDevice, _midiOutDevice));
					break;

				case "clear event log":
					_output.cssText 	= "";
					break;
			}
		}
		
		public function show():void
		{
			visible = true;
		}
		
		public function hide():void
		{
			visible = false;
		}
		
 		public function setMidiIn(port:int):void
 		{
			_midiInDevice		= _midiDevices.getMidiInDeviceById(port);
			writeLog("[in] midi in set to " + _midiInDevice.id);
			_comboInputs.selectedIndex = _midiInDevice.index; 			
 		}

 		public function setMidiOut(port:int):void
 		{
			_midiOutDevice		= _midiDevices.getMidiOutDeviceById(port);
			writeLog("[in] midi out set to " + _midiOutDevice.id);
			_comboOutputs.selectedIndex = _midiOutDevice.index; 			
 		}

		public function writeLog(msg:String):void
		{
			_outputBuffer += msg.replace(/([[])([a-z]+)(])/,"<span class='prefix'>$1$2$3</span>") + "<br/>";

			if(_outputBuffer.length > MAX_OUTPUT_BUFFER)
			{
				_outputBuffer		= _outputBuffer.substring(_outputBuffer.length - MAX_OUTPUT_BUFFER);
				_outputBuffer		= _outputBuffer.substring(_outputBuffer.indexOf("span class")-1);
				if(_outputBuffer.indexOf("span class='log'") == -1)
				{
					_outputBuffer	= "<span class='log'>" + _outputBuffer;
				}
			}

			_output.htmlText 		= _outputBuffer + "</span>";
			_output.scrollV			= _output.maxScrollV;	
		}
	}
}
