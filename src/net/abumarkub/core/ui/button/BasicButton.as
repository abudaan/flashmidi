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
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;	

	public class BasicButton extends Sprite implements IBasicButton
	{
		protected var _skin:DisplayObjectContainer;
		protected var _id:String;
		protected var _selected:Boolean;
		protected var _enabled:Boolean;

		public function handleOver(e:MouseEvent=null):void{};
		public function handleOut(e:MouseEvent=null):void{};
		public function handleDown(e:MouseEvent=null):void{};
		public function handleUp(e:MouseEvent=null):void{};
		public function handleRollOver(e:MouseEvent=null):void{};
		public function handleRollOut(e:MouseEvent=null):void{};
		public function handleClick(e:MouseEvent=null):void{};
		public function handleDoubleClick(e:MouseEvent=null):void{};
				

		public function BasicButton(skin:DisplayObjectContainer, id:String = null, autoAdd:Boolean = true, doubleClickEnabled:Boolean = false)
		{
			focusRect					= false;
			
			_skin 						= skin;
			_id 						= id == null ? _skin.name : id;
			_skin.doubleClickEnabled 	= doubleClickEnabled;
			_selected		  			= false;
			if(autoAdd)addChild(_skin);
			addListeners(true);		
		}
		
		protected function addListeners(b:Boolean):void
		{
			_enabled				= b;
			_skin["buttonMode"]    	= b;
			_skin["useHandCursor"] 	= b;
			
			if(b)
			{
				_skin.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
				_skin.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
				_skin.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				_skin.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
				_skin.addEventListener(MouseEvent.ROLL_OUT, rollOut);
				_skin.addEventListener(MouseEvent.ROLL_OVER, rollOver);
				return;
			}
			_skin.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			_skin.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			_skin.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_skin.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_skin.removeEventListener(MouseEvent.ROLL_OUT, rollOut);
			_skin.removeEventListener(MouseEvent.ROLL_OVER, rollOver);
		}
		
		protected function mouseOver(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			dispatchEvent(new ButtonEvent(ButtonEvent.OVER,new Point(e.stageX,e.stageY)));
			handleOver(e);
		}

		protected function mouseOut(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			dispatchEvent(new ButtonEvent(ButtonEvent.OUT,new Point(e.stageX,e.stageY)));
			handleOut(e);			
		}

		public function mouseDown(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			dispatchEvent(new ButtonEvent(ButtonEvent.DOWN,new Point(e.stageX,e.stageY)));
			handleDown(e);						
		}

		public function mouseUp(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			dispatchEvent(new ButtonEvent(ButtonEvent.UP,new Point(e.stageX,e.stageY)));
			handleUp(e);									
		}

		protected function doubleClick(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			dispatchEvent(new ButtonEvent(ButtonEvent.DOUBLECLICK, new Point(e.stageX,e.stageY)));
			handleDoubleClick();
		}
		
		protected function click(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, new Point(e.stageX,e.stageY)));
			handleClick();
		}
		
		protected function rollOver(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			dispatchEvent(new ButtonEvent(ButtonEvent.ROLLOVER, new Point(e.stageX,e.stageY)));
			handleRollOver();
		}

		protected function rollOut(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			dispatchEvent(new ButtonEvent(ButtonEvent.ROLLOUT, new Point(e.stageX,e.stageY)));
			handleRollOut();
		}
		
		public function forcedClick(propagate:Boolean=false):void
		{
			if(propagate)dispatchEvent(new Event(ButtonEvent.DOWN));
			handleDown();									
		}

		public function setPosition(p:Point):void
		{
			_skin.x = p.x;
			_skin.y = p.y;
		}

		public function get id():String
		{
			return _id;
		}

		public function set id(s:String):void
		{
			_id = s;
		}

		public function get skin():DisplayObjectContainer
		{
			return _skin;
		}

		public function set selected(b:Boolean):void
		{
			_selected = b;
		}

		public function get selected():Boolean
		{
			return _selected;
		}

		public function get enabled():Boolean
		{
			return _enabled;
		}

		public function set enabled(b:Boolean):void
		{
			addListeners(b);
		}
		
		public function get skinMc():MovieClip
		{
			return MovieClip(skin);
		}

		public function get skinSprite():Sprite
		{
			return Sprite(skin);
		}
	}
}