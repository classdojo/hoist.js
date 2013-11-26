var type = require("type-component"),
async    = require("async");

/**
 */

function getArrayTypeCaster () {
  return function (value) {
    if(type(value) === "array") return value;
    return [value];
  }
}

/**
 */

function getSimpleDataTypeCaster (typeClass) {
  return function (value) {
    return typeClass(value);
  }
}

/**
 */

function getClassTypeCaster (typeClass) {
  return function (value) {

    if (value && value.constructor === typeClass) {
      return value;
    }

    return new typeClass(value);
  }
}

/**
 */

function getTypeCaster (typeClass) {
  if (typeClass === Array) return getArrayTypeCaster();
  if (typeClass === String || typeClass === Number) return getSimpleDataTypeCaster(typeClass);
  return getClassTypeCaster(typeClass);
}

/**
 */

module.exports = function (options) {
  if (!options) options = {};

  var _transform = [], _pre = [], _post = [], _mid = [];


  var self = function (value, next) {
    if (arguments.length > 1 && type(arguments[arguments.length - 1]) === "function") {
      return self.async(value, next);
    } else {
      return self.sync.apply(null, arguments);
    }
  }

  self.async = function (value, next) {
    async.eachSeries(_transform, function (transformer, next) {
      if (transformer.async) {
        transformer.transform(value, function (err, result) {
          if (err) return next(err);
          next(null, value = result);
        });
      } else {
        value = transformer.transform(value);
        next();
      }
    }, function(err, result) {
      if (err) return next(err);
      next(null, value);
    });
  }

  self.sync = function () {
    for (var i = 0, n = _transform.length; i < n; i++) {
      arguments[0] = _transform[i].transform.apply(null, arguments);
    }
    return arguments[0];
  }

  self.preCast = function (typeClass) {
    return self._push(caster(typeClass), _pre);
  }

  self.cast = function (typeClass) {
    return self._push(caster(typeClass), _mid);
  }

  self.postCast = function (typeClass) {
    return self._push(caster(typeClass), _post);
  }

  self.preMap = function (fn) {
    return self._push(mapper(fn), _pre);
  }

  self.map = function (fn) {
    return self._push(mapper(fn), _mid);
  }

  self.postMap = function (fn) {
    return self._push(mapper(fn), _post);
  }

  function caster (typeClass) {
    return {
      transform: getTypeCaster(typeClass)
    };
  }

  function mapper (fn) {
    return {
      async: fn.length > 1,
      transform: fn
    };
  }

  self._push = function (obj, stack) {
    stack.push(obj);
    _transform = _pre.concat(_mid).concat(_post);
    return this;
  }

  return self;


}