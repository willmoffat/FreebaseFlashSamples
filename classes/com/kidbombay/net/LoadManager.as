//
//  LoadManager
//  Created by Ketan Anjaria on 2006-10-17.
//  Copyright (c) 2006 __MyCompanyName__. All rights reserved.
//

package com.kidbombay.net {
	import flash.display.*	
	import flash.text.*;
	import flash.events.*;
	import flash.net.*;
	
	public class LoadManager extends EventDispatcher {
		
		static private var $instance:LoadManager;
		/**
		 * Creates a new LoadManager component instance.
		 * com.kidbombay.net.LoadManager
		 */
		// put all loaders in hash by id
		static private var $threads:Object;
		public function LoadManager( caller : Function = null ) 
        {	
            if( caller != LoadManager.getInstance )
                throw new Error ("LoadManager is a Singleton class, use getInstance() instead");

            if ( LoadManager.$instance != null )
                throw new Error( "Only one LoadManager instance should be instantiated" );	

            $threads = {};
			
        }
		public static function getInstance() : LoadManager
        {
            if ( $instance == null ) {
                $instance = new LoadManager( arguments.callee );
				
			}
            return $instance;
        }
		static public function addThread(p_id:String,p_loader:URLLoader):void{
			getInstance();
			
			//trace("addThread = " + p_id);
			
			killThread(p_id);
			
			$threads[p_id] = p_loader;
		}
		static public function getThread(p_id:String):URLLoader{
			getInstance();
			
			var loader:URLLoader = $threads[p_id];
			return loader;
		}
		static public function killThread(p_id):void{
			//trace("killThread = " + p_id);
			getInstance();
			
			if($threads[p_id] != null) {
				//trace("   killThread "+ p_id)
				var existingLoader:URLLoader = $threads[p_id];
				existingLoader.close();
				delete $threads[p_id];
			}
		}
		
	}
}