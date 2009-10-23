//
//  DropDown
//
//  Created by Ketan Anjaria on 2007-09-11.
//  Copyright (c) 2007 kidBombay. All rights reserved.
//
package metaliq.controls {
	import flash.display.*	
	import flash.text.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.geom.*;
	
	import metaliq.core.*;
	import metaliq.events.*;
	
	import com.kidbombay.shapes.*;
	
	import metaliq.controls.*;
	
	public class DropDown extends Component {	
		public var bgMask:RoundRect;
		public var bg:MovieClip;
		public var arrow_btn;
		public var label_txt:TextField;
		public var list:DynamicList;
		var listBG:MovieClip
		/**
		 * Creates a new DropDown Component instance.
		 * metaliq.controls.DropDown
		 */
		public function DropDown() { 
			super();
		}
		
		override protected function configUI():void {
			
			super.configUI();
			// config
			listBG = new DropDownListBG();
			addChild(listBG)
			
			list = new DynamicList();
			addChild(list)
			
			list.defaultItemClass = 'metaliq.controls.DropDownItem'
			list.addEventListener("draw", onDrawList, false, 0, true);
			list.addEventListener(DynamicListEvent.ITEM_CLICK, onSelectItem, false, 0, true);
			
			arrow_btn.addEventListener("click", onClickArrow, false, 0, true);
			
			open = false;

		}

		override public function draw() : void {
			// draw
			bgMask.width = bg.width = $width;
			
			arrow_btn.x = $width - arrow_btn.width
			label_txt.width  = arrow_btn.x - 2
			if(list  != null) {
				list.width = $width;
			}
			super.draw()
		}

		protected var $open:Boolean=false;
		public function set open ( p_open:Boolean ):void{
			$open = p_open;	
			listBG.visible = list.visible = $open
			listBG.width = $width
			if($open) {
				positionList();
				stage.addEventListener("click", onClickStage, false, 0, true);
			} else {
				if(stage != null) stage.removeEventListener('click',onClickStage);
			}
		}
		public function get open ():Boolean{
			return $open;
		}
		public function positionList():void{
			var listX:Number = 0
			var listY:Number = bg.height + 1
			
			listBG.x = list.x = listX;
			listBG.y = list.y = listY;
			
		}

		public function selectedItem():DropDownItem {
			return list.selectedItem() as DropDownItem
		}

		
		public function addItem(p_dataModel:Object):DropDownItem {
			
			var item:DropDownItem = list.addItem(p_dataModel) as DropDownItem
			if(list.length == 1) {
				list.selectedIndex = 0;
			}
			return item	
		}
		
		protected var $dataModel:Array;
		public function set dataModel ( p_dataModel:Array ):void{
			list.dataModel = p_dataModel;

			if(list.length > 0) {
				list.selectedIndex = 0;
			}
		}
		public function get dataModel ():Array{
			return list.dataModel;
		}
		private function onClickStage (p_event:Event):void{
			var hit:Boolean = hitTestPoint(stage.mouseX,stage.mouseY,true)
			if(!hit) open = false
		}
		private function onSelectItem (p_event:DynamicListEvent):void{
			open = false;
			label_txt.text = p_event.item.dataModel.label
			dispatchEvent(new Event("change"))
		}
		private function onClickArrow (p_event:Event):void{
			open = !$open
		}
		
		private function onDrawList (p_event:Event):void{
			list.y = -list.height
			listBG.y = list.y - 3
			listBG.width = list.width;
			listBG.height = list.height + 1;
		}
	}

}
