//
//  DropDownItem
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
	
	import metaliq.core.*;

	import caurina.transitions.*;
	
	public class DropDownItem extends DynamicListItem {	
		public var highlight:MovieClip;
		/**
		 * Creates a new DropDownItem Component instance.
		 * metaliq.controls.DropDownItem
		 */
		public function DropDownItem() { 
			super();
		}
		
		override protected function configUI():void {
			super.configUI();
			// config
			$height = highlight.height;
			highlight.visible = false;
		}

		override public function draw() : void {
			// draw
			if($listOwner != null) {
				$width = $listOwner.width
			}
			
			highlight.width = $width;
			label_txt.width = $width -2
			switch ($frame){
				case "falseUp":
					showHighlight = false;
					break;
				case "falseOver":
				case "falseDown":
				case "trueOver":
				case "trueDown":
				case "trueUp":
					showHighlight = true;
					break;
			}

			super.draw()
		}
		protected var $showHighlight:Boolean;
		public function set showHighlight ( p_showHighlight:Boolean ):void{
			$showHighlight = p_showHighlight;
			Tweener.addTween(highlight, { _autoAlpha:$showHighlight ? 1 : 0, time:1});	
		}
		public function get showHighlight ():Boolean{
			return $showHighlight;
		}
	}

}
