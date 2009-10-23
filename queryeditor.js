/**
 * Copyright 2006-2007 Metaweb Technologies, Inc.  All Rights Reserved.
 *
 * This started as a pet project and then magically became
 * real, so the code was not written to be maintainable.
 * This will soon be re-written for real. - Mark
 *
 * mark@metaweb.com
 */

var SERVER = "http://www.freebase.com";
var LOJSON_READ_PATH = "/api/service/loread";
var LOJSON_WRITE_PATH = "/api/service/lowrite";
var HIJSON_READ_PATH = "/api/service/mqlread";
var HIJSON_WRITE_PATH = "/api/service/mqlwrite";
var readPath = HIJSON_READ_PATH;
var writePath = HIJSON_WRITE_PATH;

var LOWJSONEXAMPLES = "lojq-examples.json";
var HIGHJSONEXAMPLES = "hijq-examples.json";

//----------------------------------------------------- main
var isSafari = (navigator.userAgent.toLowerCase().indexOf("applewebkit") > -1);
var isIE = (navigator.userAgent.toLowerCase().indexOf("msie") > -1);
var status, messages, result, jsonResult, examples, queryText, queryState, treeView, stats;

window.onload = function(){
  status = makeContainer("status");
  messages = makeContainer("messages");
  result = makeContainer("result","json result");
  treeView =  makeContainer("treeView","tree result");
  jsonResult = makeContainer("jsonResult","full json result");
  //jsonResult.expand(false);
  stats = makeContainer("stats");

  var top = document.getElementById("queryText");
  var examplesDiv = document.getElementById("examples");
  examples = new Examples(examplesDiv, top);

  initContainers("none");

  queryText = document.getElementById("queryText");
  queryText.focus();
//  radios = document.getElementsByName("hiLoSwitch");
//  for (i = 0; i < radios.length; i++) {
//    if (radios[i].checked) {
//      syntaxSwitch(radios[i].value);
//      break;
//    }
//  }
  syntaxSwitch("hi");
  window.onresize();
};
window.onresize = function(){
  examples.resize();
  if(isIE || isSafari) return;
// begin FF resize layout bug fix (hack)
  if(!status) return;
  var se,me,re,je,te;
  se = status._expanded;
  status.expand(false);
  me = messages._expanded;
  messages.expand(false);
  re = result._expanded;
  result.expand(false);
  je = jsonResult._expanded;
  jsonResult.expand(false);
  ee = examples._expanded;
  examples.expand(false);
  te = treeView._expanded;
  treeView.expand(false);
  doLater(null, reloadBegin, 10, [se,me,re,je,ee,te]);
};
function reloadBegin(se,me,re,je,ee,te){
  document.body.style.height="90%";
  doLater(null, reloadMid, 10, [se,me,re,je,ee,te]);
}
function reloadMid(se,me,re,je,ee,te){
  document.body.style.height="auto";
  doLater(null, reloadEnd, 10, [se,me,re,je,ee,te]);
}
function reloadEnd(se,me,re,je,ee,te){
  status.expand(se);
  messages.expand(me);
  result.expand(re);
  jsonResult.expand(je);
  examples.expand(ee);
  treeView.expand(te);
}
// end resize layout bug fix (hack)

//----------------------------------------------------- makeContainer
function makeContainer(id, title){
  if(title==null) title = id;
  var div = document.getElementById(id);
  if(id == "treeView") return new TreeContainer(div);
  return new Container(div, title);
}
//----------------------------------------------------- initContainers
function initContainers(text){
  status.show(false);
  messages.show(false);
  result.show(true);
  treeView.show(true);
  var defaultColor = "#bbb";
  status.setContent(text, defaultColor);
  messages.setContent(text, defaultColor);
  result.setContent(text, defaultColor);
  treeView.setContent(text, defaultColor);
  jsonResult.setContent(text, defaultColor);
  stats.setContent(text, defaultColor);
}


/////////////////////////////////////////////////////// Examples

