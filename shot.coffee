###
  In case you didn't get it, Shot == Coffee Unit

  USAGE:
  # Start file with:
  Shot = require './shot'
  Assert = Shot.Assert
  
  # TestCases inherit from Shot.TestCase
  # all methods containing the string 'test' are run as tests
  # 'tests' should either contain asserts or can throw custom Errors
  # A TestCase class is run with: SomeTestCaseClass.run()
  # Same syntax goes for Shot.TestSuite
  # TestCases are add with: SomeTestSuitClass.add(SomeTestCaseClass)
  
  Alex Noguchi 2011
###

log = (message) ->
  console.log(message)

class Assert
  @true: (bool, message = "") ->
    try
      throw "failure" unless bool
    catch error
      if error == "failure"
        throw new Error("failure: #{message}")
      else 
        throw new Error("error: #{error}")
  @false: (bool, message = "") ->
    @true(!bool, message)
  @equal: (expected, actual, message = "") ->
    @true(expected == actual, 
      "expected: #{expected} but was #{actual}\n#{message}")
  @not_equal: (expected, actual, message = "") ->
    @true(expected != actual, 
      """
      both values were: #{expected}, they should not have been equal
      #{message}
      """)
  @no_exception: (block, message = "") ->
    try
      block()
    catch error
      throw new Error("failure: #{block} threw exception #{error}\n#{message}")
  @exception: (block, message = "") ->
    try
      block()
    catch error
      return true
    throw new Error("failure: #{block} did not throw an excption\n#{message}")
  @exists: (variable, message = "") ->
    @true(variable?, "variable should have been defined but was not\n#{message}")
  @does_not_exist: (variable, message = "") ->
    @false(variable?, "variable should not have been defined but was: #{variable}\t#{message}")
  @responds_to: (klass, member, message = "") ->
    @true(klass[member]?, "#{class}.#{member} not defined\n#{message}")
  @matches: (str, regex, message = "") ->
    @true(regex.test(str), "#{regex} should contain: #{str}, but does not\n#{message}")
  @does_not_match: (str, regex, message = "") ->
    @false(regex.test(str), "#{regex} should not contain: #{str}, but does\n#{message}")

class TestCase
  @ran: false
  @stats:
    passed: 0
    failed: 0
    errored: 0
  @run: () ->
    unless ran
      ran = true
      for member of new this()
        try
          test_case = new this()
          test_case.setup?() #run if it exists
          test_case[member]() if /test/.test(member) # Only test methods begining with 'test'
          test_case.teardown?() #run if it exists
          test_case = null
          @stats.passed += 1
          # TODO add colors to messages!
          console.log("Case: #{member} Passed")
          console.log("===============")
        catch error
          for prop of error
            console.log("#{prop}: #{error[prop]}\n")
          console.log("===============")
          @stats[if /failure/.test(error.message) then "failed" else "error"] += 1
      console.log("""
                  Passed: #{@stats.passed} Failed: #{@stats.failed} Errored: #{@stats.errored}
                  #{if @stats.failed + @stats.errored == 0
                      "congratulations! All your tests in #{@name} are passing"
                    else
                      'Oh Noes!'}
                  
                  """)

class TestSuite
  @test_cases: [ ]
  @stats:
    passed: 0
    failed: 0
    errored: 0
  @test_cases: { }
  @add: (test_case) ->
    @test_cases.push(test_case)
  @run: () ->
    console.log("""
                	Running #{@name}
                	================
                
                """)
    for test_case in @test_cases
      test_case.run()
      @add_stats(test_case.stats)
    console.log("""
                Passed: #{@stats.passed} Failed: #{@stats.failed} Errored: #{@stats.errored}
                #{if @stats.failed + @stats.errored == 0
                    "congratulations! All your tests in #{@name} are passing"
                  else
                    'Oh Noes!'}
                
                """)
    
  @add_stats: (stats) ->
    @stats.passed += stats.passed
    @stats.failed += stats.failed
    @stats.errored += stats.errored


exports.Assert = Assert
exports.TestCase = TestCase
exports.TestSuite = TestSuite