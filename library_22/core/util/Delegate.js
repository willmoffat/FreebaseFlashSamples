/**
 * Copyright 2005-2007 Metaweb Technologies, Inc.  All Rights Reserved.
 *
 * rights reserved under the copyright laws of the United States.
 *
 * <b>Delegate</b>
 *
 * @author daepark@apmindsf.com
 */

/******************************************************** Delegate
 * @constructor
 */
function Delegate()
{
}

/******************************************************** create
 * Creates a functions wrapper for the original function so that it runs 
 * in the provided context.
 *
 * @param obj:Object - Context in which to run the function
 * @param func:Function - Function to run.
 */
Delegate.create = function(obj, func, args) 
{
  if (typeof args == "undefined") {
    args = [];
  }
  
  var f = function(){
    var myArgs = [];
    for(var i=0, len=arguments.length; i<len; i++) {
      	myArgs.push(arguments[i]);
    }
    return (arguments.callee.func.apply(arguments.callee.target, arguments.callee.args.concat(myArgs)));
  };

  f.target = obj;
  f.func = func;
  f.args = args;

  return (f);
};

/******************************************************** destroy
 * Properly cleanup a delegate created from Delegate.create
 *
 * @param f:Function - Function created from Delegate.create
 */
Delegate.destroy = function(f) {
  if (f) {
    f.target = null;
    f.func = null;
    f.args = null;
  }
};



