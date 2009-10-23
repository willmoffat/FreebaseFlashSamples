/**
 * Copyright 2007 Metaweb Technologies, Inc.  All Rights Reserved.
 *
 * ///////////////////
 * global variables //
 * ///////////////////
 */
/////////////////////
// Cookie handling //
/////////////////////
//------------------------------------------------------------------ readCookie
// returns the value of a cookie given the cookie name.
function readCookie(name){
  var cookieValue = "";
  name += "=";
  if(document.cookie.length > 0){ 
    var offset = document.cookie.indexOf(name);
    if(offset != -1){ 
      offset += name.length;
      var end = document.cookie.indexOf(";", offset);
      if(end == -1) end = document.cookie.length;
      cookieValue = document.cookie.substring(offset, end);
    }
  }
  return cookieValue;
}

//----------------------------------------------------------------- writeCookie
// a simple function to write a cookie. The "hours" parameter is 
// optional - if it is left out, the cookie value will expire when 
// the user's browser session ends
function writeCookie(name, value, hours){
  var expire = "";
  if(hours != null){
    expire = new Date((new Date()).getTime() + hours * 3600000);
    expire = "; expires=" + expire.toGMTString();
  }
  document.cookie = name + "=" + value + expire;
}

var bmsg = "It appears you're using an unsupported browser. We recommend one of the following: Firefox 1.5+, Internet Explorer 6.0+, Safari 2.0+";
var bv = -1;
var browserChecked = "1" == readCookie("mwbrowserchecked");
var isFirefox = false;
var isIE = false;
var isIE6 = false;
var isIE7 = false;
var isSafari = false;
var userAgent = navigator.userAgent.toLowerCase();
if (/firefox\/(\d+(?:\.\d+))/.test(userAgent)) { 
  isFirefox = true;
  bv = Number(RegExp.$1);
  if (!browserChecked && bv < 1.5) {   // firefox/1.5+
    alert(bmsg);
    writeCookie("mwbrowserchecked", "1", 168);
  }
}
else if (/safari\/(\d+(?:\.\d+))/.test(userAgent)) {  
  isSafari = true;
  bv = Number(RegExp.$1);
  if (!browserChecked & bv < 412) {   // safari/412+
    alert(bmsg);
    writeCookie("mwbrowserchecked", "1", 168);
  }
}
else if (/msie (\d+(?:\.\d+))/.test(userAgent)) { 
  isIE = true;
  bv = Number(RegExp.$1);
  isIE6 = bv >= 6 && bv < 7;
  isIE7 = bv >= 7;
  if (!browserChecked && bv < 6) {     // msie 6.0+
    alert(bmsg);
    writeCookie("mwbrowserchecked", "1", 168);
  }
}
else if (!browserChecked){
  alert(bmsg);
  writeCookie("mwbrowserchecked", "1", 168);
}


///////////////////
// check for XHR //
///////////////////
if(typeof XMLHttpRequest == "undefined" && typeof ActiveXObject != "undefined"){
  XMLHttpRequest = function(){return (new ActiveXObject("MSXML2.XmlHttp"));};
}
if(!browserChecked && typeof XMLHttpRequest == "undefined"){
  // TODO: handle non AJAX capable browsers
  alert(bmsg);
  writeCookie("mwbrowserchecked", "1", 168);
}

////////////////////
// empty function //
////////////////////
function NO_OP() {};

/////////////////////
// generate pageID //
/////////////////////
function pageID () {
  // PageID = location.href + 8 hexes;
  var NUM_HEXES = 8;
  var st = "0A";
  var zero_code = st.charCodeAt (0);
  var a_code = st.charCodeAt (1);
  var key = "";
  for (var i = 0; i < NUM_HEXES; i++) {
    var r = Math.floor (16 * Math.random ());
    if (r >= 10)
      key += String.fromCharCode (a_code + (r - 10));
    else
      key += String.fromCharCode (zero_code + r);
  }
  
  var uri = window.location.pathname + window.location.search;
  //var uri = window.location.href;
  return key+uri;
}

// Generate a fresh pageID on each page HTML page load and put it out as a cookie
// so that all resource fetches and XHR requests can be reconciled to this original
// pageload. Store in global variable BrowserPID in case other JS want to reference it.
writeCookie("BrowserPID", pageID());

var g_transactionIdList = new Array();
if(typeof viewTransactionIdLogURL=="undefined") viewTransactionIdLogURL = "";
var g_windowLoaded = false;

