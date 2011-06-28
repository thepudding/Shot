#
# In case you didn't get it, **Shot** is **Coffee Unit**
#
# USAGE:
#
#     # Start file with:
#     Shot = require './shot'
#     Assert = Shot.Assert
#
# TestCases inherit from Shot.TestCase
# all methods containing the string 'test' are run as tests
# 'tests' should either contain asserts or can throw custom Errors
# A TestCase class is run with: SomeTestCaseClass.run()
# Same syntax goes for Shot.TestSuite
# TestCases are add with: SomeTestSuitClass.add(SomeTestCaseClass)
#  
#  Alex Noguchi 2011

#### Logging

# By default sys.puts()
sys = require('sys')
log = sys.puts
log.print = sys.print

styles =
  normal:    0
  underline: 1
  bold:      2

colors =
  clear:  0
  black:  30
  blue:   34
  green:  32
  cyan:   36
  red:    31
  purple: 35
  brown:  33

C = (color, style = null) ->
  "\033[#{if style? then "#{styles[style]};" else ''}#{colors[color]}m"

class Assert
  @true: (bool, message = "", logging = true) ->
    log.print("Assert.true. . .\t") if logging
    try
      throw "failure" unless bool
    catch error
      if error == "failure"
        log("#{C('red')}Failed!#{C('clear')}")
        throw new Error("failure: #{message}")
      else
        log("#{C('red')}Errored;!#{C('clear')}")
        throw new Error("error: #{error}")
    log("#{C('green')}Succeeded!#{C('clear')}")
  @false: (bool, message = "", logging = true) ->
    log.print("Assert.false. . .\t") if logging
    @true(!bool, message, false)
  @equal: (expected, actual, message = "") ->
    log.print("Assert.equal. . .\t")
    @true(expected == actual, 
      "expected: #{expected} but was #{actual}\n#{message}", false)
  @not_equal: (expected, actual, message = "") ->
    log.print("Assert.not_equal. . .\t")
    @true(expected != actual, 
      """
      both values were: #{expected}, they should not have been equal
      #{message}
      """, false)
  @no_exception: (block, message = "") ->
    log.print("Assert.no_exception. . .")
    try
      block()
      log("#{C('green')}Succeeded!#{C('clear')}")
    catch error
      log("#{C('red')}Failed!#{C('clear')}")
      throw new Error("failure: #{block} threw exception #{error}\n#{message}")
  @exception: (block, message = "") ->
    log.print("Assert.excetpion. . .\t")
    try
      block()
      log("#{C('red')}Failed!#{C('clear')}")
    catch error
      log("#{C('green')}Succeeded!#{C('clear')}")
      return true
    throw new Error("failure: #{block} did not throw an excption\n#{message}")
  @exists: (variable, message = "") ->
    log.print("Assert.exists. . .\t")
    @true(variable?, "variable should have been defined but was not\n#{message}", false)
  @does_not_exist: (variable, message = "") ->
    log.print("Assert.does_not_exist. . .\t")
    @false(variable?, "variable should not have been defined but was: #{variable}\t#{message}", false)
  @responds_to: (klass, member, message = "") ->
    log.print("Assert.responds_to. . .\t")
    @true(klass[member]?, "#{class}.#{member} not defined\n#{message}", false)
  @matches: (str, regex, message = "") ->
    log.print("Assert.matches. . .\t")
    @true(regex.test(str), "#{regex} should contain: #{str}, but does not\n#{message}", false)
  @does_not_match: (str, regex, message = "") ->
    log.print("Assert.does_not_match. . .\t")
    @false(regex.test(str), "#{regex} should not contain: #{str}, but does\n#{message}", false)

class TestCase
  @ran: false
  @stats:
    passed: 0
    failed: 0
    errored: 0
  @run: () ->
    unless ran
      ran = true
      log("Test case: #{C('blue')}#{this.name}#{C('clear')}\n")
      for member of new this()
        if /test/.test(member)
          try
            test_case = new this()
            log("#{C('blue')}#{member}:#{C('clear')}")
            test_case.setup?() #run if it exists
            test_case[member]() # Only test methods begining with 'test'
            test_case.teardown?() #run if it exists
            test_case = null
            @stats.passed += 1
            # TODO add colors to messages!
            log("\t\t\t----------\n\t\t\t#{C('green')}Passed!#{C('clear')}")
            log("===============")
          catch error
            log("#{error.stack}\n")
            log("===============")
            @stats[if /failure/.test(error.message) then "failed" else "error"] += 1
        log("""
            Passed: #{C('green')}#{@stats.passed}#{C('clear')} Failed: #{if @stats.failed > 0 then C('red') else ""}#{@stats.failed}#{C('clear')} Errored: #{if @stats.errored > 0 then C('red')  else ""}#{@stats.errored}#{C('clear')}
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
  @add: (test_cases...) ->
    @test_cases.push(test_cases...)
  @run: () ->
    log("""
        	Running #{@name}
        	================
        
        """)
    for test_case in @test_cases
      test_case.run()
      @add_stats(test_case.stats)
    log("""
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