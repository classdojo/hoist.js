isa = require "isa"

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

module.exports = transformer = (options = {}) ->

  if not options.transform
    options.transform = (value) ->
      value
  
  self = (value, next) ->
    if arguments.length is 1
      self.sync value
    else
      self.async value, next

  ###
  ###

  self.options = options

  ###
  ###

  self.async = (value, next) ->

    onParentResult = (err, result) ->
      return next(err) if err
      if options.async
        options.transform result, next
      else
        next null, options.transform result

    if not options.parent
      onParentResult null, value
    else
      options.parent.async value, onParentResult

  ###
  ###

  self.sync = (value, next) ->
    if options.async
      throw new Error "cannot type-cast value synchronously with asynchronous transformer"

    if options.parent
      value = options.parent.sync value

    options.transform value

  ###
  ###

  self.cast = (typeClass) ->
    transformer 
      parent: self
      transform: getTypeCaster typeClass

  ###
  ###

  self.map = (fn, test) ->
    transformer
      parent: self
      async: fn.length > 1
      transform: fn

  self

