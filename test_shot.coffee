Shot = require('./shot.coffee')
Assert = Shot.Assert

class Shift
  @one: (n) ->
    n << 1
  @two: (n) ->
    n << 2

class TestShift extends Shot.TestCase
  test_responds_to_failure: () ->
    Assert.responds_to(Shift, "banana")
  test_true_failure: () ->
    Assert.true(false)
  test_one: () ->
    Assert.responds_to(Shift, "one")
    Assert.equal(2, Shift.one(1))

TestShift.run()