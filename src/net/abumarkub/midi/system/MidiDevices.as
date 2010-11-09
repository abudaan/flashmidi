package net.abumarkub.midi.system
{
	/**
	 * @author abudaan
	 * 
	 * This class stores the current midi configuration, which means all midi devices of your hardware midi system that are currently available.
	 * The class provide some handy utility methods for retrieving midi devices by name and by id.
	 * 
	 */
	public class MidiDevices
	{
		private var _inputDevices:Vector.<MidiDeviceDVO>;
		private var _outputDevices:Vector.<MidiDeviceDVO>;
		private var _log:String;
		private var _empty:Boolean;

		public function MidiDevices(config:XML):void
		{
			_empty					= config.children().length() <= 1;
			_inputDevices			= new Vector.<MidiDeviceDVO>;
			_outputDevices			= new Vector.<MidiDeviceDVO>;
			
			var inputs:XMLList 		= config.device.(@type == "input");
			var outputs:XMLList 	= config.device.(@type == "output");
			var synths:XMLList  	= config.device.(@type == "synth");	

			var index:int;
			var xml:XML;
			var device:MidiDeviceDVO;
			_log 					= "[in] midi configuration:\n";

			for each(xml in inputs)
			{
				device				= new MidiDeviceDVO(++index,xml.@id,xml.@available,xml.name.text());
				_log 			   += "input " + device.id + " " + device.name + " (" + device.available + ")\n";
				_inputDevices.push(device);
			}

			index					= 0;

			for each(xml in outputs)
			{
				device				= new MidiDeviceDVO(++index,xml.@id,xml.@available,xml.name.text());
				_log 			   += "output " + device.id + " " + device.name + " (" + device.available + ")\n";
				_outputDevices.push(device);
			}
			for each(xml in synths)
			{
				device				= new MidiDeviceDVO(++index,xml.@id,xml.@available,xml.name.text());
				_log 			   += "output " + device.id + " " + device.name + " (" + device.available + ")\n";
				_outputDevices.push(device);
			}			
		}
		
		public function toString():String
		{
			return _log;
		}
		
		
		internal function get inports():Vector.<MidiDeviceDVO>
		{
			return _inputDevices;
		}

		internal function get outports():Vector.<MidiDeviceDVO>
		{
			return _outputDevices;
		}
		
		internal function get empty():Boolean
		{
			return _empty;
		}
		
		//utility functions
		
		public function getMidiInDeviceByName(name:String):MidiDeviceDVO
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

		public function getMidiOutDeviceByName(name:String):MidiDeviceDVO
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

		public function getMidiInDeviceById(id:int):MidiDeviceDVO
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

		public function getMidiOutDeviceById(id:int):MidiDeviceDVO
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
	}
}
