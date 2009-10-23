/**
 * Copyright 2007 Metaweb Technologies, Inc.  All Rights Reserved.
 *
 * DOMEvent class
 */

//----------------------------------------------------- constructor
function DOMEvent(){}

//----------------------------------------------------- addEventHandler
DOMEvent.addEventHandler = function(target, eventType, handler){
  if(target.addEventListener){
    target.addEventListener(eventType, handler, false);
  }
  else if(target.attachEvent){
    target.attachEvent("on" + eventType, handler);
  }
  else{
    target["on" + eventType] = handler;
  }
}
//----------------------------------------------------- removeEventHandler
DOMEvent.removeEventHandler = function(target, eventType, handler){
  if(target.removeEventListener){
    target.removeEventListener(eventType, handler, false);
  }
  else if(target.detachEvent){
    target.detachEvent("on" + eventType, handler);
  }
  else{ 
    target["on" + eventType] = null;
  }
}

DOMEvent.preventDefault = function(domEvent) {
  isIE ? domEvent.returnValue = false : domEvent.preventDefault();
};

DOMEvent.stopPropagation = function(domEvent) {
  isIE ? domEvent.cancelBubble = true : domEvent.stopPropagation();
};

