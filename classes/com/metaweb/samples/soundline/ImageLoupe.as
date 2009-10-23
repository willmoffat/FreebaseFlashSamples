//
//  ImageLoupe
//  Created by Ketan Anjaria on 2007-03-26.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//
package com.metaweb.samples.soundline {
	import flash.display.*	
	import flash.text.*;
	import flash.events.*;
	import flash.net.*;
	import flash.geom.*;
	
	import metaliq.core.*
	import com.kidbombay.shapes.*;
	
	public class ImageLoupe extends Component {
		public var contentMask:RoundRect;
		public var contentHolder:Sprite;
		public var content:Bitmap;
		public var bitmapData:BitmapData;
		public var bg:RoundRect;
		public var highlight:Sprite;
		/**
		 * Creates a new ImageLoupe component instance.
		 * com.metaweb.samples.soundline.ImageLoupe
		 */
		public function ImageLoupe() { 
			super();
		}
		
		override protected function configUI() : void {
			super.configUI();
			mouseEnabled = false;
			content = new Bitmap()
			contentHolder.addChild(content)
			
			contentMask.visible = false;
		}

		override public function draw() : void {
			bg.width = $width;
			bg.height = $height
			bg.radius = $height/2
			contentMask.radius = bg.radius - contentMask.x;
			highlight.width = contentMask.width = $width - contentMask.x * 2;
			highlight.height = contentMask.height = $height - contentMask.y * 2;
			
			super.draw();
		}
		
		protected var $contentSource:DisplayObject;
		public function set contentSource(p_contentSource:DisplayObject):void{
			$contentSource = p_contentSource;
			
		}
		public function get contentSource():DisplayObject{
			return $contentSource;
		}
		
		protected var $contentScale:Number=1;
		public function set contentScale(p_contentScale:Number):void{
			$contentScale = p_contentScale;
			
		}
		public function get contentScale():Number{
			return $contentScale;
		}
		protected var $contentX:Number=0;
		public function set contentX(p_contentX:Number):void{
			$contentX = p_contentX;
			update();
		}
		public function get contentX():Number{
			return $contentX;
		}
		protected var $contentY:Number=0;
		public function set contentY(p_contentY:Number):void{
			$contentY = p_contentY;
			update();
		}
		public function get contentY():Number{
			return $contentY;
		}
		public function update():void{
			if(contentSource != null) {
				var matrix : Matrix = new Matrix();
				matrix.scale($contentScale,$contentScale);
				matrix.translate(-$contentX + $width/2,-$contentY + $height/2)

				if(bitmapData != null) {
					bitmapData.dispose()
				}
				bitmapData = new BitmapData($width, $height, true,0xFFFFFF);
	
				bitmapData.draw(contentSource,matrix)

				content.bitmapData = bitmapData;

			}
		}
	}
}