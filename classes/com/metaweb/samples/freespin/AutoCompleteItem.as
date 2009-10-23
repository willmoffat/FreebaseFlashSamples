//
//  AutoCompleteItem
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
	
	import com.adobe.serialization.json.*;
		
	import metaliq.core.*;
	
	import caurina.transitions.*;
	import com.metaweb.*;
	import com.metaweb.samples.freespin.*;
		
	public class AutoCompleteItem extends DynamicListItem {	
		public var highlight:Sprite;
		public var type_txt:TextField;
		public var createBg:Sprite;
		public var imageNotFound:MovieClip;
		public var image:ExternalAsset;
		/**
		 * Creates a new AutoCompleteItem Component instance.
		 * com.metaweb.samples.freespin.AutoCompleteItem
		 */
		public function AutoCompleteItem() { 
			super();
		}
		
		override protected function configUI():void {
			super.configUI();
			// config
			highlight.visible = false;
			highlight.alpha = 0;
			$height = highlight.height;
			createBg.visible = false;
		}

		override public function set dataModel ( p_dataModel:* ):void{
			/*trace("ITEM = " + JSON.log(p_dataModel))*/
			$dataModel = p_dataModel;
			label_txt.htmlText = $dataModel.name;
			var types:Array = $dataModel.type;
			if(types.length > 0) {
				type_txt.text = types[0].name
			}
			if($dataModel.createNew) {
				label_txt.y+=5
				label_txt.textColor = 0xFFFFFF
				createBg.visible= true;
				imageNotFound.visible = false
			}
			if($dataModel.image != null && $dataModel.image.id != null) {
				var size:Number = 45;
				image.load(DataManager.getThumbURL($dataModel.image.id,size,size))
				image.addEventListener("complete", onLoadImage, false, 0, true);
			}
		}
		private function onLoadImage (p_event:Event):void{
			imageNotFound.visible = false;
		}
		override public function draw() : void {
			if($listOwner != null) {
				$width = $listOwner.width
			}
			
			createBg.width = highlight.width = $width;
			type_txt.width = label_txt.width = $width - 4
			
			// draw
			switch ($frame){
				case "falseUp":
					showHighlight = false;
					break;
				case "falseOver":
				case "falseDown":
					showHighlight = true;
					break;
			}

			super.draw()
		}
		protected var $showHighlight:Boolean;
		public function set showHighlight ( p_showHighlight:Boolean ):void{
			$showHighlight = p_showHighlight;
			var alpha:Number = $showHighlight ? 1 : 0
			if($showHighlight && $dataModel.createNew) {
				alpha = .35
			}
			Tweener.addTween(highlight, { _autoAlpha:alpha, time:1});	
		}
		public function get showHighlight ():Boolean{
			return $showHighlight;
		}

		
	}

}