///////////////////////////////////////////////////////////////
// Utility to get arguments from window.location querystring //
///////////////////////////////////////////////////////////////
var WINDOW_ARGS = {};  // map of name:value in the query string
var q = window.location.search;
if(q && q.length > 0){
  q = q.substring(1);
  var vars = q.split("&");
  for(var i=0, len=vars.length ; i<len; i++){
    var index = vars[i].indexOf("=");
    if(index != -1){
      var name = vars[i].substring(0, index);
      var value = vars[i].substring(index+1);
      if (! (name in WINDOW_ARGS))
          WINDOW_ARGS[name] = [];
      WINDOW_ARGS[name].push(decodeURIComponent(value));
    }
  }
}
//------------------------------------------------------------- arg
// @param multiple:Boolean - whether or not to return an array of all
//                           arguments, or return a single argument
function arg(name, multiple) {
    if (name in WINDOW_ARGS)
        if (multiple)
            return WINDOW_ARGS[name];
        else
            return WINDOW_ARGS[name][0];
    else
        if (multiple)
            return [];
        else
            return null;
};

//////////////////////////////////////////////////////////////////////////////////////
// A wrapper around firebug's console, enabled by cookie or debug=true in url query //
//////////////////////////////////////////////////////////////////////////////////////
function Debug(){};
Debug.METHODS = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml",
 "group", "groupEnd", "time", "timeEnd", "count", "trace", "profile", "profileEnd"];

//----------------------------------------------------- enable
Debug.enable = function(debug) {
  debug = debug && "console" in window;
  for(var i=0, len=Debug.METHODS.length; i<len; i++) {
    var m = Debug.METHODS[i]; 
    switch(m) {
      // always print error
      case "error":
      case "trace":
        break;
      default:
        if (debug) {
          Debug[m] = window.console[m];
        }
        else {
          Debug[m] = NO_OP;
        }
        break;
    };    
  }
};

//----------------------------------------------------- error
Debug.error = function() {
  if (!"console" in window) return; 
  window.console.error.apply(window.console, arguments);
};

//----------------------------------------------------- trace
Debug.trace = function() {
  if (!"console" in window) return; 
  window.console.trace();
};
var debugCookie = readCookie("debug");
var debug = (debugCookie.toLowerCase()=="true" ? true : false);
debug = ("true" == arg("debug")) || debug;
Debug.enable(debug);
//
// dae: Please make this work in all browsers so Debug.trace can call this
//
//------------------------------------------------------------- formatStack
function formatStack(start, ex) {
  if (ex != undefined)
    start = 0;
  else if (start === undefined)
    start = 1;
  
  if (ex==undefined)
    try {
      // garbage
      xyz[pdq] = lakjsdflkj;
    } catch (e) {
      ex = e;
    }
  
  // only works on mozilla!
  if (typeof(ex) == "object" && 'stack' in ex) {
    var stack = ex.stack.split('\n');
    var formattedStack = [];
    for (var i=start; i<stack.length; i++) {
      var frame = stack[i].split('@');
      // sourceFile:lineNumber: declaration....
      formattedStack.push(frame[1] + ": " + frame[0].slice(0,50));
    }
    
    formattedStack = formattedStack.join("\n");
    return formattedStack;
  } else if (typeof ex == "string") {
    return "(no stack, ex was a " + typeof(ex) + "!!)";
  }
  
  return "";
}
//------------------------------------------------------------- dumpStack
function dumpStack(ex) {
  Debug.log(formatStack(2, ex));
}


//////////////////////
// include          //
//////////////////////
var DEFAULT_USE_INCLUDE = false;
if(typeof USE_INCLUDE == "undefined"){
  USE_INCLUDE = DEFAULT_USE_INCLUDE;
}
var DEFAULT_INCLUDE_PATH_PREFIX = "/library_22/";
if(typeof INCLUDE_PATH_PREFIX == "undefined"){
  INCLUDE_PATH_PREFIX = DEFAULT_INCLUDE_PATH_PREFIX;
}
var INCLUDE = {}; // keep track of includes
//--------------------------------------------------------------------- include
// @param file:String
// @returns Box
if(USE_INCLUDE){
  include = function(file){
    if(INCLUDE[file] == undefined){
      INCLUDE[file] = 0;
      file = INCLUDE_PATH_PREFIX + file;    
      var includeXHR = new XMLHttpRequest();
      includeXHR.open("GET", file, false);
      includeXHR.send(null);
      if(includeXHR.status == 200 || includeXHR.status == 0){
        try {      
            if(isIE){      
              window.execScript(includeXHR.responseText);
            }
            else {
              window.eval(includeXHR.responseText);
            }
        }
        catch (ex) {
            Debug.error("[include] error evaluating", file, ":", ex);
        }
      }
      // http error:
      else{
        Debug.error( "Problem retrieving the HTTPRequest (", file, "):",
                      includeXHR.status, includeXHR.statusText, 
                      "\n\nHere is the full response text:\n\n",
                      includeXHR.responseText);
      }
    }
    INCLUDE[file] = INCLUDE[file] + 1; // tally up total calls to includes    
  }
}
else {
  include = NO_OP;
}