//----------------------------------------------------- loadExamples
function loadExamples(){
  var examples =  (queryState == "hi") ? HIGHJSONEXAMPLES : LOWJSONEXAMPLES;
  new HTTPRequest(examples, onExamplesLoaded);
}
//----------------------------------------------------- onExamplesLoaded
function onExamplesLoaded(text, xml){
  examples._json = eval("("+text+")");
  examples.setContent(reloadExamples(true));
  /*if(isSafari){
    examples.expand(false);
    examples.expand(true);
  }*/
}
//----------------------------------------------------- reloadExamples
function reloadExamples(createCategories) {
  if (createCategories) 
    examples._categories = new Array();
  var html = "<ul>";
  var json = examples._json;
  for(var i=0, len=json.length; i<len; i++){
    var note = json[i].note;
    var query;
    if (queryState == "lo" && checkCategories(json[i].categories)) {
      query = JSONUtils.format(json[i].query);
      html += "<li><div class='note' onclick='getExample(\""+escape(query)+"\")'>"+note+"</div></li>";
    }
    else if (checkCategories(json[i].categories)){
      // Need to keep the "query" for hijson
      if (json[i].query) {
        query = JSONUtils.format({ 'query': json[i].query });
        html += "<li><div class='note' onclick='getExample(\""+escape(query)+"\")'>"+note+"</div></li>";
      }
      else
        html += "<li><div class='comment'>"+note+"</div></li>";
    }
    if (checkCategories && json[i].categories) {
      for (var j=0, clen=json[i].categories.length; j<clen; j++) {
        if (examples._categories[json[i].categories[j]] == undefined)
          examples._categories[json[i].categories[j]] = true;
      }
    }
  }
  html += "</ul>";
  return html;
}
//----------------------------------------------------- checkCategories
function checkCategories(categories){
  for (var i=0, len=categories.length; i<len; i++) {
    if (examples._categories[categories[i]])
      return true;
  }
}
//----------------------------------------------------- getExample
function getExample(query){
  var queryText = document.getElementById("queryText");
  queryText.value = unescape(query);
}

/////////////////////////////////////////////////////// runQuery

//----------------------------------------------------- runQuery
function runQuery(write, get){
  if(write){
    if(!confirm("Are you sure you want to WRITE?")) return;
  }
  if(write!=1) write = 0;
  initContainers("running query...");

  var query = queryText.value;//document.getElementById("queryText").value;

  // unformat:
  var re = /\n+/g;
  query = query.replace(re," ");
	
  // check syntax:
  var json;
  try{
    json = eval("("+query+")");
  }
  catch(e){
    json = '{status:"ERROR",messages:[{text:"'+e+'"}],result:"none",jsonResult:"none"}';
    // dolater so that the "initContainers" above 
    // visibly takes affect first:
    doLater(null, onRequestLoaded, 100, [json, null, 0]);
    return;
  }

  query = "q="+ encodeURIComponent(query);
alert(query);
  var queryPath = readPath;
  if(write){
    queryPath = writePath;
  }

  if(get) httpRequest = new HTTPRequest(queryPath+"?"+query, onRequestLoaded);
  else httpRequest = new HTTPRequest(queryPath, onRequestLoaded, query);
  //httpRequest.startTime = new Date();
}
//----------------------------------------------------- onRequestLoaded
function onRequestLoaded(text, xml, requestStatus){
  //httpRequest.totalTime = (new Date()) - httpRequest.startTime;

  var RED = "#d56", ORANGE="#f80", BLACK="#20222e";
  var json,statusStr,messagesStr,resultStr,error=false;
  // no http error:
  if(requestStatus==200 || requestStatus==0){
    try{
      json = eval("("+text+")");
    }
    // probable json syntax error:
    catch(e){
      json = {status:"ERROR",messages:[{text:e}],result:"none"};
    }
  }
  // http error:
  else{
    json = {status:"ERROR",messages:[{text:text}],result:"none"};
  }

  // check for errors:
  var color;
  error = (json.status.indexOf("200")==-1);
  if(error){
    color = RED;
    status.show(true);
    status.expand(true);
    messages.show(true);
    messages.expand(true);
    result.show(false);
    treeView.show(false);
    stats.show(false);
  }
  else{
    color = BLACK;
    status.show(false);
    messages.show(false);
    result.show(true);
    treeView.show(true);
    stats.show(true);
  }
  // get/format strings:
  statusStr = JSONUtils.format(json.status);
  if(error) {
      messagesStr = json.messages[0].text;
      for (var i in json.messages[0].stack) {
          var frame = json.messages[0].stack[i];
          var source = frame.source;
          var line = frame.line;
          var func = frame.func;
          var file = frame.file;
          messagesStr += "<div class='messageItem'>file: " + file + "<br>line: " + line + 
                         " in function '" + func + "'<div class='messageItemSource'>" + 
                         source + "</div></div>"
      }
  }
  resultStr = JSONUtils.format(json.result);
  if(resultStr==null) resultStr = "none";
  resultStr = formatNoPreTag(resultStr);
  text = formatNoPreTag(text);
  // setContent:
  status.setContent(statusStr,color);
  messages.setContent(messagesStr,color);
  result.setContent(resultStr,BLACK);
  jsonResult.setContent(text,BLACK);
  treeView.setContent("building tree...","#bbb");
  //if(!error) doLater(null, buildTree, 0, [json.result]);
  if(!error) treeView.buildTree(json.result);


  var tid = httpRequest._request.getResponseHeader("X-Metaweb-TID");
  var cost = httpRequest._request.getResponseHeader("X-Metaweb-Cost");

  var info = "request time: " + httpRequest.requestTime + " ms<br><br>X-Metaweb-Cost:<br>" + cost +
    "<br><br>X-Metaweb-TID:<br><a href='"+viewTransactionIdLogURL+"?tid="+encodeURIComponent(tid)+"'>" + tid + "</a>";
  stats.setContent(info,BLACK);

  // always expand atleast one container as 
  // feedback that a result has loaded:
  if(!error && !treeView._expanded && !result._expanded && !stats._expanded && !jsonResult._expanded){
    stats.expand(true);
  }


}
/*function buildTree(data){
  treeView.setData(data);
}*/

