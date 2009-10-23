//
//  PivotQuery
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
	
	public class PivotQuery extends EventDispatcher {	
		/**
		 * Creates a new PivotQuery MovieClip instance.
		 * com.metaweb.query.PivotQuery
		 */
		public var imageQuery:Object;
		public var criteriaQuery:Object;
		public var requiredFields:Object;
		private var $queries:Array;
		protected var $result:PivotQueryResult;
		
		public function PivotQuery() { 
			super();
			imageQuery = {"/common/topic/image":[{"guid":null,"index":null,"limit":1,"link":{"timestamp":null},"optional":true,"sort":["index","-link.timestamp"]}]}
			
			criteriaQuery = {	"index":null,
												"link":{"timestamp":null},
      									"sort":["index","-link.timestamp"],
												"optional":true,
												"limit":$resultPerPage
											}
											
			requiredFields = {	id:null,
													guid:null,
													name:null,
													"types:type": []
												}
			$queries = [];
		}
		public function searchByName(p_name:String):void{

			name = p_name;
			id = null
			
			var query:Object = buildQuery()
			
			var wrapper:Object = {query:[query]}
		
			var loader:URLLoader = DataManager.getQuery(wrapper,onGetQuery);
			//loader.addEventListener(IOErrorEvent.IO_ERROR, onGetQueryError)
		}
		public function searchByID(p_id:String):void{

			name = null;
			id = p_id
			
			var query:Object = buildQuery()
			
			var wrapper:Object = {query:[query]}
		
			var loader:URLLoader = DataManager.getQuery(wrapper,onGetQuery);
			//loader.addEventListener(IOErrorEvent.IO_ERROR, onGetQueryError)
		}
		
		function buildQuery() : Object {
			var query = {}
			var j:String
			// add base parameters
			query.name = $name;
			query.id = $id
			query.guid = null
			query.type = "/common/topic"
			query["types:type"] = []
			
			// add image
			query["/common/topic/image"] = imageQuery["/common/topic/image"]
				
			var length : Number = $queries.length;
			for (var i:int = 0; i<length; i++){
				var queryName:String = "query_"+i;
				var propertyQueryObj = {};
				var targetObject:Object = propertyQueryObj
								
				var propertyQuery:PropertyQuery = $queries[i] as PropertyQuery

				
				if(propertyQuery.propertyTarget != null) {
					// propertyTarget exists, decode to object
					var targetQuery:Object = JSON.decode(propertyQuery.propertyTarget)
					for(j in targetQuery) {
						// get the name of the target by looking for "target:", should only be one in propertyTarget
						if(j.indexOf("target:") > -1) {
							var targetName:String = j;
							// delete the extra targetName property since we are making a reference to targetQuery
							delete targetQuery[targetName]
						}
					}
					// add the targetQuery to the propertyQueryObj
					propertyQueryObj[targetName] = targetQuery
					
					// set the current target for image, id an name to the targetQuery
					targetObject = targetQuery;

				}
				
				// add image
				targetObject["/common/topic/image"] = imageQuery["/common/topic/image"]
				
				// add required fields
				for(j in requiredFields) {
					targetObject[j] = requiredFields[j]
				}
				
				// add required criteria
				for(j in criteriaQuery) {
					propertyQueryObj[j] = criteriaQuery[j]
				}
				
				if(propertyQuery.targetCriteria != null) {
					var criteriaObject:Object = JSON.decode(propertyQuery.targetCriteria)
					for(j in criteriaObject) {
						propertyQueryObj[j] = criteriaObject[j]
					}
				}
				query[queryName + ":" + propertyQuery.property] = [propertyQueryObj]
			}
			
			return query;
		}
			
		
		private function onGetQuery (p_event:Event):void{
			var loader:URLLoader = URLLoader(p_event.target);
			var results:Object = JSON.decode(loader.data);
			/*trace(JSON.log(results.result))*/
			parseResult(results.result.query[0])
		}
		
		public function parseResult(p_result:Object):void{
			
			$result = new PivotQueryResult();
			$result.pivotQuery = this
			$result.parseResult(p_result)

			
			dispatchEvent(new Event("search"))
		}
		
		
		public function addPropertyQuery(p_label:String,p_objectType:String,p_rootTypes:Array,p_property:String,p_propertyTarget:String = null,p_targetCriteria:String = null):void{
			/*trace("addPropertyQuery = " + p_label);*/
			var propertyQuery:PropertyQuery = new PropertyQuery();
			propertyQuery.label = p_label;
			propertyQuery.objectType = p_objectType;
			propertyQuery.property = p_property;
			propertyQuery.propertyTarget = p_propertyTarget
			propertyQuery.targetCriteria = p_targetCriteria
			propertyQuery.rootTypes = p_rootTypes;
			
			propertyQuery.index = $queries.length;
			
			$queries.push(propertyQuery)
		}

		public function get result ():PivotQueryResult{
			return $result;
		}
		
		protected var $name:String;
		public function set name ( p_name:String ):void{
			$name = p_name;			
		}
		public function get name ():String{
			return $name;
		}
		protected var $id:String;
		public function set id ( p_id:String ):void{
			$id = p_id;			
		}
		public function get id ():String{
			return $id;
		}
		protected var $type:String="/common/topic";
		public function set type ( p_type:String ):void{
			$type = p_type;			
		}
		public function get type ():String{
			return $type;
		}
		public function getQuery(p_i:Number):PropertyQuery{
			return $queries[p_i]
		}

		
		protected var $resultPerPage:Number=25;
		public function set resultsPerPage ( p_resultPerPage:Number ):void{
			$resultPerPage = p_resultPerPage;			
		}
		public function get resultsPerPage ():Number{
			return $resultPerPage;
		}
	}
}
