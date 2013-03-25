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


  
  ###
  ###

  if not options.transform
    options.transform = (value) ->
      value

  ###
  ###
  
  self = (value, next) ->

    if arguments.length is 1
      return options.root.sync value
    else
      return options.root.async value, next


  if not options.root
    options.root = self

  ###
  ###

  self.options = options

  ###
  ###

  self.async = (value, next) ->

    onResult = (err, result) ->
      return next(err) if err
      return next(null, result) if not options.next
      options.next.async result, next


    if options.async
      options.transform value, onResult
    else
      onResult null, options.transform value

  ###
  ###

  self.sync = (value, next) ->
    if options.async
      throw new Error "cannot type-cast value synchronously with asynchronous transformer"

    value = options.transform value

    if options.next
      value = options.next.sync value

    value

  ###
  ###

  self.cast = (typeClass) ->
    options.next = transformer 
      root: options.root
      transform: getTypeCaster typeClass

  ###
  ###

  self.map = (fn, test) ->
    options.next = transformer
      parent: self
      root: options.root
      async: fn.length > 1
      transform: fn

  self

