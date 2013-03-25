```javascript
var hoist = require("hoist");
var castNumValue = hoist.cast(Number).map(function(num) {
  return {
    value: num
  }
});

var castArray = house.cast(Array);

console.log(castNumValue("5")); //{ value: 5 }
console.log(castNumValue({ value: 5 })); //{ value: 5 }
console.log(castArray(5)); //[5]
console.log(castArray([5])); //5

```