//----------------------------------------------------- formatNoPreTag
function formatNoPreTag(string){
  var re = /  /g;
  string = string.replace(re,"&nbsp; ");
  re2 = /\n/g;
  string = string.replace(re2,"<br>");
  return string;
}
//----------------------------------------------------- format
function format(){
  var query = document.getElementById("queryText");
  var json;
  try{ 
    json = eval("("+query.value+")");
  }
  catch(e){ alert(e); return; }

  var queryText = JSONUtils.format(json);
  query.value = queryText;
}
//----------------------------------------------------- unformat
function unformat(){
  var query = queryText.value;

  // eval first to catch syntax errors:
  try{ eval("("+query+")"); }
  catch(e){ alert(e); return; }

  var re = /\n+/g;
  query = query.replace(re," ");
  re = /\s+/g;
  query = query.replace(re," ");

  /* don't use format because it removes all spaces which screws with word wrap
  var json = eval("("+query+")");
  query = JSONUtils.format(json,true);*/

  queryText.value = query;
}
//----------------------------------------------------- clearAll
function clearAll(){
  document.getElementById("queryText").value = "";
  initContainers("none");
}

//----------------------------------------------------- syntaxSwitch
function syntaxSwitch(state){
  var hiButtonLabel = document.getElementById("hiButtonLabel");
  var loButtonLabel = document.getElementById("loButtonLabel");
  if(state=="hi"){
    readPath = SERVER + HIJSON_READ_PATH;
    writePath = SERVER + HIJSON_WRITE_PATH;
    var hiButton = document.getElementById("hiButton");
    hiButton.checked = true;
    CSS.addClass(hiButtonLabel,"selected");
    CSS.removeClass(loButtonLabel,"selected");
  }
  else if(state=="lo"){
    readPath = SERVER + LOJSON_READ_PATH;
    writePath = SERVER + LOJSON_WRITE_PATH;
    var loButton = document.getElementById("loButton");
    loButton.checked = true;
    CSS.addClass(loButtonLabel,"selected");
    CSS.removeClass(hiButtonLabel,"selected");
  }
  queryState = state;
  loadExamples();
}



// //////////////////////////////////////////////////// 
// //////////////////////////////////////////////////// core
// //////////////////////////////////////////////////// 

//----------------------------------------------------- addTag
function addTag(tagName, parentElement, beforeIndex){
  var tag = document.createElement(tagName);
  if(beforeIndex!=undefined){
    var targetNode = parentElement.childNodes[beforeIndex];
    if(targetNode) parentElement.insertBefore(tag, targetNode);
    else parentElement.appendChild(tag);
  }
  else parentElement.appendChild(tag);
  return tag;
}
//----------------------------------------------------- showMembers
function showMembers(o){
  var output = "Object:";
  for(var item in o){
    if(o!=Object.prototype && typeof Object.prototype[item] != "undefined") continue;
    var value = (typeof o[item] != "function") ? o[item]:"[function]";
    output += "\n  "+item+": "+value;
  }
  return output;
}

