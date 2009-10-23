//
//  GenreLine
//  Created by Ketan Anjaria on 2007-03-13.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//
package com.metaweb.samples.soundline {
	import flash.display.*	
	import flash.text.*;
	import flash.events.*;
	import flash.net.*;
	
	import metaliq.core.*
	import com.metaweb.samples.soundline.*;
	
	public class GenreLine extends Component {
		public var label_txt:TextField;
		public var items:Array;
		/**
		 * Creates a new GenreLine component instance.
		 * com.metaweb.samples.soundline.GenreLine
		 */
		public function GenreLine() { 
			super();
		}
		
		override protected function configUI() : void {
			super.configUI();
			cacheAsBitmap = true;
			items = []
			label_txt.autoSize = "right";
		}

		override public function draw() : void {

			super.draw();
		}

		public function addItem(p_item:ArtistLine):void{
			p_item.genreLine = this;
			items.push(p_item)
		}
		
		public function set label(p_label:String):void{
			label_txt.text = p_label;
			$height = label_txt.height
		}
		public function get label():String{
			return label_txt.text;
		}
		
	}
}