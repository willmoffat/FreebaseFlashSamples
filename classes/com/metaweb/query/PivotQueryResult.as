//
//  PivotQueryResult
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

	import com.adobe.serialization.json.*;
	import com.metaweb.*;
	import com.metaweb.query.*;
	
	public class PivotQueryResult {	
		/**
		 * Creates a new PivotQueryResult MovieClip instance.
		 * com.metaweb.query.PivotQueryResult
		 */
		public function PivotQueryResult() { 
			super();
		}
		public function parseResult(p_result:Object):void{
			/*trace(JSON.log(p_result))*/
			$success = false
			$items = []
			var queryReg:RegExp = /query_([0-9]+):.+/;
			$rootItem = new PropertyQueryResult();
			var queryResults:Array = [];
			for (var i:String in p_result){
				// if i is in the form "query_N"
				if(queryReg.test(i)) {
					var index:Number = Number(i.replace(queryReg,'$1'))	
					// place results in array by index of query				
					queryResults[index] = p_result[i]
					
				} else {
					$success = true
					$rootItem[i] = p_result[i]
				}
			}
			
			// loop throught resultArrays and results
			var length:int = queryResults.length;
			for (var j:int = 0; j<length; j++){
				// j is query index
				var propertyQuery:PropertyQuery = $pivotQuery.getQuery(j)
				var results:Array = queryResults[j]
				var resultsLength:Number = results.length
				for (var k:int = 0; k<resultsLength; k++){
					var result:PropertyQueryResult = new PropertyQueryResult(results[k])
					result.propertyQuery = propertyQuery;
					$items.push(result)
				}
			}
			
		}
		protected var $success:Boolean=false;
		public function get success ():Boolean{
			return $success;
		}
		
		protected var $pivotQuery:PivotQuery;
		public function set pivotQuery ( p_pivotQuery:PivotQuery ):void{
			$pivotQuery = p_pivotQuery;			
		}
		public function get pivotQuery ():PivotQuery{
			return $pivotQuery;
		}

		protected var $items:Array;
		public function set items ( p_items:Array ):void{
			$items = p_items;			
		}
		public function get items ():Array{
			return $items;
		}
		
		public function getItemsForPage(p_page:Number):void{
			var startIndex:Number = p_page * $itemsPerPage
			
		}

		
		protected var $itemsPerPage:Number=25;
		public function set itemsPerPage ( p_itemsPerPage:Number ):void{
			$itemsPerPage = p_itemsPerPage;			
		}
		public function get itemsPerPage ():Number{
			return $itemsPerPage;
		}
		
		protected var $currentPage:Number;
		public function set currentPage ( p_currentPage:Number ):void{
			$currentPage = p_currentPage;			
		}
		public function get currentPage ():Number{
			return $currentPage;
		}
		
		
		protected var $rootItem:PropertyQueryResult;
		public function set rootItem ( p_rootItem:PropertyQueryResult ):void{
			$rootItem = p_rootItem;			
		}
		public function get rootItem ():PropertyQueryResult{
			return $rootItem;
		}

	}
}
