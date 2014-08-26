(function () {/**
 * @license almond 0.2.9 Copyright (c) 2011-2014, The Dojo Foundation All Rights Reserved.
 * Available via the MIT or new BSD license.
 * see: http://github.com/jrburke/almond for details
 */
//Going sloppy to avoid 'use strict' string cost, but strict practices should
//be followed.
/*jslint sloppy: true */
/*global setTimeout: false */

var requirejs, require, define;
(function (undef) {
    var main, req, makeMap, handlers,
        defined = {},
        waiting = {},
        config = {},
        defining = {},
        hasOwn = Object.prototype.hasOwnProperty,
        aps = [].slice,
        jsSuffixRegExp = /\.js$/;

    function hasProp(obj, prop) {
        return hasOwn.call(obj, prop);
    }

    /**
     * Given a relative module name, like ./something, normalize it to
     * a real name that can be mapped to a path.
     * @param {String} name the relative name
     * @param {String} baseName a real name that the name arg is relative
     * to.
     * @returns {String} normalized name
     */
    function normalize(name, baseName) {
        var nameParts, nameSegment, mapValue, foundMap, lastIndex,
            foundI, foundStarMap, starI, i, j, part,
            baseParts = baseName && baseName.split("/"),
            map = config.map,
            starMap = (map && map['*']) || {};

        //Adjust any relative paths.
        if (name && name.charAt(0) === ".") {
            //If have a base name, try to normalize against it,
            //otherwise, assume it is a top-level require that will
            //be relative to baseUrl in the end.
            if (baseName) {
                //Convert baseName to array, and lop off the last part,
                //so that . matches that "directory" and not name of the baseName's
                //module. For instance, baseName of "one/two/three", maps to
                //"one/two/three.js", but we want the directory, "one/two" for
                //this normalization.
                baseParts = baseParts.slice(0, baseParts.length - 1);
                name = name.split('/');
                lastIndex = name.length - 1;

                // Node .js allowance:
                if (config.nodeIdCompat && jsSuffixRegExp.test(name[lastIndex])) {
                    name[lastIndex] = name[lastIndex].replace(jsSuffixRegExp, '');
                }

                name = baseParts.concat(name);

                //start trimDots
                for (i = 0; i < name.length; i += 1) {
                    part = name[i];
                    if (part === ".") {
                        name.splice(i, 1);
                        i -= 1;
                    } else if (part === "..") {
                        if (i === 1 && (name[2] === '..' || name[0] === '..')) {
                            //End of the line. Keep at least one non-dot
                            //path segment at the front so it can be mapped
                            //correctly to disk. Otherwise, there is likely
                            //no path mapping for a path starting with '..'.
                            //This can still fail, but catches the most reasonable
                            //uses of ..
                            break;
                        } else if (i > 0) {
                            name.splice(i - 1, 2);
                            i -= 2;
                        }
                    }
                }
                //end trimDots

                name = name.join("/");
            } else if (name.indexOf('./') === 0) {
                // No baseName, so this is ID is resolved relative
                // to baseUrl, pull off the leading dot.
                name = name.substring(2);
            }
        }

        //Apply map config if available.
        if ((baseParts || starMap) && map) {
            nameParts = name.split('/');

            for (i = nameParts.length; i > 0; i -= 1) {
                nameSegment = nameParts.slice(0, i).join("/");

                if (baseParts) {
                    //Find the longest baseName segment match in the config.
                    //So, do joins on the biggest to smallest lengths of baseParts.
                    for (j = baseParts.length; j > 0; j -= 1) {
                        mapValue = map[baseParts.slice(0, j).join('/')];

                        //baseName segment has  config, find if it has one for
                        //this name.
                        if (mapValue) {
                            mapValue = mapValue[nameSegment];
                            if (mapValue) {
                                //Match, update name to the new value.
                                foundMap = mapValue;
                                foundI = i;
                                break;
                            }
                        }
                    }
                }

                if (foundMap) {
                    break;
                }

                //Check for a star map match, but just hold on to it,
                //if there is a shorter segment match later in a matching
                //config, then favor over this star map.
                if (!foundStarMap && starMap && starMap[nameSegment]) {
                    foundStarMap = starMap[nameSegment];
                    starI = i;
                }
            }

            if (!foundMap && foundStarMap) {
                foundMap = foundStarMap;
                foundI = starI;
            }

            if (foundMap) {
                nameParts.splice(0, foundI, foundMap);
                name = nameParts.join('/');
            }
        }

        return name;
    }

    function makeRequire(relName, forceSync) {
        return function () {
            //A version of a require function that passes a moduleName
            //value for items that may need to
            //look up paths relative to the moduleName
            return req.apply(undef, aps.call(arguments, 0).concat([relName, forceSync]));
        };
    }

    function makeNormalize(relName) {
        return function (name) {
            return normalize(name, relName);
        };
    }

    function makeLoad(depName) {
        return function (value) {
            defined[depName] = value;
        };
    }

    function callDep(name) {
        if (hasProp(waiting, name)) {
            var args = waiting[name];
            delete waiting[name];
            defining[name] = true;
            main.apply(undef, args);
        }

        if (!hasProp(defined, name) && !hasProp(defining, name)) {
            throw new Error('No ' + name);
        }
        return defined[name];
    }

    //Turns a plugin!resource to [plugin, resource]
    //with the plugin being undefined if the name
    //did not have a plugin prefix.
    function splitPrefix(name) {
        var prefix,
            index = name ? name.indexOf('!') : -1;
        if (index > -1) {
            prefix = name.substring(0, index);
            name = name.substring(index + 1, name.length);
        }
        return [prefix, name];
    }

    /**
     * Makes a name map, normalizing the name, and using a plugin
     * for normalization if necessary. Grabs a ref to plugin
     * too, as an optimization.
     */
    makeMap = function (name, relName) {
        var plugin,
            parts = splitPrefix(name),
            prefix = parts[0];

        name = parts[1];

        if (prefix) {
            prefix = normalize(prefix, relName);
            plugin = callDep(prefix);
        }

        //Normalize according
        if (prefix) {
            if (plugin && plugin.normalize) {
                name = plugin.normalize(name, makeNormalize(relName));
            } else {
                name = normalize(name, relName);
            }
        } else {
            name = normalize(name, relName);
            parts = splitPrefix(name);
            prefix = parts[0];
            name = parts[1];
            if (prefix) {
                plugin = callDep(prefix);
            }
        }

        //Using ridiculous property names for space reasons
        return {
            f: prefix ? prefix + '!' + name : name, //fullName
            n: name,
            pr: prefix,
            p: plugin
        };
    };

    function makeConfig(name) {
        return function () {
            return (config && config.config && config.config[name]) || {};
        };
    }

    handlers = {
        require: function (name) {
            return makeRequire(name);
        },
        exports: function (name) {
            var e = defined[name];
            if (typeof e !== 'undefined') {
                return e;
            } else {
                return (defined[name] = {});
            }
        },
        module: function (name) {
            return {
                id: name,
                uri: '',
                exports: defined[name],
                config: makeConfig(name)
            };
        }
    };

    main = function (name, deps, callback, relName) {
        var cjsModule, depName, ret, map, i,
            args = [],
            callbackType = typeof callback,
            usingExports;

        //Use name if no relName
        relName = relName || name;

        //Call the callback to define the module, if necessary.
        if (callbackType === 'undefined' || callbackType === 'function') {
            //Pull out the defined dependencies and pass the ordered
            //values to the callback.
            //Default to [require, exports, module] if no deps
            deps = !deps.length && callback.length ? ['require', 'exports', 'module'] : deps;
            for (i = 0; i < deps.length; i += 1) {
                map = makeMap(deps[i], relName);
                depName = map.f;

                //Fast path CommonJS standard dependencies.
                if (depName === "require") {
                    args[i] = handlers.require(name);
                } else if (depName === "exports") {
                    //CommonJS module spec 1.1
                    args[i] = handlers.exports(name);
                    usingExports = true;
                } else if (depName === "module") {
                    //CommonJS module spec 1.1
                    cjsModule = args[i] = handlers.module(name);
                } else if (hasProp(defined, depName) ||
                           hasProp(waiting, depName) ||
                           hasProp(defining, depName)) {
                    args[i] = callDep(depName);
                } else if (map.p) {
                    map.p.load(map.n, makeRequire(relName, true), makeLoad(depName), {});
                    args[i] = defined[depName];
                } else {
                    throw new Error(name + ' missing ' + depName);
                }
            }

            ret = callback ? callback.apply(defined[name], args) : undefined;

            if (name) {
                //If setting exports via "module" is in play,
                //favor that over return value and exports. After that,
                //favor a non-undefined return value over exports use.
                if (cjsModule && cjsModule.exports !== undef &&
                        cjsModule.exports !== defined[name]) {
                    defined[name] = cjsModule.exports;
                } else if (ret !== undef || !usingExports) {
                    //Use the return value from the function.
                    defined[name] = ret;
                }
            }
        } else if (name) {
            //May just be an object definition for the module. Only
            //worry about defining if have a module name.
            defined[name] = callback;
        }
    };

    requirejs = require = req = function (deps, callback, relName, forceSync, alt) {
        if (typeof deps === "string") {
            if (handlers[deps]) {
                //callback in this case is really relName
                return handlers[deps](callback);
            }
            //Just return the module wanted. In this scenario, the
            //deps arg is the module name, and second arg (if passed)
            //is just the relName.
            //Normalize module name, if it contains . or ..
            return callDep(makeMap(deps, callback).f);
        } else if (!deps.splice) {
            //deps is a config object, not an array.
            config = deps;
            if (config.deps) {
                req(config.deps, config.callback);
            }
            if (!callback) {
                return;
            }

            if (callback.splice) {
                //callback is an array, which means it is a dependency list.
                //Adjust args if there are dependencies
                deps = callback;
                callback = relName;
                relName = null;
            } else {
                deps = undef;
            }
        }

        //Support require(['a'])
        callback = callback || function () {};

        //If relName is a function, it is an errback handler,
        //so remove it.
        if (typeof relName === 'function') {
            relName = forceSync;
            forceSync = alt;
        }

        //Simulate async callback;
        if (forceSync) {
            main(undef, deps, callback, relName);
        } else {
            //Using a non-zero value because of concern for what old browsers
            //do, and latest browsers "upgrade" to 4 if lower value is used:
            //http://www.whatwg.org/specs/web-apps/current-work/multipage/timers.html#dom-windowtimers-settimeout:
            //If want a value immediately, use require('id') instead -- something
            //that works in almond on the global level, but not guaranteed and
            //unlikely to work in other AMD implementations.
            setTimeout(function () {
                main(undef, deps, callback, relName);
            }, 4);
        }

        return req;
    };

    /**
     * Just drops the config on the floor, but returns req in case
     * the config return value is used.
     */
    req.config = function (cfg) {
        return req(cfg);
    };

    /**
     * Expose module registry for debugging and tooling
     */
    requirejs._defined = defined;

    define = function (name, deps, callback) {

        //This module may not have dependencies
        if (!deps.splice) {
            //deps is not an array, so probably means
            //an object literal or factory function for
            //the value. Adjust args.
            callback = deps;
            deps = [];
        }

        if (!hasProp(defined, name) && !hasProp(waiting, name)) {
            waiting[name] = [name, deps, callback];
        }
    };

    define.amd = {
        jQuery: true
    };
}());

define("bower_components/almond/almond", function(){});

/* Zepto v1.1.4 - zepto event ajax form ie - zeptojs.com/license */

var Zepto = (function() {
  var undefined, key, $, classList, emptyArray = [], slice = emptyArray.slice, filter = emptyArray.filter,
    document = window.document,
    elementDisplay = {}, classCache = {},
    cssNumber = { 'column-count': 1, 'columns': 1, 'font-weight': 1, 'line-height': 1,'opacity': 1, 'z-index': 1, 'zoom': 1 },
    fragmentRE = /^\s*<(\w+|!)[^>]*>/,
    singleTagRE = /^<(\w+)\s*\/?>(?:<\/\1>|)$/,
    tagExpanderRE = /<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/ig,
    rootNodeRE = /^(?:body|html)$/i,
    capitalRE = /([A-Z])/g,

    // special attributes that should be get/set via method calls
    methodAttributes = ['val', 'css', 'html', 'text', 'data', 'width', 'height', 'offset'],

    adjacencyOperators = [ 'after', 'prepend', 'before', 'append' ],
    table = document.createElement('table'),
    tableRow = document.createElement('tr'),
    containers = {
      'tr': document.createElement('tbody'),
      'tbody': table, 'thead': table, 'tfoot': table,
      'td': tableRow, 'th': tableRow,
      '*': document.createElement('div')
    },
    readyRE = /complete|loaded|interactive/,
    simpleSelectorRE = /^[\w-]*$/,
    class2type = {},
    toString = class2type.toString,
    zepto = {},
    camelize, uniq,
    tempParent = document.createElement('div'),
    propMap = {
      'tabindex': 'tabIndex',
      'readonly': 'readOnly',
      'for': 'htmlFor',
      'class': 'className',
      'maxlength': 'maxLength',
      'cellspacing': 'cellSpacing',
      'cellpadding': 'cellPadding',
      'rowspan': 'rowSpan',
      'colspan': 'colSpan',
      'usemap': 'useMap',
      'frameborder': 'frameBorder',
      'contenteditable': 'contentEditable'
    },
    isArray = Array.isArray ||
      function(object){ return object instanceof Array }

  zepto.matches = function(element, selector) {
    if (!selector || !element || element.nodeType !== 1) return false
    var matchesSelector = element.webkitMatchesSelector || element.mozMatchesSelector ||
                          element.oMatchesSelector || element.matchesSelector
    if (matchesSelector) return matchesSelector.call(element, selector)
    // fall back to performing a selector:
    var match, parent = element.parentNode, temp = !parent
    if (temp) (parent = tempParent).appendChild(element)
    match = ~zepto.qsa(parent, selector).indexOf(element)
    temp && tempParent.removeChild(element)
    return match
  }

  function type(obj) {
    return obj == null ? String(obj) :
      class2type[toString.call(obj)] || "object"
  }

  function isFunction(value) { return type(value) == "function" }
  function isWindow(obj)     { return obj != null && obj == obj.window }
  function isDocument(obj)   { return obj != null && obj.nodeType == obj.DOCUMENT_NODE }
  function isObject(obj)     { return type(obj) == "object" }
  function isPlainObject(obj) {
    return isObject(obj) && !isWindow(obj) && Object.getPrototypeOf(obj) == Object.prototype
  }
  function likeArray(obj) { return typeof obj.length == 'number' }

  function compact(array) { return filter.call(array, function(item){ return item != null }) }
  function flatten(array) { return array.length > 0 ? $.fn.concat.apply([], array) : array }
  camelize = function(str){ return str.replace(/-+(.)?/g, function(match, chr){ return chr ? chr.toUpperCase() : '' }) }
  function dasherize(str) {
    return str.replace(/::/g, '/')
           .replace(/([A-Z]+)([A-Z][a-z])/g, '$1_$2')
           .replace(/([a-z\d])([A-Z])/g, '$1_$2')
           .replace(/_/g, '-')
           .toLowerCase()
  }
  uniq = function(array){ return filter.call(array, function(item, idx){ return array.indexOf(item) == idx }) }

  function classRE(name) {
    return name in classCache ?
      classCache[name] : (classCache[name] = new RegExp('(^|\\s)' + name + '(\\s|$)'))
  }

  function maybeAddPx(name, value) {
    return (typeof value == "number" && !cssNumber[dasherize(name)]) ? value + "px" : value
  }

  function defaultDisplay(nodeName) {
    var element, display
    if (!elementDisplay[nodeName]) {
      element = document.createElement(nodeName)
      document.body.appendChild(element)
      display = getComputedStyle(element, '').getPropertyValue("display")
      element.parentNode.removeChild(element)
      display == "none" && (display = "block")
      elementDisplay[nodeName] = display
    }
    return elementDisplay[nodeName]
  }

  function children(element) {
    return 'children' in element ?
      slice.call(element.children) :
      $.map(element.childNodes, function(node){ if (node.nodeType == 1) return node })
  }

  // `$.zepto.fragment` takes a html string and an optional tag name
  // to generate DOM nodes nodes from the given html string.
  // The generated DOM nodes are returned as an array.
  // This function can be overriden in plugins for example to make
  // it compatible with browsers that don't support the DOM fully.
  zepto.fragment = function(html, name, properties) {
    var dom, nodes, container

    // A special case optimization for a single tag
    if (singleTagRE.test(html)) dom = $(document.createElement(RegExp.$1))

    if (!dom) {
      if (html.replace) html = html.replace(tagExpanderRE, "<$1></$2>")
      if (name === undefined) name = fragmentRE.test(html) && RegExp.$1
      if (!(name in containers)) name = '*'

      container = containers[name]
      container.innerHTML = '' + html
      dom = $.each(slice.call(container.childNodes), function(){
        container.removeChild(this)
      })
    }

    if (isPlainObject(properties)) {
      nodes = $(dom)
      $.each(properties, function(key, value) {
        if (methodAttributes.indexOf(key) > -1) nodes[key](value)
        else nodes.attr(key, value)
      })
    }

    return dom
  }

  // `$.zepto.Z` swaps out the prototype of the given `dom` array
  // of nodes with `$.fn` and thus supplying all the Zepto functions
  // to the array. Note that `__proto__` is not supported on Internet
  // Explorer. This method can be overriden in plugins.
  zepto.Z = function(dom, selector) {
    dom = dom || []
    dom.__proto__ = $.fn
    dom.selector = selector || ''
    return dom
  }

  // `$.zepto.isZ` should return `true` if the given object is a Zepto
  // collection. This method can be overriden in plugins.
  zepto.isZ = function(object) {
    return object instanceof zepto.Z
  }

  // `$.zepto.init` is Zepto's counterpart to jQuery's `$.fn.init` and
  // takes a CSS selector and an optional context (and handles various
  // special cases).
  // This method can be overriden in plugins.
  zepto.init = function(selector, context) {
    var dom
    // If nothing given, return an empty Zepto collection
    if (!selector) return zepto.Z()
    // Optimize for string selectors
    else if (typeof selector == 'string') {
      selector = selector.trim()
      // If it's a html fragment, create nodes from it
      // Note: In both Chrome 21 and Firefox 15, DOM error 12
      // is thrown if the fragment doesn't begin with <
      if (selector[0] == '<' && fragmentRE.test(selector))
        dom = zepto.fragment(selector, RegExp.$1, context), selector = null
      // If there's a context, create a collection on that context first, and select
      // nodes from there
      else if (context !== undefined) return $(context).find(selector)
      // If it's a CSS selector, use it to select nodes.
      else dom = zepto.qsa(document, selector)
    }
    // If a function is given, call it when the DOM is ready
    else if (isFunction(selector)) return $(document).ready(selector)
    // If a Zepto collection is given, just return it
    else if (zepto.isZ(selector)) return selector
    else {
      // normalize array if an array of nodes is given
      if (isArray(selector)) dom = compact(selector)
      // Wrap DOM nodes.
      else if (isObject(selector))
        dom = [selector], selector = null
      // If it's a html fragment, create nodes from it
      else if (fragmentRE.test(selector))
        dom = zepto.fragment(selector.trim(), RegExp.$1, context), selector = null
      // If there's a context, create a collection on that context first, and select
      // nodes from there
      else if (context !== undefined) return $(context).find(selector)
      // And last but no least, if it's a CSS selector, use it to select nodes.
      else dom = zepto.qsa(document, selector)
    }
    // create a new Zepto collection from the nodes found
    return zepto.Z(dom, selector)
  }

  // `$` will be the base `Zepto` object. When calling this
  // function just call `$.zepto.init, which makes the implementation
  // details of selecting nodes and creating Zepto collections
  // patchable in plugins.
  $ = function(selector, context){
    return zepto.init(selector, context)
  }

  function extend(target, source, deep) {
    for (key in source)
      if (deep && (isPlainObject(source[key]) || isArray(source[key]))) {
        if (isPlainObject(source[key]) && !isPlainObject(target[key]))
          target[key] = {}
        if (isArray(source[key]) && !isArray(target[key]))
          target[key] = []
        extend(target[key], source[key], deep)
      }
      else if (source[key] !== undefined) target[key] = source[key]
  }

  // Copy all but undefined properties from one or more
  // objects to the `target` object.
  $.extend = function(target){
    var deep, args = slice.call(arguments, 1)
    if (typeof target == 'boolean') {
      deep = target
      target = args.shift()
    }
    args.forEach(function(arg){ extend(target, arg, deep) })
    return target
  }

  // `$.zepto.qsa` is Zepto's CSS selector implementation which
  // uses `document.querySelectorAll` and optimizes for some special cases, like `#id`.
  // This method can be overriden in plugins.
  zepto.qsa = function(element, selector){
    var found,
        maybeID = selector[0] == '#',
        maybeClass = !maybeID && selector[0] == '.',
        nameOnly = maybeID || maybeClass ? selector.slice(1) : selector, // Ensure that a 1 char tag name still gets checked
        isSimple = simpleSelectorRE.test(nameOnly)
    return (isDocument(element) && isSimple && maybeID) ?
      ( (found = element.getElementById(nameOnly)) ? [found] : [] ) :
      (element.nodeType !== 1 && element.nodeType !== 9) ? [] :
      slice.call(
        isSimple && !maybeID ?
          maybeClass ? element.getElementsByClassName(nameOnly) : // If it's simple, it could be a class
          element.getElementsByTagName(selector) : // Or a tag
          element.querySelectorAll(selector) // Or it's not simple, and we need to query all
      )
  }

  function filtered(nodes, selector) {
    return selector == null ? $(nodes) : $(nodes).filter(selector)
  }

  $.contains = document.documentElement.contains ?
    function(parent, node) {
      return parent !== node && parent.contains(node)
    } :
    function(parent, node) {
      while (node && (node = node.parentNode))
        if (node === parent) return true
      return false
    }

  function funcArg(context, arg, idx, payload) {
    return isFunction(arg) ? arg.call(context, idx, payload) : arg
  }

  function setAttribute(node, name, value) {
    value == null ? node.removeAttribute(name) : node.setAttribute(name, value)
  }

  // access className property while respecting SVGAnimatedString
  function className(node, value){
    var klass = node.className,
        svg   = klass && klass.baseVal !== undefined

    if (value === undefined) return svg ? klass.baseVal : klass
    svg ? (klass.baseVal = value) : (node.className = value)
  }

  // "true"  => true
  // "false" => false
  // "null"  => null
  // "42"    => 42
  // "42.5"  => 42.5
  // "08"    => "08"
  // JSON    => parse if valid
  // String  => self
  function deserializeValue(value) {
    var num
    try {
      return value ?
        value == "true" ||
        ( value == "false" ? false :
          value == "null" ? null :
          !/^0/.test(value) && !isNaN(num = Number(value)) ? num :
          /^[\[\{]/.test(value) ? $.parseJSON(value) :
          value )
        : value
    } catch(e) {
      return value
    }
  }

  $.type = type
  $.isFunction = isFunction
  $.isWindow = isWindow
  $.isArray = isArray
  $.isPlainObject = isPlainObject

  $.isEmptyObject = function(obj) {
    var name
    for (name in obj) return false
    return true
  }

  $.inArray = function(elem, array, i){
    return emptyArray.indexOf.call(array, elem, i)
  }

  $.camelCase = camelize
  $.trim = function(str) {
    return str == null ? "" : String.prototype.trim.call(str)
  }

  // plugin compatibility
  $.uuid = 0
  $.support = { }
  $.expr = { }

  $.map = function(elements, callback){
    var value, values = [], i, key
    if (likeArray(elements))
      for (i = 0; i < elements.length; i++) {
        value = callback(elements[i], i)
        if (value != null) values.push(value)
      }
    else
      for (key in elements) {
        value = callback(elements[key], key)
        if (value != null) values.push(value)
      }
    return flatten(values)
  }

  $.each = function(elements, callback){
    var i, key
    if (likeArray(elements)) {
      for (i = 0; i < elements.length; i++)
        if (callback.call(elements[i], i, elements[i]) === false) return elements
    } else {
      for (key in elements)
        if (callback.call(elements[key], key, elements[key]) === false) return elements
    }

    return elements
  }

  $.grep = function(elements, callback){
    return filter.call(elements, callback)
  }

  if (window.JSON) $.parseJSON = JSON.parse

  // Populate the class2type map
  $.each("Boolean Number String Function Array Date RegExp Object Error".split(" "), function(i, name) {
    class2type[ "[object " + name + "]" ] = name.toLowerCase()
  })

  // Define methods that will be available on all
  // Zepto collections
  $.fn = {
    // Because a collection acts like an array
    // copy over these useful array functions.
    forEach: emptyArray.forEach,
    reduce: emptyArray.reduce,
    push: emptyArray.push,
    sort: emptyArray.sort,
    indexOf: emptyArray.indexOf,
    concat: emptyArray.concat,

    // `map` and `slice` in the jQuery API work differently
    // from their array counterparts
    map: function(fn){
      return $($.map(this, function(el, i){ return fn.call(el, i, el) }))
    },
    slice: function(){
      return $(slice.apply(this, arguments))
    },

    ready: function(callback){
      // need to check if document.body exists for IE as that browser reports
      // document ready when it hasn't yet created the body element
      if (readyRE.test(document.readyState) && document.body) callback($)
      else document.addEventListener('DOMContentLoaded', function(){ callback($) }, false)
      return this
    },
    get: function(idx){
      return idx === undefined ? slice.call(this) : this[idx >= 0 ? idx : idx + this.length]
    },
    toArray: function(){ return this.get() },
    size: function(){
      return this.length
    },
    remove: function(){
      return this.each(function(){
        if (this.parentNode != null)
          this.parentNode.removeChild(this)
      })
    },
    each: function(callback){
      emptyArray.every.call(this, function(el, idx){
        return callback.call(el, idx, el) !== false
      })
      return this
    },
    filter: function(selector){
      if (isFunction(selector)) return this.not(this.not(selector))
      return $(filter.call(this, function(element){
        return zepto.matches(element, selector)
      }))
    },
    add: function(selector,context){
      return $(uniq(this.concat($(selector,context))))
    },
    is: function(selector){
      return this.length > 0 && zepto.matches(this[0], selector)
    },
    not: function(selector){
      var nodes=[]
      if (isFunction(selector) && selector.call !== undefined)
        this.each(function(idx){
          if (!selector.call(this,idx)) nodes.push(this)
        })
      else {
        var excludes = typeof selector == 'string' ? this.filter(selector) :
          (likeArray(selector) && isFunction(selector.item)) ? slice.call(selector) : $(selector)
        this.forEach(function(el){
          if (excludes.indexOf(el) < 0) nodes.push(el)
        })
      }
      return $(nodes)
    },
    has: function(selector){
      return this.filter(function(){
        return isObject(selector) ?
          $.contains(this, selector) :
          $(this).find(selector).size()
      })
    },
    eq: function(idx){
      return idx === -1 ? this.slice(idx) : this.slice(idx, + idx + 1)
    },
    first: function(){
      var el = this[0]
      return el && !isObject(el) ? el : $(el)
    },
    last: function(){
      var el = this[this.length - 1]
      return el && !isObject(el) ? el : $(el)
    },
    find: function(selector){
      var result, $this = this
      if (!selector) result = []
      else if (typeof selector == 'object')
        result = $(selector).filter(function(){
          var node = this
          return emptyArray.some.call($this, function(parent){
            return $.contains(parent, node)
          })
        })
      else if (this.length == 1) result = $(zepto.qsa(this[0], selector))
      else result = this.map(function(){ return zepto.qsa(this, selector) })
      return result
    },
    closest: function(selector, context){
      var node = this[0], collection = false
      if (typeof selector == 'object') collection = $(selector)
      while (node && !(collection ? collection.indexOf(node) >= 0 : zepto.matches(node, selector)))
        node = node !== context && !isDocument(node) && node.parentNode
      return $(node)
    },
    parents: function(selector){
      var ancestors = [], nodes = this
      while (nodes.length > 0)
        nodes = $.map(nodes, function(node){
          if ((node = node.parentNode) && !isDocument(node) && ancestors.indexOf(node) < 0) {
            ancestors.push(node)
            return node
          }
        })
      return filtered(ancestors, selector)
    },
    parent: function(selector){
      return filtered(uniq(this.pluck('parentNode')), selector)
    },
    children: function(selector){
      return filtered(this.map(function(){ return children(this) }), selector)
    },
    contents: function() {
      return this.map(function() { return slice.call(this.childNodes) })
    },
    siblings: function(selector){
      return filtered(this.map(function(i, el){
        return filter.call(children(el.parentNode), function(child){ return child!==el })
      }), selector)
    },
    empty: function(){
      return this.each(function(){ this.innerHTML = '' })
    },
    // `pluck` is borrowed from Prototype.js
    pluck: function(property){
      return $.map(this, function(el){ return el[property] })
    },
    show: function(){
      return this.each(function(){
        this.style.display == "none" && (this.style.display = '')
        if (getComputedStyle(this, '').getPropertyValue("display") == "none")
          this.style.display = defaultDisplay(this.nodeName)
      })
    },
    replaceWith: function(newContent){
      return this.before(newContent).remove()
    },
    wrap: function(structure){
      var func = isFunction(structure)
      if (this[0] && !func)
        var dom   = $(structure).get(0),
            clone = dom.parentNode || this.length > 1

      return this.each(function(index){
        $(this).wrapAll(
          func ? structure.call(this, index) :
            clone ? dom.cloneNode(true) : dom
        )
      })
    },
    wrapAll: function(structure){
      if (this[0]) {
        $(this[0]).before(structure = $(structure))
        var children
        // drill down to the inmost element
        while ((children = structure.children()).length) structure = children.first()
        $(structure).append(this)
      }
      return this
    },
    wrapInner: function(structure){
      var func = isFunction(structure)
      return this.each(function(index){
        var self = $(this), contents = self.contents(),
            dom  = func ? structure.call(this, index) : structure
        contents.length ? contents.wrapAll(dom) : self.append(dom)
      })
    },
    unwrap: function(){
      this.parent().each(function(){
        $(this).replaceWith($(this).children())
      })
      return this
    },
    clone: function(){
      return this.map(function(){ return this.cloneNode(true) })
    },
    hide: function(){
      return this.css("display", "none")
    },
    toggle: function(setting){
      return this.each(function(){
        var el = $(this)
        ;(setting === undefined ? el.css("display") == "none" : setting) ? el.show() : el.hide()
      })
    },
    prev: function(selector){ return $(this.pluck('previousElementSibling')).filter(selector || '*') },
    next: function(selector){ return $(this.pluck('nextElementSibling')).filter(selector || '*') },
    html: function(html){
      return 0 in arguments ?
        this.each(function(idx){
          var originHtml = this.innerHTML
          $(this).empty().append( funcArg(this, html, idx, originHtml) )
        }) :
        (0 in this ? this[0].innerHTML : null)
    },
    text: function(text){
      return 0 in arguments ?
        this.each(function(idx){
          var newText = funcArg(this, text, idx, this.textContent)
          this.textContent = newText == null ? '' : ''+newText
        }) :
        (0 in this ? this[0].textContent : null)
    },
    attr: function(name, value){
      var result
      return (typeof name == 'string' && !(1 in arguments)) ?
        (!this.length || this[0].nodeType !== 1 ? undefined :
          (!(result = this[0].getAttribute(name)) && name in this[0]) ? this[0][name] : result
        ) :
        this.each(function(idx){
          if (this.nodeType !== 1) return
          if (isObject(name)) for (key in name) setAttribute(this, key, name[key])
          else setAttribute(this, name, funcArg(this, value, idx, this.getAttribute(name)))
        })
    },
    removeAttr: function(name){
      return this.each(function(){ this.nodeType === 1 && setAttribute(this, name) })
    },
    prop: function(name, value){
      name = propMap[name] || name
      return (1 in arguments) ?
        this.each(function(idx){
          this[name] = funcArg(this, value, idx, this[name])
        }) :
        (this[0] && this[0][name])
    },
    data: function(name, value){
      var attrName = 'data-' + name.replace(capitalRE, '-$1').toLowerCase()

      var data = (1 in arguments) ?
        this.attr(attrName, value) :
        this.attr(attrName)

      return data !== null ? deserializeValue(data) : undefined
    },
    val: function(value){
      return 0 in arguments ?
        this.each(function(idx){
          this.value = funcArg(this, value, idx, this.value)
        }) :
        (this[0] && (this[0].multiple ?
           $(this[0]).find('option').filter(function(){ return this.selected }).pluck('value') :
           this[0].value)
        )
    },
    offset: function(coordinates){
      if (coordinates) return this.each(function(index){
        var $this = $(this),
            coords = funcArg(this, coordinates, index, $this.offset()),
            parentOffset = $this.offsetParent().offset(),
            props = {
              top:  coords.top  - parentOffset.top,
              left: coords.left - parentOffset.left
            }

        if ($this.css('position') == 'static') props['position'] = 'relative'
        $this.css(props)
      })
      if (!this.length) return null
      var obj = this[0].getBoundingClientRect()
      return {
        left: obj.left + window.pageXOffset,
        top: obj.top + window.pageYOffset,
        width: Math.round(obj.width),
        height: Math.round(obj.height)
      }
    },
    css: function(property, value){
      if (arguments.length < 2) {
        var element = this[0], computedStyle = getComputedStyle(element, '')
        if(!element) return
        if (typeof property == 'string')
          return element.style[camelize(property)] || computedStyle.getPropertyValue(property)
        else if (isArray(property)) {
          var props = {}
          $.each(isArray(property) ? property: [property], function(_, prop){
            props[prop] = (element.style[camelize(prop)] || computedStyle.getPropertyValue(prop))
          })
          return props
        }
      }

      var css = ''
      if (type(property) == 'string') {
        if (!value && value !== 0)
          this.each(function(){ this.style.removeProperty(dasherize(property)) })
        else
          css = dasherize(property) + ":" + maybeAddPx(property, value)
      } else {
        for (key in property)
          if (!property[key] && property[key] !== 0)
            this.each(function(){ this.style.removeProperty(dasherize(key)) })
          else
            css += dasherize(key) + ':' + maybeAddPx(key, property[key]) + ';'
      }

      return this.each(function(){ this.style.cssText += ';' + css })
    },
    index: function(element){
      return element ? this.indexOf($(element)[0]) : this.parent().children().indexOf(this[0])
    },
    hasClass: function(name){
      if (!name) return false
      return emptyArray.some.call(this, function(el){
        return this.test(className(el))
      }, classRE(name))
    },
    addClass: function(name){
      if (!name) return this
      return this.each(function(idx){
        classList = []
        var cls = className(this), newName = funcArg(this, name, idx, cls)
        newName.split(/\s+/g).forEach(function(klass){
          if (!$(this).hasClass(klass)) classList.push(klass)
        }, this)
        classList.length && className(this, cls + (cls ? " " : "") + classList.join(" "))
      })
    },
    removeClass: function(name){
      return this.each(function(idx){
        if (name === undefined) return className(this, '')
        classList = className(this)
        funcArg(this, name, idx, classList).split(/\s+/g).forEach(function(klass){
          classList = classList.replace(classRE(klass), " ")
        })
        className(this, classList.trim())
      })
    },
    toggleClass: function(name, when){
      if (!name) return this
      return this.each(function(idx){
        var $this = $(this), names = funcArg(this, name, idx, className(this))
        names.split(/\s+/g).forEach(function(klass){
          (when === undefined ? !$this.hasClass(klass) : when) ?
            $this.addClass(klass) : $this.removeClass(klass)
        })
      })
    },
    scrollTop: function(value){
      if (!this.length) return
      var hasScrollTop = 'scrollTop' in this[0]
      if (value === undefined) return hasScrollTop ? this[0].scrollTop : this[0].pageYOffset
      return this.each(hasScrollTop ?
        function(){ this.scrollTop = value } :
        function(){ this.scrollTo(this.scrollX, value) })
    },
    scrollLeft: function(value){
      if (!this.length) return
      var hasScrollLeft = 'scrollLeft' in this[0]
      if (value === undefined) return hasScrollLeft ? this[0].scrollLeft : this[0].pageXOffset
      return this.each(hasScrollLeft ?
        function(){ this.scrollLeft = value } :
        function(){ this.scrollTo(value, this.scrollY) })
    },
    position: function() {
      if (!this.length) return

      var elem = this[0],
        // Get *real* offsetParent
        offsetParent = this.offsetParent(),
        // Get correct offsets
        offset       = this.offset(),
        parentOffset = rootNodeRE.test(offsetParent[0].nodeName) ? { top: 0, left: 0 } : offsetParent.offset()

      // Subtract element margins
      // note: when an element has margin: auto the offsetLeft and marginLeft
      // are the same in Safari causing offset.left to incorrectly be 0
      offset.top  -= parseFloat( $(elem).css('margin-top') ) || 0
      offset.left -= parseFloat( $(elem).css('margin-left') ) || 0

      // Add offsetParent borders
      parentOffset.top  += parseFloat( $(offsetParent[0]).css('border-top-width') ) || 0
      parentOffset.left += parseFloat( $(offsetParent[0]).css('border-left-width') ) || 0

      // Subtract the two offsets
      return {
        top:  offset.top  - parentOffset.top,
        left: offset.left - parentOffset.left
      }
    },
    offsetParent: function() {
      return this.map(function(){
        var parent = this.offsetParent || document.body
        while (parent && !rootNodeRE.test(parent.nodeName) && $(parent).css("position") == "static")
          parent = parent.offsetParent
        return parent
      })
    }
  }

  // for now
  $.fn.detach = $.fn.remove

  // Generate the `width` and `height` functions
  ;['width', 'height'].forEach(function(dimension){
    var dimensionProperty =
      dimension.replace(/./, function(m){ return m[0].toUpperCase() })

    $.fn[dimension] = function(value){
      var offset, el = this[0]
      if (value === undefined) return isWindow(el) ? el['inner' + dimensionProperty] :
        isDocument(el) ? el.documentElement['scroll' + dimensionProperty] :
        (offset = this.offset()) && offset[dimension]
      else return this.each(function(idx){
        el = $(this)
        el.css(dimension, funcArg(this, value, idx, el[dimension]()))
      })
    }
  })

  function traverseNode(node, fun) {
    fun(node)
    for (var i = 0, len = node.childNodes.length; i < len; i++)
      traverseNode(node.childNodes[i], fun)
  }

  // Generate the `after`, `prepend`, `before`, `append`,
  // `insertAfter`, `insertBefore`, `appendTo`, and `prependTo` methods.
  adjacencyOperators.forEach(function(operator, operatorIndex) {
    var inside = operatorIndex % 2 //=> prepend, append

    $.fn[operator] = function(){
      // arguments can be nodes, arrays of nodes, Zepto objects and HTML strings
      var argType, nodes = $.map(arguments, function(arg) {
            argType = type(arg)
            return argType == "object" || argType == "array" || arg == null ?
              arg : zepto.fragment(arg)
          }),
          parent, copyByClone = this.length > 1
      if (nodes.length < 1) return this

      return this.each(function(_, target){
        parent = inside ? target : target.parentNode

        // convert all methods to a "before" operation
        target = operatorIndex == 0 ? target.nextSibling :
                 operatorIndex == 1 ? target.firstChild :
                 operatorIndex == 2 ? target :
                 null

        var parentInDocument = $.contains(document.documentElement, parent)

        nodes.forEach(function(node){
          if (copyByClone) node = node.cloneNode(true)
          else if (!parent) return $(node).remove()

          parent.insertBefore(node, target)
          if (parentInDocument) traverseNode(node, function(el){
            if (el.nodeName != null && el.nodeName.toUpperCase() === 'SCRIPT' &&
               (!el.type || el.type === 'text/javascript') && !el.src)
              window['eval'].call(window, el.innerHTML)
          })
        })
      })
    }

    // after    => insertAfter
    // prepend  => prependTo
    // before   => insertBefore
    // append   => appendTo
    $.fn[inside ? operator+'To' : 'insert'+(operatorIndex ? 'Before' : 'After')] = function(html){
      $(html)[operator](this)
      return this
    }
  })

  zepto.Z.prototype = $.fn

  // Export internal API functions in the `$.zepto` namespace
  zepto.uniq = uniq
  zepto.deserializeValue = deserializeValue
  $.zepto = zepto

  return $
})()

window.Zepto = Zepto
window.$ === undefined && (window.$ = Zepto)

;(function($){
  var _zid = 1, undefined,
      slice = Array.prototype.slice,
      isFunction = $.isFunction,
      isString = function(obj){ return typeof obj == 'string' },
      handlers = {},
      specialEvents={},
      focusinSupported = 'onfocusin' in window,
      focus = { focus: 'focusin', blur: 'focusout' },
      hover = { mouseenter: 'mouseover', mouseleave: 'mouseout' }

  specialEvents.click = specialEvents.mousedown = specialEvents.mouseup = specialEvents.mousemove = 'MouseEvents'

  function zid(element) {
    return element._zid || (element._zid = _zid++)
  }
  function findHandlers(element, event, fn, selector) {
    event = parse(event)
    if (event.ns) var matcher = matcherFor(event.ns)
    return (handlers[zid(element)] || []).filter(function(handler) {
      return handler
        && (!event.e  || handler.e == event.e)
        && (!event.ns || matcher.test(handler.ns))
        && (!fn       || zid(handler.fn) === zid(fn))
        && (!selector || handler.sel == selector)
    })
  }
  function parse(event) {
    var parts = ('' + event).split('.')
    return {e: parts[0], ns: parts.slice(1).sort().join(' ')}
  }
  function matcherFor(ns) {
    return new RegExp('(?:^| )' + ns.replace(' ', ' .* ?') + '(?: |$)')
  }

  function eventCapture(handler, captureSetting) {
    return handler.del &&
      (!focusinSupported && (handler.e in focus)) ||
      !!captureSetting
  }

  function realEvent(type) {
    return hover[type] || (focusinSupported && focus[type]) || type
  }

  function add(element, events, fn, data, selector, delegator, capture){
    var id = zid(element), set = (handlers[id] || (handlers[id] = []))
    events.split(/\s/).forEach(function(event){
      if (event == 'ready') return $(document).ready(fn)
      var handler   = parse(event)
      handler.fn    = fn
      handler.sel   = selector
      // emulate mouseenter, mouseleave
      if (handler.e in hover) fn = function(e){
        var related = e.relatedTarget
        if (!related || (related !== this && !$.contains(this, related)))
          return handler.fn.apply(this, arguments)
      }
      handler.del   = delegator
      var callback  = delegator || fn
      handler.proxy = function(e){
        e = compatible(e)
        if (e.isImmediatePropagationStopped()) return
        e.data = data
        var result = callback.apply(element, e._args == undefined ? [e] : [e].concat(e._args))
        if (result === false) e.preventDefault(), e.stopPropagation()
        return result
      }
      handler.i = set.length
      set.push(handler)
      if ('addEventListener' in element)
        element.addEventListener(realEvent(handler.e), handler.proxy, eventCapture(handler, capture))
    })
  }
  function remove(element, events, fn, selector, capture){
    var id = zid(element)
    ;(events || '').split(/\s/).forEach(function(event){
      findHandlers(element, event, fn, selector).forEach(function(handler){
        delete handlers[id][handler.i]
      if ('removeEventListener' in element)
        element.removeEventListener(realEvent(handler.e), handler.proxy, eventCapture(handler, capture))
      })
    })
  }

  $.event = { add: add, remove: remove }

  $.proxy = function(fn, context) {
    var args = (2 in arguments) && slice.call(arguments, 2)
    if (isFunction(fn)) {
      var proxyFn = function(){ return fn.apply(context, args ? args.concat(slice.call(arguments)) : arguments) }
      proxyFn._zid = zid(fn)
      return proxyFn
    } else if (isString(context)) {
      if (args) {
        args.unshift(fn[context], fn)
        return $.proxy.apply(null, args)
      } else {
        return $.proxy(fn[context], fn)
      }
    } else {
      throw new TypeError("expected function")
    }
  }

  $.fn.bind = function(event, data, callback){
    return this.on(event, data, callback)
  }
  $.fn.unbind = function(event, callback){
    return this.off(event, callback)
  }
  $.fn.one = function(event, selector, data, callback){
    return this.on(event, selector, data, callback, 1)
  }

  var returnTrue = function(){return true},
      returnFalse = function(){return false},
      ignoreProperties = /^([A-Z]|returnValue$|layer[XY]$)/,
      eventMethods = {
        preventDefault: 'isDefaultPrevented',
        stopImmediatePropagation: 'isImmediatePropagationStopped',
        stopPropagation: 'isPropagationStopped'
      }

  function compatible(event, source) {
    if (source || !event.isDefaultPrevented) {
      source || (source = event)

      $.each(eventMethods, function(name, predicate) {
        var sourceMethod = source[name]
        event[name] = function(){
          this[predicate] = returnTrue
          return sourceMethod && sourceMethod.apply(source, arguments)
        }
        event[predicate] = returnFalse
      })

      if (source.defaultPrevented !== undefined ? source.defaultPrevented :
          'returnValue' in source ? source.returnValue === false :
          source.getPreventDefault && source.getPreventDefault())
        event.isDefaultPrevented = returnTrue
    }
    return event
  }

  function createProxy(event) {
    var key, proxy = { originalEvent: event }
    for (key in event)
      if (!ignoreProperties.test(key) && event[key] !== undefined) proxy[key] = event[key]

    return compatible(proxy, event)
  }

  $.fn.delegate = function(selector, event, callback){
    return this.on(event, selector, callback)
  }
  $.fn.undelegate = function(selector, event, callback){
    return this.off(event, selector, callback)
  }

  $.fn.live = function(event, callback){
    $(document.body).delegate(this.selector, event, callback)
    return this
  }
  $.fn.die = function(event, callback){
    $(document.body).undelegate(this.selector, event, callback)
    return this
  }

  $.fn.on = function(event, selector, data, callback, one){
    var autoRemove, delegator, $this = this
    if (event && !isString(event)) {
      $.each(event, function(type, fn){
        $this.on(type, selector, data, fn, one)
      })
      return $this
    }

    if (!isString(selector) && !isFunction(callback) && callback !== false)
      callback = data, data = selector, selector = undefined
    if (isFunction(data) || data === false)
      callback = data, data = undefined

    if (callback === false) callback = returnFalse

    return $this.each(function(_, element){
      if (one) autoRemove = function(e){
        remove(element, e.type, callback)
        return callback.apply(this, arguments)
      }

      if (selector) delegator = function(e){
        var evt, match = $(e.target).closest(selector, element).get(0)
        if (match && match !== element) {
          evt = $.extend(createProxy(e), {currentTarget: match, liveFired: element})
          return (autoRemove || callback).apply(match, [evt].concat(slice.call(arguments, 1)))
        }
      }

      add(element, event, callback, data, selector, delegator || autoRemove)
    })
  }
  $.fn.off = function(event, selector, callback){
    var $this = this
    if (event && !isString(event)) {
      $.each(event, function(type, fn){
        $this.off(type, selector, fn)
      })
      return $this
    }

    if (!isString(selector) && !isFunction(callback) && callback !== false)
      callback = selector, selector = undefined

    if (callback === false) callback = returnFalse

    return $this.each(function(){
      remove(this, event, callback, selector)
    })
  }

  $.fn.trigger = function(event, args){
    event = (isString(event) || $.isPlainObject(event)) ? $.Event(event) : compatible(event)
    event._args = args
    return this.each(function(){
      // items in the collection might not be DOM elements
      if('dispatchEvent' in this) this.dispatchEvent(event)
      else $(this).triggerHandler(event, args)
    })
  }

  // triggers event handlers on current element just as if an event occurred,
  // doesn't trigger an actual event, doesn't bubble
  $.fn.triggerHandler = function(event, args){
    var e, result
    this.each(function(i, element){
      e = createProxy(isString(event) ? $.Event(event) : event)
      e._args = args
      e.target = element
      $.each(findHandlers(element, event.type || event), function(i, handler){
        result = handler.proxy(e)
        if (e.isImmediatePropagationStopped()) return false
      })
    })
    return result
  }

  // shortcut methods for `.bind(event, fn)` for each event type
  ;('focusin focusout load resize scroll unload click dblclick '+
  'mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave '+
  'change select keydown keypress keyup error').split(' ').forEach(function(event) {
    $.fn[event] = function(callback) {
      return callback ?
        this.bind(event, callback) :
        this.trigger(event)
    }
  })

  ;['focus', 'blur'].forEach(function(name) {
    $.fn[name] = function(callback) {
      if (callback) this.bind(name, callback)
      else this.each(function(){
        try { this[name]() }
        catch(e) {}
      })
      return this
    }
  })

  $.Event = function(type, props) {
    if (!isString(type)) props = type, type = props.type
    var event = document.createEvent(specialEvents[type] || 'Events'), bubbles = true
    if (props) for (var name in props) (name == 'bubbles') ? (bubbles = !!props[name]) : (event[name] = props[name])
    event.initEvent(type, bubbles, true)
    return compatible(event)
  }

})(Zepto)

;(function($){
  var jsonpID = 0,
      document = window.document,
      key,
      name,
      rscript = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi,
      scriptTypeRE = /^(?:text|application)\/javascript/i,
      xmlTypeRE = /^(?:text|application)\/xml/i,
      jsonType = 'application/json',
      htmlType = 'text/html',
      blankRE = /^\s*$/

  // trigger a custom event and return false if it was cancelled
  function triggerAndReturn(context, eventName, data) {
    var event = $.Event(eventName)
    $(context).trigger(event, data)
    return !event.isDefaultPrevented()
  }

  // trigger an Ajax "global" event
  function triggerGlobal(settings, context, eventName, data) {
    if (settings.global) return triggerAndReturn(context || document, eventName, data)
  }

  // Number of active Ajax requests
  $.active = 0

  function ajaxStart(settings) {
    if (settings.global && $.active++ === 0) triggerGlobal(settings, null, 'ajaxStart')
  }
  function ajaxStop(settings) {
    if (settings.global && !(--$.active)) triggerGlobal(settings, null, 'ajaxStop')
  }

  // triggers an extra global event "ajaxBeforeSend" that's like "ajaxSend" but cancelable
  function ajaxBeforeSend(xhr, settings) {
    var context = settings.context
    if (settings.beforeSend.call(context, xhr, settings) === false ||
        triggerGlobal(settings, context, 'ajaxBeforeSend', [xhr, settings]) === false)
      return false

    triggerGlobal(settings, context, 'ajaxSend', [xhr, settings])
  }
  function ajaxSuccess(data, xhr, settings, deferred) {
    var context = settings.context, status = 'success'
    settings.success.call(context, data, status, xhr)
    if (deferred) deferred.resolveWith(context, [data, status, xhr])
    triggerGlobal(settings, context, 'ajaxSuccess', [xhr, settings, data])
    ajaxComplete(status, xhr, settings)
  }
  // type: "timeout", "error", "abort", "parsererror"
  function ajaxError(error, type, xhr, settings, deferred) {
    var context = settings.context
    settings.error.call(context, xhr, type, error)
    if (deferred) deferred.rejectWith(context, [xhr, type, error])
    triggerGlobal(settings, context, 'ajaxError', [xhr, settings, error || type])
    ajaxComplete(type, xhr, settings)
  }
  // status: "success", "notmodified", "error", "timeout", "abort", "parsererror"
  function ajaxComplete(status, xhr, settings) {
    var context = settings.context
    settings.complete.call(context, xhr, status)
    triggerGlobal(settings, context, 'ajaxComplete', [xhr, settings])
    ajaxStop(settings)
  }

  // Empty function, used as default callback
  function empty() {}

  $.ajaxJSONP = function(options, deferred){
    if (!('type' in options)) return $.ajax(options)

    var _callbackName = options.jsonpCallback,
      callbackName = ($.isFunction(_callbackName) ?
        _callbackName() : _callbackName) || ('jsonp' + (++jsonpID)),
      script = document.createElement('script'),
      originalCallback = window[callbackName],
      responseData,
      abort = function(errorType) {
        $(script).triggerHandler('error', errorType || 'abort')
      },
      xhr = { abort: abort }, abortTimeout

    if (deferred) deferred.promise(xhr)

    $(script).on('load error', function(e, errorType){
      clearTimeout(abortTimeout)
      $(script).off().remove()

      if (e.type == 'error' || !responseData) {
        ajaxError(null, errorType || 'error', xhr, options, deferred)
      } else {
        ajaxSuccess(responseData[0], xhr, options, deferred)
      }

      window[callbackName] = originalCallback
      if (responseData && $.isFunction(originalCallback))
        originalCallback(responseData[0])

      originalCallback = responseData = undefined
    })

    if (ajaxBeforeSend(xhr, options) === false) {
      abort('abort')
      return xhr
    }

    window[callbackName] = function(){
      responseData = arguments
    }

    script.src = options.url.replace(/\?(.+)=\?/, '?$1=' + callbackName)
    document.head.appendChild(script)

    if (options.timeout > 0) abortTimeout = setTimeout(function(){
      abort('timeout')
    }, options.timeout)

    return xhr
  }

  $.ajaxSettings = {
    // Default type of request
    type: 'GET',
    // Callback that is executed before request
    beforeSend: empty,
    // Callback that is executed if the request succeeds
    success: empty,
    // Callback that is executed the the server drops error
    error: empty,
    // Callback that is executed on request complete (both: error and success)
    complete: empty,
    // The context for the callbacks
    context: null,
    // Whether to trigger "global" Ajax events
    global: true,
    // Transport
    xhr: function () {
      return new window.XMLHttpRequest()
    },
    // MIME types mapping
    // IIS returns Javascript as "application/x-javascript"
    accepts: {
      script: 'text/javascript, application/javascript, application/x-javascript',
      json:   jsonType,
      xml:    'application/xml, text/xml',
      html:   htmlType,
      text:   'text/plain'
    },
    // Whether the request is to another domain
    crossDomain: false,
    // Default timeout
    timeout: 0,
    // Whether data should be serialized to string
    processData: true,
    // Whether the browser should be allowed to cache GET responses
    cache: true
  }

  function mimeToDataType(mime) {
    if (mime) mime = mime.split(';', 2)[0]
    return mime && ( mime == htmlType ? 'html' :
      mime == jsonType ? 'json' :
      scriptTypeRE.test(mime) ? 'script' :
      xmlTypeRE.test(mime) && 'xml' ) || 'text'
  }

  function appendQuery(url, query) {
    if (query == '') return url
    return (url + '&' + query).replace(/[&?]{1,2}/, '?')
  }

  // serialize payload and append it to the URL for GET requests
  function serializeData(options) {
    if (options.processData && options.data && $.type(options.data) != "string")
      options.data = $.param(options.data, options.traditional)
    if (options.data && (!options.type || options.type.toUpperCase() == 'GET'))
      options.url = appendQuery(options.url, options.data), options.data = undefined
  }

  $.ajax = function(options){
    var settings = $.extend({}, options || {}),
        deferred = $.Deferred && $.Deferred()
    for (key in $.ajaxSettings) if (settings[key] === undefined) settings[key] = $.ajaxSettings[key]

    ajaxStart(settings)

    if (!settings.crossDomain) settings.crossDomain = /^([\w-]+:)?\/\/([^\/]+)/.test(settings.url) &&
      RegExp.$2 != window.location.host

    if (!settings.url) settings.url = window.location.toString()
    serializeData(settings)

    var dataType = settings.dataType, hasPlaceholder = /\?.+=\?/.test(settings.url)
    if (hasPlaceholder) dataType = 'jsonp'

    if (settings.cache === false || (
         (!options || options.cache !== true) &&
         ('script' == dataType || 'jsonp' == dataType)
        ))
      settings.url = appendQuery(settings.url, '_=' + Date.now())

    if ('jsonp' == dataType) {
      if (!hasPlaceholder)
        settings.url = appendQuery(settings.url,
          settings.jsonp ? (settings.jsonp + '=?') : settings.jsonp === false ? '' : 'callback=?')
      return $.ajaxJSONP(settings, deferred)
    }

    var mime = settings.accepts[dataType],
        headers = { },
        setHeader = function(name, value) { headers[name.toLowerCase()] = [name, value] },
        protocol = /^([\w-]+:)\/\//.test(settings.url) ? RegExp.$1 : window.location.protocol,
        xhr = settings.xhr(),
        nativeSetHeader = xhr.setRequestHeader,
        abortTimeout

    if (deferred) deferred.promise(xhr)

    if (!settings.crossDomain) setHeader('X-Requested-With', 'XMLHttpRequest')
    setHeader('Accept', mime || '*/*')
    if (mime = settings.mimeType || mime) {
      if (mime.indexOf(',') > -1) mime = mime.split(',', 2)[0]
      xhr.overrideMimeType && xhr.overrideMimeType(mime)
    }
    if (settings.contentType || (settings.contentType !== false && settings.data && settings.type.toUpperCase() != 'GET'))
      setHeader('Content-Type', settings.contentType || 'application/x-www-form-urlencoded')

    if (settings.headers) for (name in settings.headers) setHeader(name, settings.headers[name])
    xhr.setRequestHeader = setHeader

    xhr.onreadystatechange = function(){
      if (xhr.readyState == 4) {
        xhr.onreadystatechange = empty
        clearTimeout(abortTimeout)
        var result, error = false
        if ((xhr.status >= 200 && xhr.status < 300) || xhr.status == 304 || (xhr.status == 0 && protocol == 'file:')) {
          dataType = dataType || mimeToDataType(settings.mimeType || xhr.getResponseHeader('content-type'))
          result = xhr.responseText

          try {
            // http://perfectionkills.com/global-eval-what-are-the-options/
            if (dataType == 'script')    (1,eval)(result)
            else if (dataType == 'xml')  result = xhr.responseXML
            else if (dataType == 'json') result = blankRE.test(result) ? null : $.parseJSON(result)
          } catch (e) { error = e }

          if (error) ajaxError(error, 'parsererror', xhr, settings, deferred)
          else ajaxSuccess(result, xhr, settings, deferred)
        } else {
          ajaxError(xhr.statusText || null, xhr.status ? 'error' : 'abort', xhr, settings, deferred)
        }
      }
    }

    if (ajaxBeforeSend(xhr, settings) === false) {
      xhr.abort()
      ajaxError(null, 'abort', xhr, settings, deferred)
      return xhr
    }

    if (settings.xhrFields) for (name in settings.xhrFields) xhr[name] = settings.xhrFields[name]

    var async = 'async' in settings ? settings.async : true
    xhr.open(settings.type, settings.url, async, settings.username, settings.password)

    for (name in headers) nativeSetHeader.apply(xhr, headers[name])

    if (settings.timeout > 0) abortTimeout = setTimeout(function(){
        xhr.onreadystatechange = empty
        xhr.abort()
        ajaxError(null, 'timeout', xhr, settings, deferred)
      }, settings.timeout)

    // avoid sending empty string (#319)
    xhr.send(settings.data ? settings.data : null)
    return xhr
  }

  // handle optional data/success arguments
  function parseArguments(url, data, success, dataType) {
    if ($.isFunction(data)) dataType = success, success = data, data = undefined
    if (!$.isFunction(success)) dataType = success, success = undefined
    return {
      url: url
    , data: data
    , success: success
    , dataType: dataType
    }
  }

  $.get = function(/* url, data, success, dataType */){
    return $.ajax(parseArguments.apply(null, arguments))
  }

  $.post = function(/* url, data, success, dataType */){
    var options = parseArguments.apply(null, arguments)
    options.type = 'POST'
    return $.ajax(options)
  }

  $.getJSON = function(/* url, data, success */){
    var options = parseArguments.apply(null, arguments)
    options.dataType = 'json'
    return $.ajax(options)
  }

  $.fn.load = function(url, data, success){
    if (!this.length) return this
    var self = this, parts = url.split(/\s/), selector,
        options = parseArguments(url, data, success),
        callback = options.success
    if (parts.length > 1) options.url = parts[0], selector = parts[1]
    options.success = function(response){
      self.html(selector ?
        $('<div>').html(response.replace(rscript, "")).find(selector)
        : response)
      callback && callback.apply(self, arguments)
    }
    $.ajax(options)
    return this
  }

  var escape = encodeURIComponent

  function serialize(params, obj, traditional, scope){
    var type, array = $.isArray(obj), hash = $.isPlainObject(obj)
    $.each(obj, function(key, value) {
      type = $.type(value)
      if (scope) key = traditional ? scope :
        scope + '[' + (hash || type == 'object' || type == 'array' ? key : '') + ']'
      // handle data in serializeArray() format
      if (!scope && array) params.add(value.name, value.value)
      // recurse into nested objects
      else if (type == "array" || (!traditional && type == "object"))
        serialize(params, value, traditional, key)
      else params.add(key, value)
    })
  }

  $.param = function(obj, traditional){
    var params = []
    params.add = function(k, v){ this.push(escape(k) + '=' + escape(v)) }
    serialize(params, obj, traditional)
    return params.join('&').replace(/%20/g, '+')
  }
})(Zepto)

;(function($){
  $.fn.serializeArray = function() {
    var result = [], el
    $([].slice.call(this.get(0).elements)).each(function(){
      el = $(this)
      var type = el.attr('type')
      if (this.nodeName.toLowerCase() != 'fieldset' &&
        !this.disabled && type != 'submit' && type != 'reset' && type != 'button' &&
        ((type != 'radio' && type != 'checkbox') || this.checked))
        result.push({
          name: el.attr('name'),
          value: el.val()
        })
    })
    return result
  }

  $.fn.serialize = function(){
    var result = []
    this.serializeArray().forEach(function(elm){
      result.push(encodeURIComponent(elm.name) + '=' + encodeURIComponent(elm.value))
    })
    return result.join('&')
  }

  $.fn.submit = function(callback) {
    if (callback) this.bind('submit', callback)
    else if (this.length) {
      var event = $.Event('submit')
      this.eq(0).trigger(event)
      if (!event.isDefaultPrevented()) this.get(0).submit()
    }
    return this
  }

})(Zepto)

;(function($){
  // __proto__ doesn't exist on IE<11, so redefine
  // the Z function to use object extension instead
  if (!('__proto__' in {})) {
    $.extend($.zepto, {
      Z: function(dom, selector){
        dom = dom || []
        $.extend(dom, $.fn)
        dom.selector = selector || ''
        dom.__Z = true
        return dom
      },
      // this is a kludge but works
      isZ: function(object){
        return $.type(object) === 'array' && '__Z' in object
      }
    })
  }

  // getComputedStyle shouldn't freak out when called
  // without a valid element as argument
  try {
    getComputedStyle(undefined)
  } catch(e) {
    var nativeGetComputedStyle = getComputedStyle;
    window.getComputedStyle = function(element){
      try {
        return nativeGetComputedStyle(element)
      } catch(e) {
        return null
      }
    }
  }
})(Zepto)
;
define("zepto", (function (global) {
    return function () {
        var ret, fn;
        return ret || global.$;
    };
}(this)));

(function() {
  define('Config',['zepto'], function($) {
    var Config;
    Config = (function() {
      Config.prototype.REQUIRED = ['selectors'];

      function Config() {
        var CONFIG, error, opt, scriptElement, _i, _j, _len, _len1, _ref, _ref1;
        this.errors = [];
        scriptElement = $('script[data-wishlistt]');
        try {
          CONFIG = JSON.parse(scriptElement.text());
        } catch (_error) {
          error = _error;
          this.errors.push('failed to parse config JSON:');
          this.errors.push(error);
          return;
        }
        _ref = this.REQUIRED;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          opt = _ref[_i];
          if (!CONFIG[opt]) {
            this.errors.push("" + opt + " not set in config");
            return;
          }
        }
        _ref1 = ['title', 'picture', 'price'];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          opt = _ref1[_j];
          if (!CONFIG['selectors'][opt]) {
            this.errors.push("" + opt + " selector not set in config");
          }
        }
        this.selectorType = CONFIG.selectorType || 'css';
        this.selectors = CONFIG.selectors;
      }

      return Config;

    })();
    return new Config();
  });

}).call(this);

(function() {
  define('extractor',['zepto'], function($) {
    return function(config) {};
  });

}).call(this);

/**
 * @license RequireJS text 2.0.12 Copyright (c) 2010-2014, The Dojo Foundation All Rights Reserved.
 * Available via the MIT or new BSD license.
 * see: http://github.com/requirejs/text for details
 */
/*jslint regexp: true */
/*global require, XMLHttpRequest, ActiveXObject,
  define, window, process, Packages,
  java, location, Components, FileUtils */

define('text',['module'], function (module) {
    

    var text, fs, Cc, Ci, xpcIsWindows,
        progIds = ['Msxml2.XMLHTTP', 'Microsoft.XMLHTTP', 'Msxml2.XMLHTTP.4.0'],
        xmlRegExp = /^\s*<\?xml(\s)+version=[\'\"](\d)*.(\d)*[\'\"](\s)*\?>/im,
        bodyRegExp = /<body[^>]*>\s*([\s\S]+)\s*<\/body>/im,
        hasLocation = typeof location !== 'undefined' && location.href,
        defaultProtocol = hasLocation && location.protocol && location.protocol.replace(/\:/, ''),
        defaultHostName = hasLocation && location.hostname,
        defaultPort = hasLocation && (location.port || undefined),
        buildMap = {},
        masterConfig = (module.config && module.config()) || {};

    text = {
        version: '2.0.12',

        strip: function (content) {
            //Strips <?xml ...?> declarations so that external SVG and XML
            //documents can be added to a document without worry. Also, if the string
            //is an HTML document, only the part inside the body tag is returned.
            if (content) {
                content = content.replace(xmlRegExp, "");
                var matches = content.match(bodyRegExp);
                if (matches) {
                    content = matches[1];
                }
            } else {
                content = "";
            }
            return content;
        },

        jsEscape: function (content) {
            return content.replace(/(['\\])/g, '\\$1')
                .replace(/[\f]/g, "\\f")
                .replace(/[\b]/g, "\\b")
                .replace(/[\n]/g, "\\n")
                .replace(/[\t]/g, "\\t")
                .replace(/[\r]/g, "\\r")
                .replace(/[\u2028]/g, "\\u2028")
                .replace(/[\u2029]/g, "\\u2029");
        },

        createXhr: masterConfig.createXhr || function () {
            //Would love to dump the ActiveX crap in here. Need IE 6 to die first.
            var xhr, i, progId;
            if (typeof XMLHttpRequest !== "undefined") {
                return new XMLHttpRequest();
            } else if (typeof ActiveXObject !== "undefined") {
                for (i = 0; i < 3; i += 1) {
                    progId = progIds[i];
                    try {
                        xhr = new ActiveXObject(progId);
                    } catch (e) {}

                    if (xhr) {
                        progIds = [progId];  // so faster next time
                        break;
                    }
                }
            }

            return xhr;
        },

        /**
         * Parses a resource name into its component parts. Resource names
         * look like: module/name.ext!strip, where the !strip part is
         * optional.
         * @param {String} name the resource name
         * @returns {Object} with properties "moduleName", "ext" and "strip"
         * where strip is a boolean.
         */
        parseName: function (name) {
            var modName, ext, temp,
                strip = false,
                index = name.indexOf("."),
                isRelative = name.indexOf('./') === 0 ||
                             name.indexOf('../') === 0;

            if (index !== -1 && (!isRelative || index > 1)) {
                modName = name.substring(0, index);
                ext = name.substring(index + 1, name.length);
            } else {
                modName = name;
            }

            temp = ext || modName;
            index = temp.indexOf("!");
            if (index !== -1) {
                //Pull off the strip arg.
                strip = temp.substring(index + 1) === "strip";
                temp = temp.substring(0, index);
                if (ext) {
                    ext = temp;
                } else {
                    modName = temp;
                }
            }

            return {
                moduleName: modName,
                ext: ext,
                strip: strip
            };
        },

        xdRegExp: /^((\w+)\:)?\/\/([^\/\\]+)/,

        /**
         * Is an URL on another domain. Only works for browser use, returns
         * false in non-browser environments. Only used to know if an
         * optimized .js version of a text resource should be loaded
         * instead.
         * @param {String} url
         * @returns Boolean
         */
        useXhr: function (url, protocol, hostname, port) {
            var uProtocol, uHostName, uPort,
                match = text.xdRegExp.exec(url);
            if (!match) {
                return true;
            }
            uProtocol = match[2];
            uHostName = match[3];

            uHostName = uHostName.split(':');
            uPort = uHostName[1];
            uHostName = uHostName[0];

            return (!uProtocol || uProtocol === protocol) &&
                   (!uHostName || uHostName.toLowerCase() === hostname.toLowerCase()) &&
                   ((!uPort && !uHostName) || uPort === port);
        },

        finishLoad: function (name, strip, content, onLoad) {
            content = strip ? text.strip(content) : content;
            if (masterConfig.isBuild) {
                buildMap[name] = content;
            }
            onLoad(content);
        },

        load: function (name, req, onLoad, config) {
            //Name has format: some.module.filext!strip
            //The strip part is optional.
            //if strip is present, then that means only get the string contents
            //inside a body tag in an HTML string. For XML/SVG content it means
            //removing the <?xml ...?> declarations so the content can be inserted
            //into the current doc without problems.

            // Do not bother with the work if a build and text will
            // not be inlined.
            if (config && config.isBuild && !config.inlineText) {
                onLoad();
                return;
            }

            masterConfig.isBuild = config && config.isBuild;

            var parsed = text.parseName(name),
                nonStripName = parsed.moduleName +
                    (parsed.ext ? '.' + parsed.ext : ''),
                url = req.toUrl(nonStripName),
                useXhr = (masterConfig.useXhr) ||
                         text.useXhr;

            // Do not load if it is an empty: url
            if (url.indexOf('empty:') === 0) {
                onLoad();
                return;
            }

            //Load the text. Use XHR if possible and in a browser.
            if (!hasLocation || useXhr(url, defaultProtocol, defaultHostName, defaultPort)) {
                text.get(url, function (content) {
                    text.finishLoad(name, parsed.strip, content, onLoad);
                }, function (err) {
                    if (onLoad.error) {
                        onLoad.error(err);
                    }
                });
            } else {
                //Need to fetch the resource across domains. Assume
                //the resource has been optimized into a JS module. Fetch
                //by the module name + extension, but do not include the
                //!strip part to avoid file system issues.
                req([nonStripName], function (content) {
                    text.finishLoad(parsed.moduleName + '.' + parsed.ext,
                                    parsed.strip, content, onLoad);
                });
            }
        },

        write: function (pluginName, moduleName, write, config) {
            if (buildMap.hasOwnProperty(moduleName)) {
                var content = text.jsEscape(buildMap[moduleName]);
                write.asModule(pluginName + "!" + moduleName,
                               "define(function () { return '" +
                                   content +
                               "';});\n");
            }
        },

        writeFile: function (pluginName, moduleName, req, write, config) {
            var parsed = text.parseName(moduleName),
                extPart = parsed.ext ? '.' + parsed.ext : '',
                nonStripName = parsed.moduleName + extPart,
                //Use a '.js' file name so that it indicates it is a
                //script that can be loaded across domains.
                fileName = req.toUrl(parsed.moduleName + extPart) + '.js';

            //Leverage own load() method to load plugin value, but only
            //write out values that do not have the strip argument,
            //to avoid any potential issues with ! in file names.
            text.load(nonStripName, req, function (value) {
                //Use own write() method to construct full module value.
                //But need to create shell that translates writeFile's
                //write() to the right interface.
                var textWrite = function (contents) {
                    return write(fileName, contents);
                };
                textWrite.asModule = function (moduleName, contents) {
                    return write.asModule(moduleName, fileName, contents);
                };

                text.write(pluginName, nonStripName, textWrite, config);
            }, config);
        }
    };

    if (masterConfig.env === 'node' || (!masterConfig.env &&
            typeof process !== "undefined" &&
            process.versions &&
            !!process.versions.node &&
            !process.versions['node-webkit'])) {
        //Using special require.nodeRequire, something added by r.js.
        fs = require.nodeRequire('fs');

        text.get = function (url, callback, errback) {
            try {
                var file = fs.readFileSync(url, 'utf8');
                //Remove BOM (Byte Mark Order) from utf8 files if it is there.
                if (file.indexOf('\uFEFF') === 0) {
                    file = file.substring(1);
                }
                callback(file);
            } catch (e) {
                if (errback) {
                    errback(e);
                }
            }
        };
    } else if (masterConfig.env === 'xhr' || (!masterConfig.env &&
            text.createXhr())) {
        text.get = function (url, callback, errback, headers) {
            var xhr = text.createXhr(), header;
            xhr.open('GET', url, true);

            //Allow plugins direct access to xhr headers
            if (headers) {
                for (header in headers) {
                    if (headers.hasOwnProperty(header)) {
                        xhr.setRequestHeader(header.toLowerCase(), headers[header]);
                    }
                }
            }

            //Allow overrides specified in config
            if (masterConfig.onXhr) {
                masterConfig.onXhr(xhr, url);
            }

            xhr.onreadystatechange = function (evt) {
                var status, err;
                //Do not explicitly handle errors, those should be
                //visible via console output in the browser.
                if (xhr.readyState === 4) {
                    status = xhr.status || 0;
                    if (status > 399 && status < 600) {
                        //An http 4xx or 5xx error. Signal an error.
                        err = new Error(url + ' HTTP status: ' + status);
                        err.xhr = xhr;
                        if (errback) {
                            errback(err);
                        }
                    } else {
                        callback(xhr.responseText);
                    }

                    if (masterConfig.onXhrComplete) {
                        masterConfig.onXhrComplete(xhr, url);
                    }
                }
            };
            xhr.send(null);
        };
    } else if (masterConfig.env === 'rhino' || (!masterConfig.env &&
            typeof Packages !== 'undefined' && typeof java !== 'undefined')) {
        //Why Java, why is this so awkward?
        text.get = function (url, callback) {
            var stringBuffer, line,
                encoding = "utf-8",
                file = new java.io.File(url),
                lineSeparator = java.lang.System.getProperty("line.separator"),
                input = new java.io.BufferedReader(new java.io.InputStreamReader(new java.io.FileInputStream(file), encoding)),
                content = '';
            try {
                stringBuffer = new java.lang.StringBuffer();
                line = input.readLine();

                // Byte Order Mark (BOM) - The Unicode Standard, version 3.0, page 324
                // http://www.unicode.org/faq/utf_bom.html

                // Note that when we use utf-8, the BOM should appear as "EF BB BF", but it doesn't due to this bug in the JDK:
                // http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=4508058
                if (line && line.length() && line.charAt(0) === 0xfeff) {
                    // Eat the BOM, since we've already found the encoding on this file,
                    // and we plan to concatenating this buffer with others; the BOM should
                    // only appear at the top of a file.
                    line = line.substring(1);
                }

                if (line !== null) {
                    stringBuffer.append(line);
                }

                while ((line = input.readLine()) !== null) {
                    stringBuffer.append(lineSeparator);
                    stringBuffer.append(line);
                }
                //Make sure we return a JavaScript string and not a Java string.
                content = String(stringBuffer.toString()); //String
            } finally {
                input.close();
            }
            callback(content);
        };
    } else if (masterConfig.env === 'xpconnect' || (!masterConfig.env &&
            typeof Components !== 'undefined' && Components.classes &&
            Components.interfaces)) {
        //Avert your gaze!
        Cc = Components.classes;
        Ci = Components.interfaces;
        Components.utils['import']('resource://gre/modules/FileUtils.jsm');
        xpcIsWindows = ('@mozilla.org/windows-registry-key;1' in Cc);

        text.get = function (url, callback) {
            var inStream, convertStream, fileObj,
                readData = {};

            if (xpcIsWindows) {
                url = url.replace(/\//g, '\\');
            }

            fileObj = new FileUtils.File(url);

            //XPCOM, you so crazy
            try {
                inStream = Cc['@mozilla.org/network/file-input-stream;1']
                           .createInstance(Ci.nsIFileInputStream);
                inStream.init(fileObj, 1, 0, false);

                convertStream = Cc['@mozilla.org/intl/converter-input-stream;1']
                                .createInstance(Ci.nsIConverterInputStream);
                convertStream.init(inStream, "utf-8", inStream.available(),
                Ci.nsIConverterInputStream.DEFAULT_REPLACEMENT_CHARACTER);

                convertStream.readString(inStream.available(), readData);
                convertStream.close();
                inStream.close();
                callback(readData.value);
            } catch (e) {
                throw new Error((fileObj && fileObj.path || '') + ': ' + e);
            }
        };
    }
    return text;
});


define('text!view/widget.html',[],function () { return '<div id="wishlistt-widget">\n    <style type="text/css">\n     #wishlistt-widget {\n       position: absolute;\n       right: 0;\n       top: 10%;\n\n       border: 1px solid black;\n\n       width: 150px;\n       height: 65px;\n\n       margin: 5px 0 5px 5px;\n     }\n     #wishlistt-widget.loading { background-color: whitesmoke; }\n\n     #wishlistt-widget h4,\n     #wishlistt-widget p,\n     #wishlistt-widget img {\n       margin: 0;\n     }\n\n     #wishlistt-widget img {\n       position: absolute;\n       /* left: 5px;\n       top: 5px; */\n     }\n\n     #wishlistt-widget .info {\n       margin-left: 60px;\n     }\n\n     #wishlistt-widget.loading .wishlistt-widget-content { display: none; }\n     #wishlistt-widget.loading .wishlistt-widget-spinner { display: block; }\n     #wishlistt-widget .wishlistt-widget-content { display: block; }\n     #wishlistt-widget .wishlistt-widget-spinner { display: none; }\n\n     #wishlistt-widget .wishlistt-widget-spinner img {\n       left: 50px;\n       top: 7px;\n     }\n    </style>\n    <div class="wishlistt-widget-content">\n        <div class="picture">\n            <img src="" width="50"/>\n        </div>\n\n        <div class="info">\n            <h4 class="title"></h4>\n            <p class="price"></p>\n        </div>\n    </div>\n    <div class="wishlistt-widget-spinner">\n        <img src="data:image/gif;base64,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"/>\n    </div>\n\n</div>\n';});


define('text!view/iframe.html',[],function () { return '<div id="wishlistt-iframe">\n    <style type="text/css">\n     #wishlistt-iframe {\n\n       position: absolute;\n       right: 0;\n       top: 0;\n       height: 100%;\n       width: 350px;\n       overflow: hidden;\n     }\n\n     #wishlistt-iframe .container {\n       position: absolute;\n       right: -350px;\n       /* width: 100%; */\n       height: 100%;\n     }\n\n     #wishlistt-iframe .container iframe {\n       widht: 100%;\n       height: 100%;\n     }\n\n     #wishlistt-iframe .close {\n       position: absolute;\n       right: 20px;\n       top: 0;\n\n       font-size: 30px;\n     }\n    </style>\n    <div class="container">\n        <iframe src="http://localhost:8000/dummy_content.html" frameBorder="0"></iframe>\n\n        <div class="close">X</div>\n    </div>\n</div>\n';});


define('text!view/spinner.html',[],function () { return '<div class="wishlistt-spinner">\n    <style type="text/css">\n     #wishlistt-spinner {\n       display: none;\n     }\n    </style>\n    <img src="data:image/gif;base64,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"/>\n</div>\n';});

//     Zepto.js
//     (c) 2010-2014 Thomas Fuchs
//     Zepto.js may be freely distributed under the MIT license.
;(function($, undefined){
    var prefix = '', eventPrefix, endEventName, endAnimationName,
        vendors = { Webkit: 'webkit', Moz: '', O: 'o' },
        document = window.document, testEl = document.createElement('div'),
        supportedTransforms = /^((translate|rotate|scale)(X|Y|Z|3d)?|matrix(3d)?|perspective|skew(X|Y)?)$/i,
        transform,
        transitionProperty, transitionDuration, transitionTiming, transitionDelay,
        animationName, animationDuration, animationTiming, animationDelay,
        cssReset = {}

    function dasherize(str) { return str.replace(/([a-z])([A-Z])/, '$1-$2').toLowerCase() }
    function normalizeEvent(name) { return eventPrefix ? eventPrefix + name : name.toLowerCase() }

    $.each(vendors, function(vendor, event){
        if (testEl.style[vendor + 'TransitionProperty'] !== undefined) {
            prefix = '-' + vendor.toLowerCase() + '-'
            eventPrefix = event
            return false
        }
    })

    transform = prefix + 'transform'
    cssReset[transitionProperty = prefix + 'transition-property'] =
        cssReset[transitionDuration = prefix + 'transition-duration'] =
        cssReset[transitionDelay    = prefix + 'transition-delay'] =
        cssReset[transitionTiming   = prefix + 'transition-timing-function'] =
        cssReset[animationName      = prefix + 'animation-name'] =
        cssReset[animationDuration  = prefix + 'animation-duration'] =
        cssReset[animationDelay     = prefix + 'animation-delay'] =
        cssReset[animationTiming    = prefix + 'animation-timing-function'] = ''

    $.fx = {
        off: (eventPrefix === undefined && testEl.style.transitionProperty === undefined),
        speeds: { _default: 400, fast: 200, slow: 600 },
        cssPrefix: prefix,
        transitionEnd: normalizeEvent('TransitionEnd'),
        animationEnd: normalizeEvent('AnimationEnd')
    }

    $.fn.animate = function(properties, duration, ease, callback, delay){
        if ($.isFunction(duration))
            callback = duration, ease = undefined, duration = undefined
        if ($.isFunction(ease))
            callback = ease, ease = undefined
        if ($.isPlainObject(duration))
            ease = duration.easing, callback = duration.complete, delay = duration.delay, duration = duration.duration
        if (duration) duration = (typeof duration == 'number' ? duration :
                                  ($.fx.speeds[duration] || $.fx.speeds._default)) / 1000
        if (delay) delay = parseFloat(delay) / 1000
        return this.anim(properties, duration, ease, callback, delay)
    }

    $.fn.anim = function(properties, duration, ease, callback, delay){
        var key, cssValues = {}, cssProperties, transforms = '',
            that = this, wrappedCallback, endEvent = $.fx.transitionEnd,
            fired = false

        if (duration === undefined) duration = $.fx.speeds._default / 1000
        if (delay === undefined) delay = 0
        if ($.fx.off) duration = 0

        if (typeof properties == 'string') {
            // keyframe animation
            cssValues[animationName] = properties
            cssValues[animationDuration] = duration + 's'
            cssValues[animationDelay] = delay + 's'
            cssValues[animationTiming] = (ease || 'linear')
            endEvent = $.fx.animationEnd
        } else {
            cssProperties = []
            // CSS transitions
            for (key in properties)
                if (supportedTransforms.test(key)) transforms += key + '(' + properties[key] + ') '
            else cssValues[key] = properties[key], cssProperties.push(dasherize(key))

            if (transforms) cssValues[transform] = transforms, cssProperties.push(transform)
            if (duration > 0 && typeof properties === 'object') {
                cssValues[transitionProperty] = cssProperties.join(', ')
                cssValues[transitionDuration] = duration + 's'
                cssValues[transitionDelay] = delay + 's'
                cssValues[transitionTiming] = (ease || 'linear')
            }
        }

        wrappedCallback = function(event){
            if (typeof event !== 'undefined') {
                if (event.target !== event.currentTarget) return // makes sure the event didn't bubble from "below"
                $(event.target).unbind(endEvent, wrappedCallback)
            } else
                $(this).unbind(endEvent, wrappedCallback) // triggered by setTimeout

            fired = true
            $(this).css(cssReset)
            callback && callback.call(this)
        }
        if (duration > 0){
            this.bind(endEvent, wrappedCallback)
            // transitionEnd is not always firing on older Android phones
            // so make sure it gets fired
            setTimeout(function(){
                if (fired) return
                wrappedCallback.call(that)
            }, (duration * 1000) + 25)
        }

        // trigger page reflow so new elements can animate
        this.size() && this.get(0).clientLeft

        this.css(cssValues)

        if (duration <= 0) setTimeout(function() {
            that.each(function(){ wrappedCallback.call(this) })
        }, 0)

        return this
    }

    testEl = null
})(Zepto);

define("zeptoFx", function(){});

(function() {
  require(['zepto', 'Config', 'extractor', 'text!view/widget.html', 'text!view/iframe.html', 'text!view/spinner.html', 'zeptoFx'], function($, Config, extractor, widgetTemplate, iframeTemplate, spinnerTemplate) {
    return $(function() {
      var err, iframeContainer, iframeElement, iframeWrapper, values, widgetElement, _i, _len, _ref;
      console.log('Init Wishlistt plugin');
      if (Config.errors.length > 0) {
        _ref = Config.errors;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          err = _ref[_i];
          if (typeof err === 'string') {
            console.log("Wishlistt-plugin: " + err);
          } else {
            console.log(err);
          }
        }
        return;
      }
      values = {
        title: $(Config.selectors.title).text(),
        price: $(Config.selectors.price).text(),
        picture: $(Config.selectors.picture).attr('src')
      };
      iframeContainer = $(iframeTemplate);
      iframeWrapper = iframeContainer.find('.container');
      iframeElement = iframeWrapper.find('iframe');
      iframeContainer.on('click', '.close', function() {
        widgetElement.removeClass('loading');
        return iframeWrapper.animate({
          right: '-350px'
        }, {
          duration: 500,
          easing: 'ease-in-out',
          complete: function() {
            return iframeContainer.remove();
          }
        });
      });
      iframeElement.on('load', function() {
        iframeElement.get(0).contentWindow.postMessage('I\'m from parent', '*');
        return iframeWrapper.animate({
          right: '0px'
        });
      });
      widgetElement = $(widgetTemplate);
      widgetElement.find('.title').text(values.title);
      widgetElement.find('.price').text(values.price);
      widgetElement.find('.picture img').attr({
        src: values.picture
      });
      widgetElement.on('click', function() {
        $(document.body).append(iframeContainer);
        return $(this).addClass('loading');
      });
      $(document.body).append(widgetElement);
      return window.onmessage = function(e) {
        return console.log('Message from iframe side: ' + e.data);
      };
    });
  });

}).call(this);

define("main", function(){});

}());