//////////////////////
// inheritance      //
//////////////////////

//------------------------------------------------------------ applyNew
// @param classFunction:Function
// @param firstArg:Object
// @param args:Array
function applyNew (classFunction, args) {
  // create a dummy class with the same prototype as classFunction, so
  // we start with a valid empty class
  function K() {};
  K.prototype = classFunction.prototype;
  var result = new K();
  
  // now call the constructor with the arguments
  classFunction.apply(result, args);
  return result;
}

//------------------------------------------------------------ superConstructor
// @param instance:Object
// @param superClass:Function
// @param args:Array
function superConstructor(superClass, instance, args){
  if(args == undefined) {
    args = [];
  }
  superClass.apply(instance, args);
}
//----------------------------------------------------------------- superMethod
// @param superClass:Function
// @param instance:Object
// @param methodName:String
// @param args:Array
function superMethod(superClass, instance, methodName, args){
  if(args == undefined) {
    args = [];
  }
  return (superClass.prototype[methodName].apply(instance, args));
}
//------------------------------------------------------------- InheritanceNode
// @param clazz:Function
function InheritanceNode(clazz){
  this._clazz = clazz;
  this._children = new Array();
}
InheritanceNode.prototype.getClass = function(){ 
  return (this._clazz); 
}
InheritanceNode.prototype.getChildren = function(){ 
  return (this._children); 
}
InheritanceNode.prototype.addChild = function(c){ 
  this._children.push(c); 
}
InheritanceNode.prototype.toString = function(){
  if ('_inheritanceClassName' in this)
      return this._inheritanceClassName;
  
  var name = [this._clazz];
  name.push(" <[ ");
  var children = this._children;
  for(var i=0, l=children.length; i<l; i++){
      name.push(children[i].toString());
  }
  name.push(" ]> ");
  
  var className = this._inheritanceClassName = name.join("");
  
  return className;
}
//------------------------------------------------------------- InheritanceTree
// @param clazz:Function
function InheritanceTree(clazz){
  this._root = new InheritanceNode(clazz);
  InheritanceTree.createTree(this._root);
}
var ObjectMap = [];
InheritanceTree.createTree = function(node){
  var clazz = node.getClass();
  if(clazz.superClass != undefined){
    for(var i=0, l=clazz.superClass.length; i<l; i++){
      var superClass = clazz.superClass[i];
      if (!superClass) {
          console.log("Couldn't find superClass for " + clazz.superClass[i]);
      }
      var childNode = new InheritanceNode(superClass);
      node.addChild(childNode);
      InheritanceTree.createTree(childNode);
    }
  }
}
InheritanceTree.prototype.getRoot = function(){ 
  return (this._root); 
}
InheritanceTree.prototype.isCyclic = function(){
  var visitor = new GraphVisitor();
  this.dfs(this.getRoot(), visitor, [], []);
  return (visitor.detectedCycle());
}
InheritanceTree.prototype.dfs = function(node, visitor, preOrder, postOrder){
  // mark node as gray
  visitor.startVisit(node);
  preOrder.push(node);
  var children = node.getChildren();
  for(var i=0, l=children.length; i<l; i++){
    var child = children[i];
    if(visitor.isWhite(child)){
      this.dfs(child, visitor, preOrder, postOrder);
    }
    else if(visitor.isGray(child)){
      visitor.addCycle(child);
    }
  }
  postOrder.push(node);
  // mark node as black
  visitor.finishVisit(node);
}
//---------------------------------------------------------------- GraphVisitor
/**
 * As commonly practiced, the dfs and bfs algorithms color the
 * verices white, gray, and black - white means the vertex has not
 * been visited by the algorithm, gray means the vertex has been
 * discovered and in the queue for processing, and black means the
 * algorithm has finished visiting the vertex (dequeued and
 * expanded).
 */
