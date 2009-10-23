﻿////  ExternalAsset//  /Users/ketan/Documents/metaliq/kuler/develop2/classes/metaliq/core//  Created by Ketan Anjaria on 2006-09-13.//  Copyright (c) 2006 __MyCompanyName__. All rights reserved.//package metaliq.core {	import flash.display.*;	import flash.net.*;	import flash.events.*;	import flash.text.*;		import metaliq.core.Component;	public class ExternalAsset extends Component {				public var holder:Sprite;		public var content:Loader;		public var holderMask:Shape;			protected var $assetUrl:String;		protected var $assetWidth:Number;		protected var $assetHeight:Number;		protected var $useMask:Boolean = false;		protected var $isLoaded:Boolean = false;		protected var $allowScale : Boolean = false;		/**		 * Creates a new ExternalAsset component instance.		 * metaliq.core.ExternalAsset		 */		public function ExternalAsset() { super(); }				override protected function configUI():void {			super.configUI();						holder = new Sprite();			holder.name = "holder";			addChild(holder)			content = new Loader();			content.name = "content";			holder.addChild(content);						holderMask = new Shape();			holderMask.name = "holderMask";			holderMask.visible = false			addChild(holderMask);								}			override public function draw() : void {			if (holder == null) return;			var scale:Number = 1;			if($allowScale && $assetWidth > 0) {				if($assetHeight < $assetWidth) {					scale = $width/$assetWidth;									} else {					scale = $height/$assetHeight;				}				scale = Math.min(1,scale);							} 			holder.scaleX = holder.scaleY = scale;			holderMask.graphics.clear();			holderMask.graphics.beginFill(0xFF000);			holderMask.graphics.drawRect(0, 0, $width, $height);			holderMask.graphics.endFill();						useMask = $useMask;			if($isLoaded) {holder.visible = true};						super.draw();		}		public function load (  p_assetUrl : String  )  :  void  {			$assetUrl = p_assetUrl;			var request:URLRequest = new URLRequest($assetUrl);						holder.visible = false;						unload();			holder.removeChild(content);						content = new Loader();			holder.addChild(content);						content.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);			content.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete, false, 0, true)			content.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);						try {				content.load(request);			} catch (error:*) {				trace("   Unable to load requested document. " + error);			}		}				public function unload() : void {			// TODO check if content is loading before calling close			//content.close();			$isLoaded = false;			content.unload();		}				protected function onComplete(p_event:Event) {			$assetWidth = content.width; 			$assetHeight = content.height;			$isLoaded = true;			draw();			dispatchEvent(p_event);					}		private function onProgress(p_event:Event):void{			dispatchEvent(p_event)		}		private function onIOError(p_event:IOErrorEvent):void{			dispatchEvent(p_event)		}		public function get isLoaded():Boolean{			return $isLoaded;		}		override public function set width(p_width:Number):void{			setSize(p_width,$height);					}		override public function get width():Number{			return $width;		}				override public function set height(p_height:Number):void{			$height = p_height;			setSize($width,p_height);		}		override public function get height():Number{			return $height;		}				[Inspectable(type="String", defaultValue="")]		public function set assetUrl (p_assetUrl:String) : void		{			if(p_assetUrl == null || p_assetUrl == "") return;			$assetUrl = p_assetUrl;			load($assetUrl);		}		public function get assetUrl () : String		{		   return $assetUrl;		}				[Inspectable(type="Boolean", defaultValue=false)]		public function set allowScale (p_allowScale:Boolean) : void		{			//if(p_allowScale == null) return;		  $allowScale = p_allowScale;		  if(!$allowScale) {		  	holder.scaleX = holder.scaleY = 1;		  }		  draw();		}				public function get allowScale () : Boolean		{		   return $allowScale;		}				[Inspectable(type="Boolean", defaultValue=false)]		public function set useMask (p_useMask:Boolean) : void		{			$useMask = p_useMask;			if($useMask) {				holder.mask = holderMask;				} else {				holder.mask = null			}		}				public function get useMask () : Boolean		{		   return $useMask;		}					public function get assetWidth():Number{			return $assetWidth;		}				public function get assetHeight():Number{			return $assetHeight;		}	}}