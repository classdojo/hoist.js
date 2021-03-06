### Hoist makes it easy to transform your objects. [![Alt ci](https://travis-ci.org/classdojo/hoist.js.png)](https://travis-ci.org/classdojo/hoist.js)

Synchronous mappings:

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

Asynchronous mappings:

```javascript
var castNumValue = hoist.cast(Number).map(function(num, next) {
  setTimeout(next, 500, null, { value: num });
});

castNumValue("5", function(err, result) {
  console.log(result); //{ value: 5 }
})

castNumValue("5"); //error thrown for casting against asynchronous caster
```