//----------------------------------------------------- isEmpty
function isEmpty(object){
  if(typeof object != "object") return;
  for(var item in object) return false;
  return true;
}

//----------------------------------------------------- CSS class
function CSS(){}
//----------------------------------------------------- addClass
CSS.addClass = function(element, classString){
  CSS.removeClass(element,classString);
  element.className += " "+classString;
}
//----------------------------------------------------- removeClass
CSS.removeClass = function(element, classString){
  var str = "\\b"+classString+"\\b";
  var re = new RegExp(str, "g");
  element.className = element.className.replace(re, "")
}

// //////////////////////////////////////////////////// 
// //////////////////////////////////////////////////// Container class
// //////////////////////////////////////////////////// 

//----------------------------------------------------- constructor
function Container(div, title){
  if(div==undefined) return;
  this._body = div;

  this._header = addTag("div",this._body);
  this._header.className = "header";

  this._expandButton = addTag("div",this._header);
  this._expandButton.className = "expandButton";

  this._title = addTag("div",this._header);
  this._title.className = "title";

  this._content = addTag("div",this._body);
  this._content.className = "content";

  this._expanded = true;

  var owner = this;
  var onClick = function(e){ owner._onExpandButton(e); };
  DOMEvent.addEventHandler(this._expandButton, "click", onClick);

  if(title!=undefined) this.setTitle(title);

  var expandedState = readCookie("Container_"+escape(this.title));
  (expandedState=="true")?expandedState=true:expandedState=false;

  this.expand(expandedState);
}
//----------------------------------------------------- setTitle
Container.prototype.setTitle = function(text){
  this._title.innerHTML = text;
  this.title = text;
}
//----------------------------------------------------- setContent
Container.prototype.setContent = function(html, color){
  this._content.innerHTML = html;
  this._content.style.color = color;
}
//----------------------------------------------------- setContent
Container.prototype.getContent = function(){
  return this._content.innerHTML;
}
//----------------------------------------------------- expand
Container.prototype.expand = function(state){
  if(state!=undefined) this._expanded = state;
  else this._expanded = !this._expanded;
  if(this._expanded){
    this._expandButton.innerHTML = "&#9660;";
    this._content.style.display = "block";
    this._expandButton.setAttribute("title", "click to collapse");
  }
  else{
    this._expandButton.innerHTML = "&#9658;";
    this._content.style.display = "none";
    this._expandButton.setAttribute("title", "click to expand");
  }
}
//----------------------------------------------------- _onExpandButton
Container.prototype._onExpandButton = function(){
  this.expand();
  writeCookie("Container_"+escape(this.title),this._expanded,99999);
}
//----------------------------------------------------- show
Container.prototype.show = function(state){
  if(state) this._body.style.display = "block";
  else this._body.style.display = "none";
}

// //////////////////////////////////////////////////// 
// //////////////////////////////////////////////////// Examples class
// //////////////////////////////////////////////////// 

