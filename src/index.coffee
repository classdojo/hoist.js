transformer = require "./transformer"

module.exports = transformer

module.exports.cast = (typeClass) -> 
    transformer().cast typeClass
    
module.exports.map = (typeClass) ->
    transformer().map typeClass
