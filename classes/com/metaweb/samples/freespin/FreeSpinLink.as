//
//  FreeSpinLink
//  Created by Ketan Anjaria on 2007-06-20.
//  Copyright (c) 2007 kidBombay. All rights reserved.
//
package com.metaweb.samples.freespin {
	import flash.display.*	
	import flash.text.*;
	import flash.events.*;
	import flash.net.*;
	import flash.geom.*;
	
	import caurina.transitions.*;
	
	import metaliq.core.*
	import com.kidbombay.shapes.*;
	import com.metaweb.samples.freespin.*;
	
	public class FreeSpinLink extends Component {
		public var line:Sprite;
		public var highlight:Sprite;
		public var labelHolder:Sprite;
		private var $labels:Array;
		private var $labelsByName:Object;
		private var $maxLabelWidth:Number=0;
		/**
		 * Creates a new FreeSpinLink component instance.
		 * com.metaweb.samples.freespin.FreeSpinLink
		 */
		public function FreeSpinLink() { 
			super();
		}
		
		override protected function configUI() : void {
			super.configUI();
			highlight.visible = false
			highlight.alpha = 0;
			
			$labels = []
			$labelsByName = {}
			labelHolder = new Sprite();
			addChild(labelHolder)
			addEventListener("click", onClick, false, 0, true);
			addEventListener(MouseEvent.ROLL_OVER, onOver, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, onOut, false, 0, true);
		}
		private function onClick (p_event:Event):void{
			$targetNode.dispatchItemClick();
		}
		private function onOver (p_event:Event):void{
			$targetNode.onOver(p_event)
		}
		private function onOut (p_event:Event):void{
			$targetNode.onOut(p_event)
		}
		override public function draw() : void {

			super.draw();
		}
		public function drawLine(p_x:Number,p_y:Number):void{
			

			line.scaleX = 0;
			line.scaleY = 0;
			
			highlight.scaleX = line.scaleX = p_x/100;
			highlight.scaleY = line.scaleY = p_y/100;
			if(highlight.scaleX == 0) {
				highlight.scaleX = .001
			}
			if(highlight.scaleY == 0) {
				highlight.scaleY = .001
			}
			
			labelHolder.x = p_x/2 - labelHolder.width/2 + 3
			labelHolder.y = p_y/2 - labelHolder.height/2 + 6;
			
			var i:Number = $labels.length;
			while(i--) {
				var linkLabel:LinkLabel = $labels[i] as LinkLabel;
				linkLabel.x = $maxLabelWidth/2 - linkLabel.width/2
			}

		}
		public function addLabel(p_label:String,p_color):void{
			if($labelsByName[p_label] != null) return;
			
			var linkLabel:LinkLabel = new LinkLabel();
			linkLabel.label = p_label;
			linkLabel.color = p_color;
			labelHolder.addChild(linkLabel)
			
			linkLabel.y = $labels.length * (linkLabel.height + 4)
			
			$maxLabelWidth = Math.max(linkLabel.width,$maxLabelWidth)
			$labels.push(linkLabel)
			$labelsByName[p_label] = linkLabel;
		}

		public function showHighlight(p_show:Boolean):void{
			var a:Number = p_show ? 1 : 0
			Tweener.addTween(highlight, { _autoAlpha:a, time:FreeSpin.ANIMATION_SPEED/2,transition:"linear"});
			var i:Number = $labels.length;
			while(i--) {
				var linkLabel:LinkLabel = $labels[i] as LinkLabel;
				Tweener.addTween(linkLabel.highlight, { _autoAlpha:a, time:FreeSpin.ANIMATION_SPEED/2,transition:"linear"});
			}
		}

		
		protected var $originNode:FreeSpinNode;
		public function set originNode(p_originNode:FreeSpinNode):void{
			$originNode = p_originNode;
			
		}
		public function get originNode():FreeSpinNode{
			return $originNode;
		}
		protected var $targetNode:FreeSpinNode;
		public function set targetNode(p_targetNode:FreeSpinNode):void{
			$targetNode = p_targetNode;
			
		}
		public function get targetNode():FreeSpinNode{
			return $targetNode;
		}
		
	}
}