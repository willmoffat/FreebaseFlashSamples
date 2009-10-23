/**
 * Copyright 2006-2007 Metaweb Technologies, Inc.  All Rights Reserved.
 *
 * JSONUtils class
 * mark@metaweb.com
 */

//--------------------------------- JSONUtils
function JSONUtils(){}

JSONUtils.format = function(obj, plain, _indent){
  var str = [];                 // array of strings to be joined later
  if(_indent==undefined) _indent = "";
  var newIndent = _indent + "  ";
  var newLine = "\n";
  if (plain) {
    newIndent = "";
    newLine = "";
  }  
  switch(typeof obj){
    case "boolean":
      str.push(obj);
      break;
    case "number":
      str.push(obj);
      break;
    case "string":
      obj=obj.replace(/([\"\\])/g, '\\$1').replace(/\r/g, '').replace(/\n/g, '\\n');
      str.push('"'+obj+'"');
      break;
    case "object":
      if(obj instanceof Array){
        str.push("[");
        var first=true;
        for(var i=0, len=obj.length; i<len; i++){
          if (!first) {
            str.push(",");
          }
          first=false;
          str.push(JSONUtils.format(obj[i],plain,_indent));
        }
        str.push("]");
      }
      else{
        if(obj==null){
          str.push("null");
        }
        else{
          // make sure to sort the keys for proper caching
          str.push("{");
          var keys = [];
          for (var item in obj) {
            keys.push(item);
          }
          keys.sort();
          var first=true;
          for(var i=0, len=keys.length; i<len; i++) {
            if (!first) {
              str.push(",");
            }
            first=false;
            var item=keys[i];
            str.push(newLine+newIndent+'"'+item+'":');
            str.push(JSONUtils.format(obj[item],plain,newIndent));
          }
          if(item) str.push(newLine+_indent);
          str.push("}");
        }
      }
      break;
  }
  return str.join("");
};

JSONUtils.is_valid = function(s) {
  return /^(\"(\\.|[^\"\\\n\r])*?\"|[,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t])+?$/.test(s);
};

JSONUtils._encoding_dict = { '[': 'A',
                             ']': 'B',
                             '{': 'C',
                             '}': 'D',
                             '<': 'E',
                             '>': 'F',
                             '.': 'G',
                             ',': 'H',
                             ':': 'I',
                             '"': 'J',
                             '\\': 'K',
                             '/': 'L',
                             '#': 'M',
                             '$': 'N',
                             '=': 'O',
                             '+': 'P',
                             '-': 'Q',
                             '*': 'R',
                             '(': 'S',
                             ')': 'T',
                             '|': 'U',
                             '_': 'V',
                             ' ': 'W',
                             '`': 'Y0',
                             '!': 'Y1',
                             '@': 'Y2',
                             '^': 'Y3',
                             '&': 'Y4',
                             ';': 'Y5',
                             '?': 'Y6',
                             '%': 'Y7',
                             "'": 'Y8',
                             '~': 'Y9'};

// function-scoped to avoid exposing 'k'
JSONUtils._init = function() {
  JSONUtils._decoding_dict = {};
  var encoding_dict = JSONUtils._encoding_dict;
  for (var k in encoding_dict) {
    JSONUtils._decoding_dict[encoding_dict[k]] = k;
  }
};
JSONUtils._init();

JSONUtils.encode = function(query) {
  return JSONUtils.encode_string(JSONUtils.format(query, true));
}

JSONUtils.encode_string = function(query_string) {

  // Given a JSON structure already encoded as a string, compress it
  var result = []
  for (var i=0; i<query_string.length; i++) {
    var c = query_string.charAt(i);
      
    if (c >= 'a' && c <= 'z')
      result.push(c);
    else if (c >= '0' && c <= '9')
      result.push(c);
    else if (c in JSONUtils._encoding_dict)
      result.push(JSONUtils._encoding_dict[c]);
    else if (c >= 'A' && c <= 'Z') {
      result.push('Y');
      result.push(c);
    } else {
      result.push('X');
      //var charcode = c.charCodeAt(0);
      var charcode = query_string.charCodeAt(i);
      if (charcode < 16)
        result.push("0" + charcode.toString(16));
      else
        result.push(charcode.toString(16));
    }
  }
    
  return result.join("");
};

JSONUtils.decode = function(encoded_string) {

  var json_string = JSONUtils.decode_string(encoded_string);
  
  // this is a little scary. is it really good to eval stuff from the url?
  // we should think about using a json parser
  if (!JSONUtils.is_valid(json_string))
    throw "Invalid JSON string: " + json_string;
  
  return eval("("+json_string+")");
}
  
JSONUtils.decode_string = function(encoded_string) {
  // Given an encoded string, decode it to a string representing a
  // serialized JSON structure
  result = [];
  last = null;
  for (var i=0; i<encoded_string.length; i++) {
    var c = encoded_string.charAt(i);
    if (last) {
      if (last == 'Y' && (c >= 'A' && c <= 'Z')) {
        result.push(c);
        last = null;
      } else if (last == 'Y' && (c >= '0' && c <= '9')) {
        result.push(JSONUtils._decoding_dict['Y' + c]);
        last = null;
      } else if (last == 'X' && ((c >= '0' && c <= '9') ||
                                 (c >= 'A' && c <= 'F'))) {
        last = c;
      } else if (((last >= '0' && last <= '9') ||
                  (last >= 'A' && last <= 'F')) &&
                 ((c >= '0' && c <= '9') ||
                  (c >= 'A' && c <= 'F'))) {
        result.push(unescape("%" + last + c));
        last = null;
      } else {
        throw "Character '" + c + "' was not expected here in " + encoded_string;
      }
    }
      
    else {
      if (c >= 'A' && c <= 'W')
        result.push(JSONUtils._decoding_dict[c]);
      else if (c >= 'a' && c <= 'z')
        result.push(c);
      else if (c >= '0' && c <= '9')
        result.push(c);
      else if (c == 'X' || c == 'Y')
        last = c;
      else
        throw "Character '" + c + "' was not expected here in " + encoded_string;
    }
  }
  return result.join("");
}
