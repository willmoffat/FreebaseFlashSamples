﻿////  ArtistLine//  Created by Ketan Anjaria on 2007-03-13.//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.//package com.metaweb.samples.soundline {	import flash.display.*		import flash.text.*;	import flash.events.*;	import flash.net.*;	import flash.geom.*;		import metaliq.core.*	import metaliq.util.*;	import metaliq.events.*;	import com.kidbombay.util.*;	import com.kidbombay.shapes.*;	import com.kidbombay.net.*;			import com.metaweb.*;		import com.adobe.serialization.json.*;		import caurina.transitions.*;			public class ArtistLine extends FrameButton {		public var bg:RoundRect;		public var postBG:Shape;		public var eventBG:RoundRect;		public var eventList:DynamicList;		public var lineHolder:Sprite;		public var arrow_btn:Sprite;		public var lock_btn:FrameButton;		public var delete_btn:FrameButton;		public var metaData:AlbumMetaData;		/**		 * Creates a new ArtistLine component instance.		 * com.metaweb.samples.soundline.ArtistLine		 */		public function ArtistLine() { 			super();		}				override protected function configUI() : void {			super.configUI();			buttonMode = false;			useHitRegion = true;			mouseChildren = true;			toggle = true;			label_txt.autoSize = "left";						postBG = new Shape();			addChild(postBG);			swapChildren(getChildAt(0),postBG);			swapChildren(getChildAt(0),eventBG);						lineHolder = new Sprite();			addChild(lineHolder)						eventList = new DynamicList();			lineHolder.x = eventList.x = 6;			lineHolder.y = eventList.y = 26;						eventList.defaultItemClass = "com.metaweb.samples.soundline.EventListItem";			eventList.layout = DynamicList.LAYOUT_HORIZONTAL;			eventList.customDraw = drawEventList;									addChild(eventList);						arrow_btn.addEventListener("click", onClickArrow, false, 0, true);			lock_btn.toggle = true;			lock_btn.addEventListener("click", onClickLock, false, 0, true);						delete_btn.addEventListener("click", onClickDelete, false, 0, true);							}		private function onClickDelete(p_event:Event):void{			dispatchEvent(new Event("delete"))		}		private function onClickLock(p_event:Event):void{			dispatchEvent(new Event("changeLock"))		}		private function onClickArrow(p_event:Event):void{			var url:String = DataManager.getLink($dataModel.guid)						var request:URLRequest = new URLRequest(url);			navigateToURL(request,"_blank")		}		private function onEventItemOut(p_event:Event):void{						var point:Point = new Point(stage.mouseX,stage.mouseY)			if(metaData != null && metaData.hitTestPoint(point.x,point.y,true)) {				return;			}			LoadManager.killThread("albumQuery");						hideMetaData();						}		protected function onAnimateMetaDataOut():void{			metaData.visible = false;			//metaData.parent.removeChild(metaData)			//metaData = null;		}		private function onEventItemOver(p_event:Event):void{									var eventListItem:EventListItem = p_event.currentTarget as EventListItem;			eventListItem.bringToFront();						var albumModel:Object = eventListItem.dataModel;						//if(metaData != null) metaData.parent.removeChild(metaData);						if(metaData == null) {				metaData = new AlbumMetaData();				addChild(metaData)			}			//Tweener.removeTween(metaData,"alpha");			metaData.alpha = 1;			metaData.x = eventListItem.x + eventList.x - 8;			metaData.y = eventBG.height - 8;			metaData.cacheAsBitmap = true;			metaData.mouseEnabled = false;			metaData.visible = false;			metaData.loadedQuery = false;			metaData.label_txt.autoSize = "left";			metaData.data_txt.autoSize = "left";						setMetaData(albumModel.eventModelIndex);									var images:Array = albumModel["/common/topic/image"];						metaData.image.addEventListener("complete", onLoadMetaDataImage, false, 0, true);			if(Environment.isInBrowser() ) {								if(images.length > 0) {					metaData.image.load(DataManager.getThumbURL(images[0].guid,200,200))				} else {					metaData.image.load("content/noCover.gif")				}				 					} else {				metaData.image.load("content/noCover.gif")			}					}		private function onLoadMetaDataImage(p_event:Event):void{			showMetaData()					}		public function showMetaData():void{			if(metaData != null) {								var imageWidth:Number = 200;				metaData.visible = true;				//Tweener.addTween(metaData, { alpha:1, time:.5, transition:"easeOutExpo",onComplete:onAnimateMetaDataOut});				Tweener.addTween(metaData.image, { width:imageWidth, height:imageWidth, time:.5, transition:"easeOutExpo"});				Tweener.addTween(metaData.imageHighlight, { width:imageWidth, height:imageWidth, time:.5, transition:"easeOutExpo"});				Tweener.addTween(metaData.label_txt, { x:imageWidth + 16, alpha:1, time:.5, transition:"easeOutExpo"});				Tweener.addTween(metaData.data_txt, { x:imageWidth + 16, alpha:1, time:.5, transition:"easeOutExpo"});							var bgWidth:Number = Math.max(imageWidth*2 + 16,imageWidth + 16 + Math.max(metaData.data_txt.width,metaData.label_txt.width) + 8)				var bgHeight:Number = Math.max(imageWidth + 16,metaData.data_txt.y + metaData.data_txt.height + 8)				Tweener.addTween(metaData.bg, { width:bgWidth, height:bgHeight, time:.5, transition:"easeOutExpo"});								Tweener.addTween(metaData, { alpha:1, time:.5, transition:"easeOutExpo"});			}					}		public function hideMetaData():void{						if(metaData != null) {				metaData.cacheAsBitmap = true;						var imageWidth:Number = 100;				Tweener.addTween(metaData.image, { width:imageWidth, height:imageWidth, time:.5, transition:"easeOutExpo"});				Tweener.addTween(metaData.imageHighlight, { width:imageWidth, height:imageWidth, time:.5, transition:"easeOutExpo"});				Tweener.addTween(metaData.label_txt, { x:imageWidth + 16, alpha:0,time:.5, transition:"easeOutExpo"});				Tweener.addTween(metaData.data_txt, { x:imageWidth + 16, alpha:0,time:.5, transition:"easeOutExpo"});				Tweener.addTween(metaData.bg, { width:imageWidth + 16, height:imageWidth + 16, time:.5, transition:"easeOutExpo"});				Tweener.addTween(metaData, { alpha:0, time:.5, transition:"easeOutExpo",onComplete:onAnimateMetaDataOut});							}		}				private function setMetaData(albumIndex:uint):void{						//showProgress(false)			if(metaData != null) {				var album:Object = $dataModel.album[albumIndex]				metaData.label_txt.text = album.name.toUpperCase();				var releaseDate:Date = DataManager.parseDate(album.release_date.value);				metaData.data_txt.text = DateUtil.getTimeStamp(releaseDate,"F, Y") + "\n\n";;				var tracks:Array = album.track;				var length:uint = tracks.length;				for ( var i:uint = 0; i < length; i++ ) {					var track:Object = tracks[i];					metaData.data_txt.appendText((i+1) + ". " + track.name + "\n");				}			}		}		private function onEventItemClick(p_event:Event):void{			var eventListItem:EventListItem = p_event.currentTarget as EventListItem;					var url:String = DataManager.getLink(eventListItem.dataModel.guid)					var request:URLRequest = new URLRequest(url);			navigateToURL(request,"_blank")		}				protected var $genreLine:GenreLine;		public function set genreLine(p_genreLine:GenreLine):void{			$genreLine = p_genreLine;					}		public function get genreLine():GenreLine{			return $genreLine;		}				protected var $dataModel:Object;		public function set dataModel(p_dataModel:Object):void{			$dataModel = p_dataModel;			label_txt.text = $dataModel.name.toUpperCase();			arrow_btn.x = label_txt.x + label_txt.width + 4;			lock_btn.x = arrow_btn.x + arrow_btn.width + 6;			delete_btn.x = lock_btn.x + lock_btn.width + 4;			eventBG.width = $width;			//addFoundedEvent();			if($dataModel.album.length > 0) {				addAlbums($dataModel.album)			} else {				eventBG.visible = false;			}		}		public function get dataModel():Object{			return $dataModel;		}		public function addFoundedEvent():void{			var event:Object = {};			event.eventDate = $dataModel.startDate;			event.label = DateUtil.getTimeStamp($dataModel.startDate,"M Y") + " - " + DateUtil.getTimeStamp($dataModel.endDate,"M Y")			event.eventTime = event.eventDate.getTime();			addEvent(event)		}		public function addEvent(event:Object):void{						eventList.addItem(event)		}		public function addAlbums(albums:Array):void{				var length:uint = albums.length;			var albumEvents:Array = [];			for ( var i:uint = 0; i < length; i++ ) {				var album:Object = albums[i];								//assume release is album				var type:String = "album"				var types:Array = album.release_type;				var j:int = types.length;				if(j > 0) {					while(j--) {						var foundType:String = types[j].name.toLowerCase()						type = foundType						if( type == "album") {							break;						}					}				}				if(type != "album" ) continue;																album.label = album.name;				// make a index that corresponds to the album model in the album array				// it's different than the album events index cause we only show release type albums				album.eventModelIndex = i;				var eventDate:Date = DataManager.parseDate(album.release_date.value)				//put release date in event				album.eventDate = eventDate;				album.eventTime = album.eventDate.getTime();								//trace(JSON.log(album))				albumEvents.push(album)			}			// sort by eventTime			albumEvents.sortOn("eventTime",Array.NUMERIC);			for ( i = 0; i < albumEvents.length; i++ ) {				album = albumEvents[i]				addEvent(album)			}		}		protected var $hasEventImages:Boolean=false;		public function set hasEventImages(p_hasEventImages:Boolean):void{			$hasEventImages = p_hasEventImages;					}		public function get hasEventImages():Boolean{			return $hasEventImages;		}				private function drawEventList():void{						if(eventList == null) return;						var items:Array = eventList.items;			var length:uint = items.length;			var rowPositionsX:Array = [0,0,0];			var maxOffSet:Number = 0;			var maxX:Number = 0;			for ( var i:uint = 0; i < length; i++ ) {								var row:Number = 0;				var eventListItem:EventListItem = items[i] as EventListItem;				var line:MovieClip = new EventListItemLine();				lineHolder.addChild(line);								eventListItem.addEventListener(MouseEvent.ROLL_OVER, onEventItemOver, false, 0, true);				eventListItem.addEventListener(MouseEvent.ROLL_OUT, onEventItemOut, false, 0, true);				eventListItem.addEventListener("click", onEventItemClick, false, 0, true);								var newX:Number = getXForDate(eventListItem.dataModel.eventDate)				eventListItem.x = newX;				line.x = newX;								while(newX < rowPositionsX[row]) {					row++				}								//eventListItem.albumRows = row;				eventListItem.offsetY = row * 26;				line.height+= eventListItem.offsetY;								rowPositionsX[row] = newX + eventListItem.width+3;				maxOffSet = Math.max(eventListItem.offsetY,maxOffSet)				maxX = Math.max(maxX, newX + eventListItem.width+3)			}													eventBG.height+= maxOffSet + 6;						for ( i = 0; i < length; i++ ) {				eventListItem = items[i] as EventListItem;				eventListItem.imageY = eventBG.height - eventList.y;				if(eventListItem.hasImage) {					$hasEventImages = true;				}			}			if(maxX > $width) {				eventBG.width = maxX + eventList.x;				drawPostBG();			} else {				eventBG.width = $width;			}						height = eventBG.height;			SoundLine.getInstance().redraw();		}		public function drawPostBG():void{			postBG.graphics.clear();			postBG.graphics.lineStyle(2,$color)			postBG.graphics.drawRoundRect(0,0,eventBG.width-1,bg.height,bg.radius*2)					}		public function getXForDate(p_date):Number{			var year:Number = p_date.getFullYear();			var startYear:Number = $dataModel.startDate.getFullYear();			var yearDelta:Number = year - startYear;									var newX:Number = (yearDelta * SoundLine.WIDTH_PER_YEAR);			var months:uint = p_date.getMonth();						if(months > 0) {				newX+= (SoundLine.WIDTH_PER_YEAR/12) * months;			}			return Math.round(newX); 		}		override public function draw() : void {			hitRegion.width = bg.width = $width;			hitRegion.height = $height;						var showingEvents:Boolean = true;			switch ( $frame ) {				case "falseDown" :				case "falseOver" :				case "trueUp":				case "trueDown":				case "trueOver":					//showingEvents = true					break;							}						showEvents (showingEvents);												super.draw();		}		public function showEvents(p_show:Boolean):void{						if(eventList == null) return;						var length:uint = eventList.items.length;			for ( var i:uint = 0; i < length; i++ ) {				eventList.items[i].showEvent(p_show)			}			if(!p_show) hideMetaData();		}		protected var $color:Number;		public function set color(p_color:Number):void{			$color = p_color;						var colorTransform:ColorTransform = new ColorTransform();			colorTransform.color = p_color;			bg.transform.colorTransform = colorTransform;		}		public function get color():Number{			return $color;		}			}}