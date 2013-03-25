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

    if arguments.length > 1 and isa.function arguments[arguments.length - 1]
      return options.root.async value, next
    else
      return options.root.sync.apply null, arguments


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

  self.sync = (value) ->

    #if options.async
    #  throw new Error "cannot type-cast value synchronously with asynchronous transformer"

    arguments[0] = options.transform.apply null, arguments

    if options.next
      value = options.next.sync.apply null, arguments

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

