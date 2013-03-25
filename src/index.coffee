transformer = require "./transformer"

module.exports = 
  cast: (typeClass) -> 
    transformer().cast typeClass
  map: (typeClass) ->
    transformer().map typeClass
