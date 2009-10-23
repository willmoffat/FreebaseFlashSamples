//
//  EditView
//
//  Created by Ketan Anjaria on 2007-10-23.
//  Copyright (c) 2007 kidBombay. All rights reserved.
//
package com.metaweb.samples.freespin {
	import flash.display.*	
	import flash.text.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import com.adobe.serialization.json.*;
	import caurina.transitions.*;
	
	import metaliq.core.*;
	import metaliq.controls.*;
	import metaliq.events.*;
	
	import com.kidbombay.shapes.*;
	import com.kidbombay.util.*;
	import com.kidbombay.effects.*;
	
	import com.metaweb.*;
	import com.metaweb.samples.freespin.*;
	import com.metaweb.query.*;
	
	
	
	public class EditView extends MovieClip {	
		/**
		 * Creates a new EditView MovieClip instance.
		 * com.metaweb.samples.freespin.EditView
		 */
		public var bg:MovieClip;
		public var cancel_btn:MovieClip;
		public var save_btn:MovieClip;
		public var dropDown:DropDown;
		public var name_txt:TextField;
		public var autoComplete:AutoCompleteView;
		public var progressCircle:MovieClip;
		private var $autoCompleteType:String;
		
		public function EditView() { 
			super();
			cancel_btn.addEventListener("click", onClickCancel, false, 0, true);
			save_btn.addEventListener("click", onClickSave, false, 0, true);
			save_btn.enabled = false;
			dropDown.addEventListener("change", onChangeConnection, false, 0, true);
			
			autoComplete.inputField = name_txt
			// when the auto complete is executed for an item
			autoComplete.addEventListener("autoComplete", onAutoCompleteSearch, false, 0, true);
			autoComplete.addEventListener("submit", onAutoCompleteSearch, false, 0, true);
			autoComplete.rows = 5
			autoComplete.showCreateItem = true
			name_txt.addEventListener("click", onClickSearchText, false, 0, true);
			
			showProgress(false)
		}
		public function showProgress(p_show:Boolean):void{
			if(p_show) {
				progressCircle.gotoAndPlay("on")
			} else {
				progressCircle.gotoAndStop("off")
			}
		}
		
		private function onClickSave (p_event:Event):void{
			if(dropDown.list.selectedIndex == 0) return;
			
			var dataModel:Object = autoComplete.selectedDataModel;
			
			if(dataModel != null ) {
				if(dataModel.createNew) {
					dataModel.name = name_txt.text
				}
				dispatchEvent(new Event("save"))
			}
			showProgress(true);
		}
		private function onAutoCompleteSearch (p_event:Event):void{

			var dataModel:Object = autoComplete.selectedDataModel;
			if(!dataModel.createNew) {
				name_txt.text = dataModel.name;
			}
			save_btn.enabled = autoComplete.selectedDataModel != null && dropDown.list.selectedIndex > 0
		}
		
		private function onClickSearchText(p_event:Event):void{
			name_txt.setSelection(0,name_txt.length)
		}
		
		private function onChangeConnection (p_event:Event):void{
			var item = dropDown.selectedItem()
			if(item.index > 0) {
				autoComplete.type = item.dataModel.type;
				stage.focus = name_txt;
				name_txt.setSelection(0,name_txt.length)
				save_btn.enabled = autoComplete.selectedDataModel != null && dropDown.list.selectedIndex > 0
			}
		}
		
		private function onClickCancel (p_event:Event):void{
			dispatchEvent(new Event("cancel"))
			showProgress(false)
		}


		
	}
}
