package com.flexComponent.component
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.IUIComponent;
	import mx.events.FlexEvent;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.core.IGraphicElement;
	
	[Event(name="complete", type="flash.events.Event")]
	
	public class DragButton extends SkinnableComponent
	{
		[SkinPart(required="true")]
		public var track:IGraphicElement;
		
		[SkinPart(required="true")]
		public var thumb:IUIComponent;
		
		private const MOVE_LEFT:String = "LEFT";
		private const MOVE_RIGHT:String = "RIGHT";
		
		private var _chkFlag:Boolean = false;
		private var _moveFlag:String = MOVE_RIGHT;
		private var _mouseDownXPos:Number = 0;
		private var _autoCompletePercent:Number = 0.25;
		
		[Bindable]
		private var _min:Number = 0;
		
		[Bindable]
		private var _max:Number = 0;
		
		public function DragButton()
		{
			super();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreatComplete);
		}
		
		private function onCreatComplete(event:FlexEvent):void
		{
			if (track != null && thumb != null)
				thumb.x = track.x;
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch (instance)
			{
				case track :
					systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_DOWN, sendBoxMouseDownHandler);
					break;
				case thumb :
					thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
					thumb.addEventListener(MouseEvent.CLICK, thumbClickHandler);
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			switch (instance)
			{
				case track :
					systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_DOWN, sendBoxMouseDownHandler);
					break;
				case thumb :
					thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
					thumb.removeEventListener(MouseEvent.CLICK, thumbClickHandler);
					break;
			}
		}
		
		/*******************************************************************
		 * on Enter Frame Handler
		 *******************************************************************/
		// Enter Frame Handler
		private function onEnterFrameHandler(event:Event):void
		{
			if (!_chkFlag)
				return;
			
			switch (_moveFlag)
			{
				case MOVE_RIGHT :
					thumb.x = thumb.x + (max - thumb.x) * 0.3;
					break;
				case MOVE_LEFT :
					thumb.x = thumb.x + (min - thumb.x) * 0.3;
					break;
			}
			
			if (thumb.x < min + 1 || thumb.x > max - 1)
			{
				thumb.x = (thumb.x < min + 1)?min:max;
				_chkFlag = false;
			}
			
			if (thumb.x == max) // &#53804;&#54364;
			{
				dispatchEvent(new Event(Event.COMPLETE));
				thumb.x = max - 1;
				_moveFlag = MOVE_LEFT;
				_chkFlag = true;
			}
		}
		
		/*******************************************************************
		 * Public Method
		 *******************************************************************/
		public function get max():Number
		{
			return track.width - thumb.width + track.x;
		}
		
		public function get min():Number
		{
			return track.x;
		}
		
		/*******************************************************************
		 * Getter / Setter
		 *******************************************************************/
		public function get autoCompletePercent():Number
		{
			return _autoCompletePercent;
		}
		
		public function set autoCompletePercent(value:Number):void
		{
			_autoCompletePercent = value;
		}
		
		/*******************************************************************
		 * Send Box Mouse Event Handler
		 *******************************************************************/
		// Area Mouse Down
		private function sendBoxMouseDownHandler(event:MouseEvent):void
		{
			_mouseDownXPos = event.stageX - thumb.x;
		}
		
		// Send Box Mouse Move Handler
		private function sendBoxMouseMoveHandler(event:MouseEvent):void
		{
			var moveXPos:Number = event.stageX - _mouseDownXPos;
			
			if (moveXPos < min)
				moveXPos = min;
			else if (moveXPos > max)
				moveXPos = max;
			
			thumb.x = moveXPos;
		}
		
		// Send Box Mouse Up Handler
		private function sendBoxMouseUpHandler(event:MouseEvent):void
		{
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_MOVE, sendBoxMouseMoveHandler);
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, sendBoxMouseUpHandler);
			
			_moveFlag = (thumb.x > max * _autoCompletePercent)?MOVE_RIGHT:MOVE_LEFT;
			_chkFlag = true;
		}
		
		/*******************************************************************
		 * Thumb Mouse Event Handler
		 *******************************************************************/
		// Thumb Mouse Down Handler
		private function thumbMouseDownHandler(event:MouseEvent):void
		{
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_MOVE, sendBoxMouseMoveHandler);
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, sendBoxMouseUpHandler);
		}
		
		// Thumb Click Handler
		private function thumbClickHandler(event:MouseEvent):void
		{
			if (thumb.x == min)
			{
				_moveFlag = MOVE_RIGHT;
				_chkFlag = true;
			}
		}
	}
}