function Examples(div, topElement){
  Container.call(this, div, "examples");
  this._topElement = topElement;
  this._thumb = addTag("div", this._body, 0);
  this._thumb.className = "thumb";
  this._thumb.innerHTML = '<div class="grip"><div></div></div><div class="grip"><div></div></div><div class="grip"><div></div></div>';
  var owner = this;
  var onMouseDown = function(e){ owner._onMouseDown(e); };
  DOMEvent.addEventHandler(this._thumb, "mousedown", onMouseDown);
  this._initialized = true;
  this.expand(true);
  
  this._toolbar = addTag("div", this._title);
  this._toolbar.className = "toolbar";
  var item = addTag("div", this._toolbar);
  item.className = "filter";
  this._filterButton = addTag("button", item);
  this._filterButton.innerHTML = "filter &#9660;" ;
  this._filterButton.className = "filterButton";
  this._filterPopupMenu = addTag("div", item);
  this._filterPopupMenu.className = "filterMenu";
  var owner = this;
  this._onMenuButtonClick = function(e){ owner._onFilterSelectButton(e); };
  DOMEvent.addEventHandler(this._filterButton, "click", this._onMenuButtonClick);
  this._examplesOnClick = function(e){ owner._onSelectOption(e); };
}
Examples.prototype = new Container;
//----------------------------------------------------- _onMouseDown
Examples.prototype._onMouseDown = function(e){
  var owner = this;
  var body = document.body;
  this._mouseMoveListener = function(e){ owner._onMouseMove(e); };
  DOMEvent.addEventHandler(body, "mousemove", this._mouseMoveListener);
  this._mouseUpListener = function(e){ owner._onMouseUp(e); };
  DOMEvent.addEventHandler(body, "mouseup", this._mouseUpListener);
  if(isIE){
    this.onselectstartSave = document.body.onselectstart;
    document.body.onselectstart = function(){return false;};
  }
}
//----------------------------------------------------- _onMouseUp
Examples.prototype._onMouseUp = function(e){
  var body = document.body;
  DOMEvent.removeEventHandler(body, "mousemove", this._mouseMoveListener);
  DOMEvent.removeEventHandler(body, "mouseup", this._mouseUpListener);
  if(isIE){
    document.body.onselectstart = this.onselectstartSave;
  }
}
//----------------------------------------------------- _onMouseMove
Examples.prototype._onMouseMove = function(e){
  if(!this._expanded) Container.prototype.expand.call(this, true);
  this.resize(e.clientY - (this._thumb.offsetHeight/2));
}
//----------------------------------------------------- resize
Examples.prototype.resize = function(y, percent){
  var thumbTop = DOMUtils.getElementLocation(this._thumb).y
  if(y==undefined && percent==undefined) y = thumbTop;

  var parentTop = DOMUtils.getElementLocation(this._body.parentNode).y;
  var parentHeight = this._body.parentNode.offsetHeight;
  var parentBottom = parentTop+parentHeight;
  var thumbHeight = this._thumb.offsetHeight;
  var headerHeight = this._header.offsetHeight;
  var thumbOffset = thumbTop-parentTop;

  // set the percentage based on a given y value:
  if(y!=undefined){
    thumbTop = y;
    var max = parentBottom-thumbHeight-headerHeight;
    if(thumbTop>=max) thumbTop = max;
    thumbOffset = thumbTop-parentTop;
    percent = Math.round((thumbOffset/parentHeight)*100);
  }
  this._topElement.style.height = percent+"%";

  var bodyHeight = parentHeight - thumbOffset;
  var contentHeight = bodyHeight - headerHeight - thumbHeight;

  if(contentHeight<0) contentHeight = 0;
  this._content.style.height = contentHeight +"px";

  // this fixes a Safari & FF bug:
  if(!isIE && !isSafari){
    // this next line (alone) fixes the safari bug (!):
    var actualHeight = this._content.offsetHeight;
    var newContentHeight;
    if(actualHeight!=contentHeight && !isSafari){
      newContentHeight = (contentHeight - (actualHeight-contentHeight) -1 )+"px";
      this._content.style.height = newContentHeight;
    }
    var actualHeight2 = this._content.offsetHeight;
    ///debug("<br>contentHeight:"+contentHeight +" actualHeight:"+actualHeight +" newContentHeight:"+newContentHeight +" actualHeight2:"+actualHeight2);
  }
}

//----------------------------------------------------- debug
// just trace out some text to the stats container:
function debug(text){
  stats.setContent(stats.getContent()+"<br>"+text);
}

