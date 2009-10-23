//
//  PropertyQueryResult
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

	public dynamic class PropertyQueryResult  {
		static public var INSTANCE_COUNT:Number=0;
		/**
		 * Creates a new PropertyQueryResult MovieClip instance.
		 * com.metaweb.query.PropertyQueryResult
		 */
		public function PropertyQueryResult(p_source:Object=null) { 
			super();
			
			var targetReg:RegExp = /target:.+/;
			
			for (var i:String in p_source){
				
				if(targetReg.test(i)) {
					for (var j:String in p_source[i]){
						this[j] = p_source[i][j]
					}
					
				} else {
					/*trace(i + " = " +p_source[i] )*/
					this[i] = p_source[i]
				}
			}	
		}
		
		protected var $propertyQuery:PropertyQuery;
		public function set propertyQuery ( p_propertyQuery:PropertyQuery ):void{
			$propertyQuery = p_propertyQuery;			
		}
		public function get propertyQuery ():PropertyQuery{
			return $propertyQuery;
		}

		protected var $id:String;
		public function set id ( p_id:String ):void{
			$id = p_id;			
		}
		public function get id ():String{
			return $id;
		}
		
		protected var $name:String;
		public function set name ( p_name:String ):void{
			$name = p_name;			
		}
		public function get name ():String{
			return $name;
		}

		protected var $type:String;
		public function set type ( p_type:String ):void{
			$type = p_type;			
		}
		public function get type ():String{
			return $type;
		}
		
		public function get image ():Object{
			if(this['/common/topic/image'] != null) {
				var images:Array =  this['/common/topic/image'] as Array
				if(images != null && images.length > 0) return images[0];
			}
			return null
		}
		
		protected var $index:Number;
		public function set index ( p_index:Number ):void{
			$index = p_index;			
		}
		public function get index ():Number{
			return $index;
		}
	}
}
