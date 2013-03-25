var hoist = require("../"),
expect = require("expect.js")

describe("sync", function() {
  var numberCaster,
  arrayCaster,
  numberTransformer;

  it("can create a few casters", function() {
    numberCaster = hoist.cast(Number);
    arrayCaster = hoist.cast(Array);
    numberTransformer = numberCaster.map(function(value) {
      return { value: value };
    });
  });

  it("can properly type cast a number", function() {
    expect(hoist.cast(Number)("5")).to.be(5);
  })
  it("can properly type cast an array", function() {
    var result = hoist.cast(Array)("5");
    expect(result).to.be.an(Array);
    expect(result).to.contain("5");
  });

  it("can propertly run double casts", function() {
    var result = hoist.cast(Number).cast(Array)("5");

    expect(result).to.be.an(Array);
    expect(result).to.contain(5);
  });

  it("can properly map a value", function() {
    var result = hoist.cast(Number).map(function(value) { return { value: value } })("5");
    expect(result.value).to.be(5);
  });
})