//----------------------------------------------------- expand
Examples.prototype.expand = function(state){
  if(!this._initialized) return;
  Container.prototype.expand.call(this, state);
  if(this._expanded){ // expand
    if(this._expandedSize==undefined) this.resize(null,50);
    else this.resize(this._expandedSize);
  }
  else{ // collapse
    this._expandedSize = DOMUtils.getElementLocation(this._thumb).y;
    this.resize(100000);
  }
}
//----------------------------------------------------- popupFilterSelectMenu
Examples.prototype.popupFilterSelectMenu = function(state){
  if(state!=undefined) this._poppedUp = state;
  else this._poppedUp = !this._poppedUp;
  if(this._poppedUp){
    if (!this._categories) return;
    var options = "";
    for (category in this._categories) {
      if (this._categories[category])
        options += "<option name=" + category + " SELECTED>" + category;
      else
        options += "<option name=" + category + ">" + category;
    }
    this._popupLayer = addTag("div", this._header);
    DOMEvent.addEventHandler(this._popupLayer, "click", this._onMenuButtonClick);
    this.setSize(this._popupLayer, document.body);
    this._popupLayer.className = "popupLayer";
    this._filterPopupMenu.innerHTML = "<select id='filterPopupMenu' name='filterPopupMenu' MULTIPLE>" + options +"</select>";
    this._filterButton.innerHTML = "filter &#9650;" ;
    this._filterButton.setAttribute("title", "click to close popup");
    this.setMenuLocation(this._filterButton, this._filterPopupMenu);
    DOMEvent.addEventHandler(this._filterPopupMenu, "click", this._examplesOnClick);
  }
  else{
    DOMEvent.removeEventHandler(this._popupLayer, "click",  this._onMenuButtonClick);
    this._header.removeChild(this._popupLayer);
    this._filterPopupMenu.innerHTML = "";
    this._filterButton.innerHTML = "filter &#9660;";
    this._filterButton.setAttribute("title", "click to popup menu");
    DOMEvent.removeEventHandler(this._filterPopupMenu, "click", this._examplesOnClick);
  }
}
//----------------------------------------------------- setSize
Examples.prototype.setSize = function(popupLayer, referenceElement){
  var refLoc = DOMUtils.getElementLocation(referenceElement);
  popupLayer.style.left = refLoc.x + 2;
  popupLayer.style.top = refLoc.y + 2;
  popupLayer.style.width = referenceElement.offsetWidth-4;
  popupLayer.style.height = referenceElement.offsetHeight-4;
 }
//----------------------------------------------------- setMenuLocation
//Examples.prototype.setMenuLocation = function(anchorElement, popupElement){
//  var anchorLoc = DOMUtils.getElementLocation(anchorElement);
//  var popupLoc = DOMUtils.getElementLocation(popupElement);
//  anchorLoc.y += anchorElement.offsetHeight;
//  popupElement.style.left = anchorLoc.x;
//  popupElement.style.top = anchorLoc.y;
//}
Examples.prototype.setMenuLocation = function(anchorElement, popupElement){
  var anchorLoc = DOMUtils.getElementLocation(anchorElement);
  popupElement.style.left = anchorLoc.x + "px";
  if (isIE)
    popupElement.style.top = anchorLoc.y - popupElement.offsetHeight + anchorElement.offsetHeight + "px";
  else
    popupElement.style.top = anchorLoc.y + anchorElement.offsetHeight + "px";
}
//----------------------------------------------------- popupCategorySelect
Examples.prototype.popupCategorySelect = function(e){
  var checkboxes = document.getElementsByTagName("option");
  var sel = "";
  for (i = 0; i < checkboxes.length; i++) {
    this._categories[checkboxes[i].text] =  checkboxes[i].selected;
    if (checkboxes[i].selected) sel += " " + checkboxes[i].text;
  }
  DOMEvent.stopPropagation(e);
  examples.setContent(reloadExamples(false));
}
//----------------------------------------------------- _onFilterSelectButton
Examples.prototype._onFilterSelectButton = function(e){
  this.popupFilterSelectMenu();
}
//----------------------------------------------------- _onSelectOption
Examples.prototype._onSelectOption = function(e){
  this.popupCategorySelect(e);
}

