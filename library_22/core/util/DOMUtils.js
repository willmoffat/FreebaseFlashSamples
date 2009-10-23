/**
 * Copyright 2006-2007 Metaweb Technologies, Inc.  All Rights Reserved.
 *
 * DOMUtils class
 * alee@metaweb.com
 * mark@metaweb.com
 * STATIC utilities for accessing DOM information
 */

//----------------------------------------------------- DOMUtils
function DOMUtils() {}

//----------------------------------------------------- getElementDimension
DOMUtils.getElementDimension = function(element) {
  return {w:element.offsetWidth, h:element.offsetHeight};
}

//----------------------------------------------------- getElementLocation
DOMUtils.getElementLocation = function(element) {
  var x = 0;
  var y = 0;
  var current = element;
  while (current) {
    x += current.offsetLeft;
    y += current.offsetTop;
    
    current = current.offsetParent;
  }
  return {x:x, y:y};
}

//----------------------------------------------------- docScrollLeft
DOMUtils.docScrollLeft = function() {
  if ( window.pageXOffset )
    return window.pageXOffset;
  else if ( document.documentElement && document.documentElement.scrollLeft )
    return document.documentElement.scrollLeft;
  else if ( document.body )
    return document.body.scrollLeft;
  else
    return 0;
}

//----------------------------------------------------- docScrollTop
DOMUtils.docScrollTop = function() {
  if ( window.pageYOffset )
    return window.pageYOffset;
  else if ( document.documentElement && document.documentElement.scrollTop )
    return document.documentElement.scrollTop;
  else if ( document.body )
    return document.body.scrollTop;
  else
    return 0;
}
//----------------------------------------------------- getElementStyle
// propertyObjName == "borderLeftWidth"
// propertyCSSName == "border-left-width"
DOMUtils.getElementStyle = function(elem, style){
  var computedStyle;
  if (typeof elem.currentStyle != 'undefined') { 
    computedStyle = elem.currentStyle; 
  }
  else { 
    computedStyle = document.defaultView.getComputedStyle(elem, null); 
  }
  return computedStyle[style];
}

/*
//----------------------------------------------------- getStyle
function getStyle(element, styleAttribute){
  var style;
  if(window.getComputedStyle) style = window.getComputedStyle(element,null)[styleAttribute];
  else if(element.currentStyle) style = element.currentStyle[styleAttribute];
  return style;
}
*/

//----------------------------------------------------- setElementStyle
DOMUtils.setElementStyle = function(element, styleString){
  if(isIE) element.style.setAttribute("cssText", styleString);
  else element.setAttribute("style", styleString);
}

//----------------------------------------------------- getWindowSize
// @return Object {w:Number, h:Number}
DOMUtils.getWindowSize = function() 
{
  var myWidth = 0;
  var myHeight = 0;
  if(typeof(window.innerWidth) == 'number' ) 
  {
    //Non-IE
    myWidth = window.innerWidth;
    myHeight = window.innerHeight;
  } 
  else if(document.documentElement &&
          (document.documentElement.clientWidth || 
           document.documentElement.clientHeight)) 
  {
    //IE 6+ in 'standards compliant mode'
    myWidth = document.documentElement.clientWidth;
    myHeight = document.documentElement.clientHeight;
  } 
  else if(document.body && 
          (document.body.clientWidth || document.body.clientHeight)) 
  {
    //IE 4 compatible
    myWidth = document.body.clientWidth;
    myHeight = document.body.clientHeight;
  }
  
  return ({w:myWidth, h:myHeight});
}


//----------------------------------------------------- getWindowScrollPos
// @return Object {x:Number, y:Number}
DOMUtils.getWindowScrollPos = function() 
{
  var scrOfX = 0;
  var scrOfY = 0;
  if(typeof(window.pageYOffset) == 'number') 
  {
    //Netscape compliant
    scrOfY = window.pageYOffset;
    scrOfX = window.pageXOffset;
  }
  else if(document.body && 
          (document.body.scrollLeft || document.body.scrollTop)) 
  {
    //DOM compliant
    scrOfY = document.body.scrollTop;
    scrOfX = document.body.scrollLeft;
  }
  else if(document.documentElement &&
          (document.documentElement.scrollLeft || 
           document.documentElement.scrollTop)) 
  {
    //IE6 standards compliant mode
    scrOfY = document.documentElement.scrollTop;
    scrOfX = document.documentElement.scrollLeft;
  }
  return ({x:scrOfX, y:scrOfY});
}



//----------------------------------------------------- formSubmit
// data is an object of name:value pairs 
// ex: data = {name1:"value one","another name":"2"}
// if method = "post" submit using post, else get
// NOTE: An interesting tidbit, this only supports non-multipart
// forms since we found out that cases where you want multipart like
// <input type='file'> have security issues and we can use this method
// to programmatically submit forms.
DOMUtils.formSubmit = function(url, data, method){
  var formFields = "";
  for(var item in data){
    formFields += "<textarea name='"+ item +
                  "'>" + data[item] + "</textarea>";
  }
  var form = document.createElement("form");
  form.setAttribute("action",url);
  if(method && method.toLowerCase()!="post") method = "get";
  form.setAttribute("method",method);
  form.innerHTML = formFields;
  document.body.appendChild(form);
  form.submit();
}

// ---------------------------------------------------------- getChildNode
// @param node:Node
// @param nodeName:String
DOMUtils.getChildNode = function(node, nodeName) {
  var nodes = node.getElementsByTagName(nodeName);
  if (nodes.length > 0) {
    return (nodes[0]);
  }
  Debug.error("[DOMUtils.getChildNode] node not found:", nodeName);
  return (null);
};

// ---------------------------------------------------------- getChildNodes
//
// Returns a copy of the nodeList returned by getElementsByTagName to
// get around the fact that the nodeList returned by
// getElementsByTagName is "live" (or changes as the underlying
// document is modified).
//
// @param node:Node 
// @param nodeName:String
DOMUtils.getChildNodes = function(node, nodeName) {
  var nodes = node.getElementsByTagName(nodeName);
  var res = new Array();
  for (var i=0,l=nodes.length; i<l; i++){
    res[i] = nodes[i];
  }
  return (res);
};

// ---------------------------------------------------------- getChildNodeText
// @param node:Node
// @param nodeName:String
DOMUtils.getChildNodeText = function(node, nodeName) {
  var text;
  var node = DOMUtils.getChildNode(node, nodeName);
  return (DOMUtils.getNodeText(node));
};

// ---------------------------------------------------------- setChildNodeText
// @param node:Node
// @param nodeName:String
// @param text:String
DOMUtils.setChildNodeText = function(node, nodeName, text) {
  var node = DOMUtils.getChildNode(node, nodeName);
  DOMUtils.setNodeText(node, text);
};


// ---------------------------------------------------------- getNodeText
// @param node:Node
DOMUtils.getNodeText = function(node) {
  var text = null;
  if (node != null && node.firstChild){
    text = node.firstChild.nodeValue;
  }
  if (text == undefined || text == null){
    text = "";
  }
  return (text);
};

// ---------------------------------------------------------- setNodeText
// @param node:Node
// @param text:String
DOMUtils.setNodeText = function(node, text) {
  if (node != null) {
    for (var i=node.childNodes.length-1; i >=0; i--) {
      node.removeChild(node.childNodes[i]);
    }
    node.appendChild(node.ownerDocument.createTextNode(text));
  }
};