function GraphVisitor(){
  this._visitStarted = {};
  this._visitFinished = {};
  this._cycles = new Array();
}

GraphVisitor.visitorKey = 0;
GraphVisitor.getKey = function(node) {
    // annotate the node with a key
    var key;
    if ('_visitorKey' in node)
        key = node._visitorKey;
    else
        key = node._visitorKey = GraphVisitor.visitorKey++;
    return key;
};

GraphVisitor.prototype.startVisit = function(node){
  var key = GraphVisitor.getKey(node);
  this._visitStarted[key] = true;
}
GraphVisitor.prototype.finishVisit = function(node){
  var key = GraphVisitor.getKey(node);
  this._visitFinished[key] = true;
}
GraphVisitor.prototype.isWhite = function(node){
    var key = GraphVisitor.getKey(node);
    return (!((key in this._visitStarted) ||
              (key in this._visitFinished)));
}
GraphVisitor.prototype.isGray = function(node){
    var key = GraphVisitor.getKey(node);
    return ((key in this._visitStarted) &&
            !(key in this._visitFinished));
}
GraphVisitor.prototype.isBlack = function(node){
    var key = GraphVisitor.getKey(node);
    return ((key in this._visitStarted) &&
            (key in this._visitFinished));
}
GraphVisitor.prototype.addCycle = function(node){
  this._cycles.push(node);
}
GraphVisitor.prototype.detectedCycle = function(){
  return (this._cycles.length > 0);
}
GraphVisitor.prototype.arrayContains = function(arr, item){
  for(var i=0, len=arr.length; i<len; i++){
  	if(arr[i] == item){
  	  return true;
  	}
  }
  return false;
};
//------------------------------------------------------------ setupInheritance
function setupInheritance(clazz){
  if(clazz._inheritInitialized == undefined){
    var tree = new InheritanceTree(clazz);
    if(CHECK_CYCLIC_INHERITANCE && tree.isCyclic()){
      Debug.error("Cannot initialize inheritance tree for ",
            clazz, " because it contains cycle");
      return;
    }
    setupInheritanceRecursive(tree.getRoot());
  }
}

//--------------------------------------------------- setupInheritanceRecursive
function registerClass(clazz, className) {
    ObjectMap[className] = clazz;
    clazz._className = clazz;
}

//--------------------------------------------------- setupInheritanceRecursive
function setupInheritanceRecursive(inode){
  var clazz = inode.getClass();
  if(clazz._inheritInitialized == undefined){
    var parent = inode;
    var children = parent.getChildren();
    for(var i=0, l=children.length; i<l; i++){
      var child = children[i];
      setupInheritanceRecursive(child);
      inherit(parent.getClass(), child.getClass());
    }
    clazz._inheritInitialized = true;
  }
}
//-------------------------------------------------------------- inheritClasses
// @param superClass:Function
// @param classList:Array
function inheritClasses(superClass, classList){
  classList.push(superClass);
  if(typeof superClass._superClasses == "object"){
    for(var i=0; i < superClass._superClasses.length; i++){
      inheritClasses(superClass._superClasses[i], classList);
    }
  }
}
//--------------------------------------------------------------------- inherit
// @param subClass
// @param superClass
function inherit(subClass, superClass){
  if(subClass.prototype.constructor._superClasses == undefined){
    subClass.prototype.constructor._superClasses = new Array();
  }
  inheritClasses(superClass, subClass.prototype.constructor._superClasses);
  for(var property in superClass.prototype){
    if(subClass.prototype[property] == undefined){
      subClass.prototype[property] = superClass.prototype[property];
    }
  }
}


///////////////////////
// globals functions //
///////////////////////
 
//------------------------------------------------------------- getClassName
// @param c:Function or Function instance
function getClassName(c){
  if ('_className' in c)
      return c._className;
  var className = this.CLASS_NAME;
  if (typeof this.CLASS_NAME == "undefined" || this.CLASS_NAME == null){
    if(typeof c == "function"){
      var m = c.prototype.constructor.toString().match(/function\s*([^\(\)\s]+)/);
      className = (m && m.length == 2 ? m[1] : undefined);
    }
    else if(typeof c == "object"){
      var m = c.constructor.toString().match(/function\s*([^\(\)\s]+)/);
      className = (m && m.length == 2 ? m[1] : undefined);
    }
//    Debug.warn("Please set the CLASS_NAME variable for", className);
  }
  this._className = className;
  return className;
}

