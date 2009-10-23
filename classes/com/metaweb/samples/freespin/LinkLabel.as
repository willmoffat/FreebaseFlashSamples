//
//  LinkLabel
//
//  Created by Ketan Anjaria on 2007-10-04.
//  Copyright (c) 2007 kidBombay. All rights reserved.
//
package com.metaweb.samples.freespin {
	import flash.display.*	
	import flash.text.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.geom.*;
		
	import metaliq.core.*;
	import com.kidbombay.shapes.*;
	
	public class LinkLabel extends Component {
		public var label_txt:TextField;
		public var bg:RoundRect;
		public var highlight:MovieClip;
		/**
		 * Creates a new LinkLabel Component instance.
		 * com.metaweb.samples.freespin.LinkLabel
		 */
		public function LinkLabel() { 
			super();
		}
		
		override protected function configUI():void {
			super.configUI();
			// config

			label_txt.autoSize = "left";
			
			highlight.visible = false;
			highlight.alpha = 0;
		}

		override public function draw() : void {
			// draw

			bg.width = $width
			bg.height = $height
			
			highlight.rect.width = $width + 8;
			highlight.rect.height = $height + 8;
			
			highlight.x = highlight.y = -4;
			
			label_txt.x = Math.round($width/2 - label_txt.width/2) - 1
			label_txt.y = Math.round($height/2 - label_txt.height/2) + 1
			
			super.draw()
		}
		protected var $label:String;
		public function set label(p_label:String):void{
			$label = p_label;
			label_txt.text = $label
			setSize(label_txt.width+12,label_txt.height+4)
		}
		public function get label():String{
			return $label;
		}
		protected var $color:Number;
		public function set color(p_color:Number):void{
			$color = p_color;
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = p_color;
			bg.transform.colorTransform = colorTransform;
		}
		public function get color():Number{
			return $color;
		}
	}

}
