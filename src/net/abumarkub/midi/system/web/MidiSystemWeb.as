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
package net.abumarkub.midi.system.web 
{
	import net.abumarkub.midi.system.IMidiConfigUI;
	import net.abumarkub.midi.system.IMidiSystem;
	import net.abumarkub.midi.system.MidiSystem;

	/**
	 * @author abudaan
	 * 
	 * This is the web version of the MidiSystem class.
	 * 
	 * The difference between the air and the web version is:
	 * - the way it connects to your hardware midi system
	 * - the way it stores default midi devices
	 * 
	 * The web version connects to your hardware midi system via an applet that is connected to Flash via the ExternalInterface
	 * The air version connects to your hardware midi system via a commandline program that is started by a NativeProcess
	 * 
	 * The web version stores the default midi devices in a SharedObject
	 * The air version stores the default midi devices in a File on your local harddrive
	 * 
	 * You can see that this class only instantiates the proper version of MidiSettings and MidiSystem, and for the rest all logic takes place
	 * in the super class MidiSystem. 
	 * 
	 * Note that MidiSystem, MidiSettings and MidiConnection do not implement the interfaces IMidiSystem, IMidiSettings and IMidiConnection respectively:
	 * this is done to make those classes 'abstract' and prevents you from instantiating and using these classes directly.
	 * 
	 * Whereas:
	 * - the classes MidiSystemWeb and MidiSystemAir both implement IMidiSystem
	 * - the classes MidiConnectionWeb and MidiConnectionAir both implement IMidiConnection
	 * - the classes MidiSettingsWeb and MidiSettingsAir both implement IMidiSettings
	 * 
	 */
	public class MidiSystemWeb extends MidiSystem implements IMidiSystem
	{		
		private static var _instance:MidiSystemWeb 		= null;

		public function MidiSystemWeb(configUI:IMidiConfigUI=null)
		{	
			_midiSettings		= new MidiSettingsWeb();
			_midiConnection		= MidiConnectionWeb.getInstance();
			super(configUI);
		}
												
		/**
		 * @param configUI: the MidiConfigUI to be used. If you leave this parameter empty, the default MidiConfigUI will be used
		 * @see MidiConfigUI
		 */
		public static function getInstance(configUI:IMidiConfigUI = null):MidiSystemWeb
		{
			if(_instance == null)
			{
				_instance = new MidiSystemWeb(configUI);
			}
			return _instance;
		}
	}
}