//------------------------------------------------------------- showMembers
// this is a debug helper - mark
function showMembers(o){
  var output = "Object:";
  for(var item in o){
    if(o!=Object.prototype && typeof Object.prototype[item] != "undefined") continue;
    var value = (typeof o[item] != "function") ? o[item]:"[function]";
    output += "\n  "+item+": "+value;
  }
  return output;
}

//------------------------------------------------------------- cloneObject
function cloneObject(obj) {
  var copy = null;
  switch(typeof obj){
    case "boolean":
    case "number":
    case "string":
      copy = obj;
      break;
    case "object":
      if(obj instanceof Array){
        copy = new Array();
        for(var i=0, len=obj.length; i<len; i++){
          copy.push(cloneObject(obj[i]));
        }
      }
      else{
        if(obj==null){
          copy = null;
        }
        else{
          copy = new Object();
          for (var key in obj) {
            copy[key] = cloneObject(obj[key]);
          }
        }
      }
      break;
  }
  return copy;
};

//------------------------------------------------------------- getStyle
function getStyle(element, styleAttribute){
  var style;
  if(window.getComputedStyle) style = window.getComputedStyle(element,null)[styleAttribute];
  else if(element.currentStyle) style = element.currentStyle[styleAttribute];
  return style;
}
//------------------------------------------------------------- setStyle
function setStyle(element, styleAttribute, value){
  if(isIE) element.style.setAttribute("cssText", styleAttribute+"="+value);
  else element.style[styleAttribute] = value;
}

//------------------------------------------------------------- doLater
// delay is optional, default=0 meaning as soon as
// possible but still async
function doLater(owner, method, delay, params){
  if(delay==undefined) delay = 0;
  if(params==undefined) params = [];
  if(owner==null) owner = arguments.caller;
  var handler = function(){
    method.apply(owner, params);
  }
  return setTimeout(handler, delay);
}

//------------------------------------------------------------- wait
// for debug, TODO: this should be removed for deploy
function wait(ms){
  var start = new Date().getTime();
  var current = start;
  while((current-start) < ms){
    current = new Date().getTime();
  }
}

//------------------------------------------------------------- addWindowOnloadHandler
function addWindowOnloadHandler(handler){
  if(typeof window.addEventListener != "undefined")
    window.addEventListener("load", handler, false);
  else if(typeof window.attachEvent != "undefined"){
    window.attachEvent( "onload", handler);
  }
  else{
    var oldOnload = window.onload;
    window.onload = function(e){
      if(oldOnload != null) oldOnload(e);
      oldOnload = null;
      handler(e);
    }
  }
}

//------------------------------------------------------------- openLocation
function openLocation(loc) {
  if (loc) {
    window.location = loc;
  }
  return false;
};

//------------------------------------------------------------- reload
function reload() {
  window.location.reload();
};

//------------------------------------------------------------- createElementWithName
// This fixes IE bug with ÒSetting the ÒnameÓ attribute in Internet Explorer
// See original blog and particular comments at end where this solution was derived from
//   http://www.thunderguy.com/semicolon/2005/05/23/setting-the-name-attribute-in-internet-explorer/
// Since we add DOM events, innerHTML's problems with using innerHTML necessitated this approach
// See also problem with read/write-once with type for input elements - hence createTypedElement
//   http://alt-tag.com/blog/archives/2006/02/ie-dom-bugs/
function createNamedTypedElement(){};

try {
  var el=document.createElement( '<div name="foo">' );
  if( 'div'!=el.tagName.toLowerCase() ||
      'foo'!=el.name ){
    throw 'create element error';
  }
  createNamedTypedElement = function( tag, nameValue, typeValue ){
    var nameString = "";
    if (typeof nameValue != "undefined" && nameValue)
      nameString = 'name="' + nameValue + '"';
    var typeString = "";
    if (typeof typeValue != "undefined" && typeValue)
      typeString = 'type="' + typeValue + '"';
    return document.createElement( '<'+tag + " " +nameString + " " + typeString+'></'+tag+'>' );
  }
}catch( e ){
  createNamedTypedElement = function( tag, nameValue, typeValue ){
    var el = document.createElement( tag );
    if (typeof nameValue != "undefined" && nameValue)
      el.setAttribute('name', nameValue);
    if (typeof typeValue != "undefined" && typeValue)
      el.setAttribute('type', typeValue);
    return el;
  }
}

// for dev debugging only:
var gcn = getClassName;
var sm = showMembers;
