//
//  AutoCompleteView
//
//  Created by Ketan Anjaria on 2007-07-26.
//  Copyright (c) 2007 kidBombay. All rights reserved.
//
package com.metaweb.samples.freespin {
	import flash.display.*	
	import flash.text.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.ui.*;
	
	import com.adobe.serialization.json.*;
		
	import metaliq.core.*;
	import metaliq.events.*;
	
	import com.kidbombay.shapes.*;
	import com.kidbombay.util.*;
	import caurina.transitions.*;
	
	import com.metaweb.*;
	
	
	public class AutoCompleteView extends Component {
		public var bg:MovieClip;
		public var bgMask:RoundRect;	

		public var list:DynamicList;
		/**
		 * Creates a new AutoCompleteView Component instance.
		 * com.metaweb.samples.freespin.AutoCompleteView
		 */
		public function AutoCompleteView() { 
			super();
		}
		
		override protected function configUI():void {
			super.configUI();
			// config
			
			list.defaultItemClass = "com.metaweb.samples.freespin.AutoCompleteItem"
			list.marginY = 2;
			list.addEventListener(DynamicListEvent.ITEM_CLICK, onClickItem, false, 0, true);
			list.y = -bgMask.height;
			list.addEventListener("draw", onDrawList, false, 0, true);
			
			showList = false;
		}

		override public function draw() : void {
			// draw

			list.width = $width;
			bgMask.width = bg.rect.width = $width;
			
			var r:Number = $showCreateItem ? $rows+1 : $rows
			bgMask.height = bg.rect.height = ((30+list.marginY) * r) + 8
			
			bg.y = -bgMask.height
			

			super.draw()
		}
		private function onInputText (p_event:Event):void{
			var field:TextField = p_event.target as TextField;
			if(field.text.length > 0) {
				getAutoComplete(field.text)
			} else {
				showList = false;
			}
			
		}
		public function getAutoComplete(p_text:String):void{
			
			/*var autoComplete:Object = {};
			autoComplete.category = "instance";
			autoComplete.method = "instance"
			autoComplete.get_all_types = 0;
			autoComplete.disamb = 1;
			autoComplete.limit = 10;
			autoComplete.prefix = p_text;
			autoComplete.type = "/common/topic";
			
			var loader:URLLoader = DataManager.getData("api/service/autocomplete",true,autoComplete,onGetAutoComplete);*/
			
			var autoComplete:Object = {};
			autoComplete.limit = $rows;
			autoComplete.query = p_text + (p_text.length > 2 ? '*' : '')
			autoComplete.type = $type
			
			var loader:URLLoader = DataManager.getData("api/service/search",true,autoComplete,onGetAutoComplete);

		}
		private function onGetAutoComplete (p_event:Event):void{
			
			var loader:URLLoader = URLLoader(p_event.target);
			var result:Object = JSON.decode(loader.data);
			drawAutoComplete(result)
		}
		public function drawAutoComplete(p_result:Object):void{
			/*trace("RESULT = " + JSON.log(p_result))*/
			
			list.removeItems();
			var items:Array = p_result.result
			var length:Number = items.length;
			for (var i:int = 0; i<length; i++){
				var dataModel:Object =  items[i];
				list.addItem(dataModel)
			}
			
			if($showCreateItem) {
				dataModel = {name:"Create New",createNew:true,type:[]}
				list.addItem(dataModel)
			}
			
			if(length > 0) {
				showList = true;
				selectedIndex = 0
			}
		}
		
		private function onDrawList (p_event:Event):void{
			dispatchEvent(new Event("getAutoComplete"))
		}
		
		protected var $showList:Boolean;
		public function set showList ( p_showList:Boolean ):void{
			$showList = p_showList;	
			var newY:Number =$showList ? 0 : -bgMask.height - 30;
			 
			Tweener.addTween(list, { y:newY+4, time:.5});
			Tweener.addTween(bg, { y:newY, time:.5});
			if($showList) {
				stage.addEventListener("click", onClickStage, false, 0, true);
			} else {
				if(stage != null) stage.removeEventListener("click",onClickStage);
			}
		}
		public function get showList ():Boolean{
			return $showList;
		}
		private function onClickStage (p_event:Event):void{
			var hitField:Boolean = $inputField.hitTestPoint(stage.mouseX,stage.mouseY);

			var hit:Boolean =  bg.hitTestPoint(stage.mouseX,stage.mouseY,true)
			if(!hitField && !hit) {
				showList = false;
			}
		}
		private function onClickItem (p_event:DynamicListEvent):void{
			var item:AutoCompleteItem = p_event.item as AutoCompleteItem;
			showList = false;
			updateCaretIndex();
			dispatchEvent(new Event("autoComplete"));
		}
		
		public function get selectedDataModel():Object{
			var item:AutoCompleteItem = list.selectedItem() as AutoCompleteItem;
			if(item == null) return null
			
			return item.dataModel;
		}

		
		protected var $inputField:TextField;
		public function set inputField ( p_inputField:TextField ):void{
			$inputField = p_inputField;	
			$inputField.addEventListener("change", onInputText, false, 0, true);
			$inputField.addEventListener("focusIn", onFocusField, false, 0, true);
			$inputField.addEventListener("focusOut", onFocusFieldOut, false, 0, true);		
		}
		public function get inputField ():TextField{
			return $inputField;
		}
		private function onFocusField (p_event:Event):void{
			stage.addEventListener("keyDown", onKeyInput, false, 0, true);
		}
		private function onFocusFieldOut (p_event:Event):void{
			stage.removeEventListener("keyDown",onKeyInput)
		}
		private function onKeyInput (p_event:KeyboardEvent):void{

			if(p_event.keyCode == Keyboard.DOWN) {
				selectedIndex = Math.min($selectedIndex+1,list.length-1);
			} else if(p_event.keyCode == Keyboard.UP) {
				if($selectedIndex == -1) {
					selectedIndex = list.length - 1;
				} else {
					selectedIndex = Math.max($selectedIndex-1,0)
				}
				updateCaretIndex();
				
				// add delay to put insertion point at end of text
				var t:Timer = new Timer(18,1);
				t.addEventListener("timerComplete", onIndexUp, false, 0, true);
				t.start();
			} else if(p_event.keyCode == Keyboard.ENTER && $inputField.text.length > 0) {
				if($selectedIndex > - 1 ) {
					list.selectedIndex = $selectedIndex;
				} else {
					dispatchEvent(new Event("submit"))
				}
				updateCaretIndex();
			} else if(p_event.keyCode == Keyboard.ESCAPE) {
				showList = false;
			}
		}
		private function onIndexUp (p_event:Event):void{

			updateCaretIndex();
		}
		public function updateCaretIndex():void{
			var index:Number = $inputField.text.length;
			$inputField.setSelection(index,index)
		}

		
		protected var $selectedIndex:Number=-1;
		public function set selectedIndex ( p_selectedIndex:Number ):void{
			if($selectedIndex > -1) {
				var item:AutoCompleteItem = list.getItem($selectedIndex) as AutoCompleteItem;
				item.setFrame("falseUp")
			}
			$selectedIndex = p_selectedIndex;
			
			if($selectedIndex > -1) {
				item = list.getItem($selectedIndex) as AutoCompleteItem;
				item.setFrame("falseOver");
			}			
		}
		public function get selectedIndex ():Number{
			return $selectedIndex;
		}
		
		protected var $highlightedIndex:Number=-1;
		public function set highlightedIndex ( p_highlightedIndex:Number ):void{
			$highlightedIndex = p_highlightedIndex;	
			var item:AutoCompleteItem = list.getItem(p_highlightedIndex) as AutoCompleteItem;
			item.showHighlight = true
		}
		public function get highlightedIndex ():Number{
			return $highlightedIndex;
		}
		protected var $type:String="/common/topic";;
		public function set type ( p_type:String ):void{
			$type = p_type;			
		}
		public function get type ():String{
			return $type;
		}
		protected var $rows:Number=10;
		public function set rows ( p_rows:Number ):void{
			$rows = p_rows;			
		}
		public function get rows ():Number{
			return $rows;
		}
		protected var $showCreateItem:Boolean=false;
		public function set showCreateItem ( p_showCreateItem:Boolean ):void{
			$showCreateItem = p_showCreateItem;			
		}
		public function get showCreateItem ():Boolean{
			return $showCreateItem;
		}
	}

}
