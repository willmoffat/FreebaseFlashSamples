//
//  PropertyQuery
//
//  Created by Ketan Anjaria on 2007-10-22.
//  Copyright (c) 2007 kidBombay. All rights reserved.
//
package com.metaweb.query {
	import flash.display.*	
	import flash.text.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;

	public class PropertyQuery {	
		/**
		 * Creates a new PropertyQuery MovieClip instance.
		 * com.metaweb.query.PropertyQuery
		 */
		public function PropertyQuery() { 
			super();
		}
		protected var $label:String;
		public function set label ( p_label:String ):void{
			$label = p_label;			
		}
		public function get label ():String{
			return $label;
		}
		protected var $objectType:String;
		public function set objectType ( p_objectType:String ):void{
			$objectType = p_objectType;			
		}
		public function get objectType ():String{
			return $objectType;
		}
		protected var $property:String;
		public function set property ( p_property:String ):void{
			$property = p_property;			
		}
		public function get property ():String{
			return $property;
		}
		protected var $index:Number;
		public function set index ( p_index:Number ):void{
			$index = p_index;			
		}
		public function get index ():Number{
			return $index;
		}
		protected var $propertyTarget:String;
		public function set propertyTarget ( p_propertyTarget:String ):void{
			$propertyTarget = p_propertyTarget;			
		}
		public function get propertyTarget ():String{
			return $propertyTarget;
		}
		protected var $targetCriteria:String;
		public function set targetCriteria ( p_targetCriteria:String ):void{
			$targetCriteria = p_targetCriteria;			
		}
		public function get targetCriteria ():String{
			return $targetCriteria;
		}
		protected var $rootTypes:Array;
		public function set rootTypes ( p_rootTypes:Array ):void{
			$rootTypes = p_rootTypes;			
		}
		public function get rootTypes ():Array{
			return $rootTypes;
		}
	}
}
