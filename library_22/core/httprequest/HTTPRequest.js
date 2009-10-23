/**
 * Copyright 2006-2007 Metaweb Technologies, Inc.  All Rights Reserved.
 *
 * HTTPRequest class
 * mark@metaweb.com
 */
include("core/util/Delegate.js");

//----------------------------------------------------- HTTPRequest
//
// Sample usage:
//
// GET: new HTTPRequest("/query.xml?q=chaos&write=0",
//            { "object": this, "callback": this.onLoaded} );
//
// When the response is available, "this.onLoaded" will be invoked
// with the HTTPRequest object as an argument.
//
// POST: new HTTPRequest("/query.xml",
//            { "object": this, "callback": this.onLoaded, "errback": this.onLoaded},
//            "q=chaos&write=0");
//
// In this example, this.onLoaded will be called for success or error.  In
// the sample callback below, note that the callback can obtain either
// text or parsed JSON responses as needed.
//
// MyClass.prototype.onLoaded(hr) {
//    if (hr.status() == 200) {
//           this.process(hr.responseJSON());
//    } else {
//           alert("Error happened: response = " + hr.responseText());
//    }
// }
//
// The "handler" argument can also be a plain function, in which case it will
// be called only on success.  The function form receives three arguments:
// responseText, responseXML, and the HTTP status value.  Note that with
// this form, you cannot easily get JSON values, nor control the error
// handling.

function HTTPRequest(url, callback, postData, headers){
  this._postData = postData;
  if(postData != undefined)
      this._method="POST";
  else
      this._method="GET";
  this._url = url;
  this._request = new XMLHttpRequest();
  this._id = HTTPRequest._makeId();
  this._headers = headers || {};
  this._json = undefined;
  if (typeof(callback) == "function") {
      // Old-style callback functions need an adapter.
      this._callback = { "object":this, "callback":this._functionCallback };
      this._handler = callback;
  } else {
      // New-style callback descriptors don't need an adapter.
      this._callback = callback;
  }

  // default headers
  if (postData != undefined && typeof this._headers["Content-Type"] == "undefined")
    this._headers["Content-Type"] =  "application/x-www-form-urlencoded";
  if (typeof this._headers["Referer"] == "undefined")
    this._headers["Referer"] =  window.location;
  
  // Unique browser page id (BrowserPID cookie) is forwarded.
  if (typeof this._headers["X-Metaweb-PGID"] == "undefined")
    this._headers["X-Metaweb-PGID"] =  readCookie("BrowserPID");
  
  this._request.onreadystatechange = Delegate.create(this, this.onreadystatechange);
  doLater(this, this._send, 0, [url, 0]);
}

//----------------------------------------------------- _send
// Actually send the request.  This is packaged separately to
// simplify retrying, which is needed to workaround a Firefox
// bug which sometimes requires a delay between open() and
// setRequestHeader().
HTTPRequest.prototype._send = function(url, iteration){
  this._request.open(this._method, url, true);

  try{
      for(var key in this._headers)
	  this._request.setRequestHeader(key, this._headers[key]);
      this._request.send(this._postData);
  } catch(e) {
      // Wait a second and try again.
      if(iteration <= 20) {
	  Debug.warn("HTTPRequest setRequestHeader (", iteration , "of 20):", e);
	  doLater(this, this._send, 1, [url, iteration + 1]);
      } else {
	  Debug.error("HTTPRequest setRequestHeader:", e);
      }
  }
}

//---------------------------------------------------------- accounting
HTTPRequest.prototype.accounting = function() {
    // Why is this overridden?
}

//---------------------------------------------------------- abort
HTTPRequest.prototype.abort = function() {
  Debug.log("HTTPRequest.abort", this._url);
  if (this._request) this._request.abort();
};

//---------------------------------------------------------- _functionCallback
// This adapter invokes an old-style function callback with response text, XML,
// and status arguments.  This is less flexible than the new-style object/method
// callbacks that just pass the HTTPRequest object.
HTTPRequest.prototype._functionCallback = function() {
    this._handler(this.responseText(), this.responseXML(), this.status());
}

//--------------------------------------------------------- onreadystatechange
// Invoked by XMLHttpRequest on any state change.  In particular, this
// gets invoked when the download is complete.
HTTPRequest.prototype.onreadystatechange = function(e){
  // Ready states other than 4 are handled inconsistently, so don't bother trying.
  if(this._request.readyState != 4)
      return;

  // Avoid memory leak in MSIE and prevent infinte recursion in Firefox      
  this._request.onreadystatechange = function(){};

  try {
      // Add the Transaction ID from the server to the list of relevant
      // transaction IDs, for debugging.
      var tid = this._request.getResponseHeader("X-Metaweb-TID");
      g_transactionIdList.push(tid);
      // Call the appropriate callback depending on the status.
      // Like MochiKit, we treat 200, 201, 204, and 304 as success.
      if (this._request.status == 200 || this._request.status == 201
	  || this._request.status == 204 || this._request.status == 304) {
	  try {
	      this._callback.callback.apply(this._callback.object, [ this ]);
	  } catch (ex) {
	      // Callback failed; report it.
	      Debug.error("HTTPRequest: Success callback failed for URL: ", this._url, "\n",
			  "Error: ", ex);
	      this._request.abort();
	  }
      } else if (this._callback.errback) {
	  try {
	      this._callback.errback.apply(this._callback.object, [ this ]);
	  } catch (ex) {
	      // Error callback failed?
	      Debug.error("HTTPRequest: Error callback failed: ", ex);
	      this._request.abort();
	  }
      } else {
	  // There is no errback; use generic handling.
	  Debug.error("HTTPRequest: Server error: ", this._request.status, "\n",
		      "Response: ", this._request.responseText);
	  this._request.abort();
      }
  } catch (ex) {
      // Catch any other errors and report them.
      Debug.error("HTTPRequest: ", ex);
      Debug.trace(ex);
      this._request.abort();
  }
};

//----------------------------------------------------- _makeId
// STATIC
HTTPRequest._currentId = 0;
HTTPRequest._makeId = function(){
    HTTPRequest._currentId = HTTPRequest._currentId || 0;
    return ++HTTPRequest._currentId;
}

//----------------------------------------------------- status
// Get status from XHR object.
HTTPRequest.prototype.status = function() {
    return this._request.status;
}

//----------------------------------------------------- responseText
// Get raw response body from XHR object.
HTTPRequest.prototype.responseText = function() {
    return this._request.responseText;
}

//----------------------------------------------------- responseXML
// Get parsed XML from XHR object.
HTTPRequest.prototype.responseXML = function() {
    return this._request.responseXML;
}

//----------------------------------------------------- responseJSON
// Get parsed JSON object by parsing XHR text.
// In particular, note that the callback design of simply passing the
// HTTPRequest object allows us to support a variety of data formats
// and client-side conversions with conversions happening only as needed.
//
// Note the error handling here:  Any exceptions are caught, logged, and re-thrown.
// Clients generally won't need to log them again.
HTTPRequest.prototype.responseJSON = function() {
    if (!this._json) {
	try{
	    Debug.time("JSON eval time");
	    this._json = eval("("+ this._request.responseText +")");
	    Debug.timeEnd("JSON eval time");
	} catch(ex) {
	    Debug.warn("HTTPRequest.responseJSON: Ill-formed JSON: ", err, "\n",
		       "JSON: ", this._request.responseText);
	    this._json = null;
	    throw ex;
	}
    }
    return this._json;
}

