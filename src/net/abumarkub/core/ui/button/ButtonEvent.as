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
 
package net.abumarkub.core.ui.button 
{
	import flash.events.Event;
	import flash.geom.Point;

	public class ButtonEvent extends Event
	{
		private var _position:Point
		
		public static const DOWN:String 			= "BUTTON_DOWN";
		public static const UP:String 				= "BUTTON_UP";
		public static const OVER:String 			= "BUTTON_OVER";
		public static const OUT:String 				= "BUTTON_OUT";

		public static const ROLLOVER:String 		= "BUTTON_ROLLOVER";
		public static const ROLLOUT:String 			= "BUTTON_ROLLOUT";

		public static const CLICK:String 			= "BUTTON_CLICK";
		public static const DOUBLECLICK:String 		= "BUTTON_DOUBLECLICK";
		
		public static const IMAGE_LOADED:String 	= "IMAGE_LOADED";
		public static const DESELECTED:String 		= "DESELECTED";
		public static const SELECTED:String 		= "SELECTED";
		public static const SUB_MENU:String 		= "SUB_MENU";				

		public function ButtonEvent(type:String,position:Point,bubbles:Boolean=true)
		{
			_position = position;
			super(type, bubbles);
		}

	    public function get targetId():String
	    {
			return BasicButton(target).id;
		}
		
		public function get position():Point
		{
			return _position;
		}		
	    
	    public override function clone():Event
	    {
	        return new ButtonEvent(type,_position,bubbles);
	    }  	
	 }
}