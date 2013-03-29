isa = require "isa"
async = require "async"

###
###

getArrayTypeCaster = () ->
  (value) ->
    return value if isa.array value
    return [value]

###
###

getSimpleDataTypeCaster = (typeClass) ->
  (value) ->
    return typeClass value

###
###

getClassTypeCaster = (typeClass) ->
  (value) ->

    if value && value.constructor is typeClass
      return value

    return new typeClass value

###
###

getTypeCaster = (typeClass) ->
  return getArrayTypeCaster() if typeClass is Array
  return getSimpleDataTypeCaster(typeClass) if (typeClass is String) or (typeClass is Number)
  return getClassTypeCaster(typeClass)





###
###

module.exports = (options = {}) ->

  _transform = []

  ###
  ###
  
  self = (value, next) ->

    if arguments.length > 1 and isa.function arguments[arguments.length - 1]
      return self.async value, next
    else
      return self.sync.apply null, arguments


  ###
  ###

  self.async = (value, next) ->

    async.eachSeries _transform, ((transformer, next) ->
      if transformer.async
        transformer.transform value, (err, result) ->
          return next(err) if err
          next null, value = result
      else
        value = transformer.transform value
        next()
    ), (err, result) ->
      return next(err) if err
      next null, value


  ###
  ###

  self.sync = () ->
    for transformer in _transform
      arguments[0] = transformer.transform.apply null, arguments

    arguments[0]


  ###
  ###

  self.cast = (typeClass) ->
    _transform.push {
      transform: getTypeCaster typeClass
    }
    @

  ###
  ###

  self.map = (fn) ->
    _transform.push {
      async: fn.length > 1
      transform: fn
    }
    @

  self