// //////////////////////////////////////////////////// 
// //////////////////////////////////////////////////// Tree class
// //////////////////////////////////////////////////// 
//----------------------------------------------------- constructor
function Tree(div, name, value, expanded){
  if(div==null) return;
  this._body = div;
  CSS.addClass(this._body,"Tree");

  this.setName(name);
  this.setValue(value,expanded);
  this._name = name;
  this._data = value;

  if(expanded==undefined) this._expanded = false;
  else this._expanded = expanded;
  this.expand(this._expanded);
}
//----------------------------------------------------- setName
Tree.prototype.setName = function(text){
  if(!this._name){
    this._name = addTag("span",this._body);
    CSS.addClass(this._name,"name");
    var owner = this;
    this._onClickHandler = function(e){
      owner.expand(null);
    }
    DOMEvent.addEventHandler(this._name, "click", this._onClickHandler);
  }
  this._name.innerHTML = text;
}
//----------------------------------------------------- expand
Tree.prototype.expand = function(state, recurse){
  if(state==null) state = !this._expanded;
  this._expanded = state;
  if(this._expanded){
    CSS.removeClass(this._body,"collapsed");
    CSS.addClass(this._body,"expanded");
  }
  else{
    CSS.removeClass(this._body,"expanded");
    CSS.addClass(this._body,"collapsed");
  }
  if(recurse && this._children){
    for(var i=0, len=this._children.length; i<len; i++){
      this._children[i].expand(state, true);
    }
  }
}
//----------------------------------------------------- setValue
Tree.prototype.setValue = function(data, expand){
  if(this._value) this._body.removeChild(this._value);
  // Object
  if(data!=null && typeof data == "object"){
    if(isEmpty(data)){
      this._value = addTag("span",this._body);
      CSS.addClass(this._value,"empty");
      this._value.innerHTML = "empty";
    }
    else{
      this._value = addTag("ul",this._body);
      CSS.addClass(this._value,"value");
      this._children = new Array();
      for(var item in data){
        var li = addTag("li",this._value);
        var tree = new Tree(li, item, data[item],expand);
        CSS.addClass(this._name,"node");
        this._children.push(tree);
      }
    }
  }
  // Value
  else{
    this._value = addTag("span",this._body);
    CSS.addClass(this._value,"value");
    this._value.innerHTML = data;
  }
}
//----------------------------------------------------- destroy
Tree.prototype.destroy = function(){
  DOMEvent.removeEventHandler(this._name, "click", this._onClickHandler);
  if(this._body.parentNode) this._body.parentNode.removeChild(this._body);
}

// //////////////////////////////////////////////////// 
// //////////////////////////////////////////////////// TreeContainer class
// //////////////////////////////////////////////////// 

function TreeContainer(div){
  Container.call(this, div, "tree view");
}
TreeContainer.prototype = new Container;

//----------------------------------------------------- setData
TreeContainer.prototype.setData = function(data){
  this._content.innerHTML = "";
  if(this._tree){
    this._tree.destroy();
    delete this._tree;
  }
  // building the tree can be slow for large data sets,
  // so only do it if this container is expanded:
  this._tempData = null;
  if(this._expanded!=true){
    this._tempData = data;
    return;
  }

  //if(!this._expandAllButton){
    this._expandAllButton = addTag("button",this._content);
    this._expandAllButton.className = "expandAllButton collapsed";
    this._expandAllButton.innerHTML = "<span>expand all</span>";
    this._expandAllButton.setAttribute("title","click to expand all");
    this._expandAllButton.expanded = true;
    var owner = this;
    var onClick = function(e){
      owner._expandAllButton.expanded = !owner._expandAllButton.expanded;
      owner._tree.expand(owner._expandAllButton.expanded,true);
      if(owner._expandAllButton.expanded){
        owner._expandAllButton.className = "expandAllButton expanded";
        owner._expandAllButton.setAttribute("title","click to collapse all");
      }
      else{
        owner._expandAllButton.className = "expandAllButton collapsed";
        owner._expandAllButton.setAttribute("title","click to expand all");
      }
    }
    DOMEvent.addEventHandler(this._expandAllButton, "click", onClick);
  //}
  this._tree = addTag("div",this._content);
  this._tree = new Tree(this._tree, "result", data, true);
}
//----------------------------------------------------- expand
TreeContainer.prototype.expand = function(state){
  Container.prototype.expand.call(this, state);
  if(this._expanded && this._tempData!=null){
    this.buildTree(this._tempData);
  }
}
//----------------------------------------------------- buildTree
TreeContainer.prototype.buildTree = function(data){
  this.setContent("building tree...","#bbb");
  doLater(this, this.setData, 0, [data]);
}






// -----------------------------------------------------------
// -----------------------------------------------------------
// -----------------------------------------------------------
function viewMQLViz(){
  var url = "http://dhcp128.metaweb.com/cgi-bin/mql.py/mql2png?query=" +   
            encodeURIComponent(result.getContent());
  open(url);
}





/*
Container HTML example:
<div class="Container" id="messages">
  <div class="header">
    <div class="expandButton" onclick="onExpandButton('messagesContent')">></div>
    <div class="title">messages</div>
  </div>
  <div class="content" id="messagesContent">none</div>
</div>
*/


