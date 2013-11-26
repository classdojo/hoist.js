var transformer = require("./transformer");
module.exports = transformer;


[ 
  "cast",
  "map", 
  "preCast",
  "preMap",
  "postCast",
  "postMap"
].forEach(function (method) {
  module.exports[method] = function () {
    var t = transformer();
    return t[method].apply(t, arguments);
  }
});
