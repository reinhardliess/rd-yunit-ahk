; cspell:ignore dont ansi
;; ConsoleOutputTest
Class ConsoleOutputTest {
  
  /**
  * Runs expect(), returns status
  * @param {string} matcherName
  * @param {any} actualValue
  * @param {any*} expectedValues 
  * @returns {Yunit.AssertError | 0} 
  */
  _runMatcher(matcherName, actualValue, expectedValues*) {
    try {
      Yunit.expect(actualValue)[matcherName](expectedValues*)
      ret := 0
    } catch err {
      ret := err
    }
    return ret
  }

  /**
  * Creates OutputInfo object from passed arguments
  * "Prints" category, resets print output (simulated)
  * @param {string} category 
  * @param {string} testMethod - Name of test
  * @param {Yunit.AssertError | 0} result - test result
  * @param {string} methodTime_ms - time taken for test
  * @returns {OutputInfo} 
  */
  _setOutputInfo(category, testMethod, result, methodTime_ms) {
    return { category: (category)
      , testMethod: (testMethod)
      , result: (result)
      , methodTime_ms: (methodTime_ms)}
  }
  
  /**
  * Runs simplified, simulated test using ToEqual() matcher
  * @param {string} testName 
  * @param {string} actual 
  * @param {string} expected 
  * @param {string} timeTaken 
  * @returns {outputInfo} 
  */
  _runTest(category, testName, actual, expected, timeTaken) {
    result := this._runMatcher("toEqual", actual, expected)
    outputInfo := this._setOutputInfo(category, testName, result, timeTaken)
    return outputInfo
  }

  _setup() {
    ; Yunit.SetOptions({EnablePrivateProps: true, TimingWarningThreshold: 100})
    return new TestStdout("")
  }

  beforeEach() {
    this.module := ConsoleOutputTest._setup()
  }

  convert_indentation_level_to_spaces() {
    noSpaces   := this.module.indentationToSpaces(0)
    twoSpaces  := this.module.indentationToSpaces(1)
    fourSpaces := this.module.indentationToSpaces(2)

    Yunit.expect(noSpaces).toBe("")
    Yunit.expect(twoSpaces).toBe("  ")
    Yunit.expect(fourSpaces).toBe("    ")
  }
  
  print_text_with_lf() {
    this.module.printLine(0, "Test data")

    Yunit.expect(this.module.test_printOutput).toBe("Test data`n")
  }

  print_one_line_with_indentation_level1() {
    this.module.print(1, "Test data")

    Yunit.expect(this.module.test_printOutput).toBe("  Test data")
  }

  print_multiline_text_with_indentation_level1() {
    this.module.print(1, "Test data`nSecond line")

    Yunit.expect(this.module.test_printOutput)
          .toBe("  Test data`n  Second line")
  }
  
  remove_ansi_placeholders_from_formatString() {
    this.module.print(0, "{format.text}Test data{reset}")
    
    Yunit.expect(this.module.test_printOutput).toBe("Test data")
  }

  replace_ansi_placeholders_in_formatString() {
    this.module.useAnsiEscapes := true
    esc := chr(27)
    formattedString := esc "[0;37mTest data" esc "[0m"
    
    this.module.print(0, "{format.text}Test data{reset}")
    
    Yunit.expect(this.module.test_printOutput).toEqual(formattedString)
  }
  
  perform_an_ansi_reset_before_printing_an_lf() {
    this.module.useAnsiEscapes := true
    esc := chr(27)
    formattedString := esc "[0;37mTest data" esc "[0m`n"
    
    this.module.printLine(0, "{format.text}Test data")
    
    Yunit.expect(this.module.test_printOutput).toEqual(formattedString)
  }
  
  print_categories_if_not_already_printed() {
    expected := "Category1`n  sub1`n"
    
    this.module.printNewCategories("Category1.sub1")
    
    Yunit.expect(this.module.test_printOutput).toEqual(expected)
  }
  
  dont_print_categories_that_are_already_printed() {
    m := this.module
    
    m.printNewCategories("Category1.sub1")
    m.printNewCategories("Category1.sub1")
    
    Yunit.expect(m.test_printOutput).toEqual("Category1`n  sub1`n")
  }

  print_new_categories_after_other_categories_already_printed() {
    m := this.module
    expected := "Category1`n  sub1`nCategory2`n  sub2`n"
    
    m.printNewCategories("Category1.sub1")
    m.printNewCategories("Category2.sub2")
    
    Yunit.expect(m.test_printOutput).toEqual(expected)
  }
  
  _runPrintInfoTest(category, testName, actual, expected, timeTaken) {
    this.module.printNewCategories(category)
    outputInfo := this._runTest(category, testName, actual, expected, timeTaken)
    this.module.printTestInfo(outputInfo)
  }
  
  print_test_info_for_passed_test_with_time() {
    this._runPrintInfoTest("Category1", "tests_a_behavior", "def", "def", 5)
    
    Yunit.expect(this.module.test_printOutput).toBe("Category1`n  [Pass] tests_a_behavior (5 ms)`n")
  }
  
  print_test_info_for_passed_test_dont_show_time_below1ms() {
    this._runPrintInfoTest("Category1", "tests_a_behavior", "def", "def", 0)
    
    Yunit.expect(this.module.test_printOutput).toBe("Category1`n  [Pass] tests_a_behavior`n")
  }

  print_test_info_for_failed_test() {
    this._runPrintInfoTest("Category1", "tests_a_behavior", "def", "ghi", 5)
    
    Yunit.expect(this.module.test_printOutput).toBe("Category1`n  [Fail] tests_a_behavior`n")
  }
  
  update_summary_data_for_tests() {
    m := this.module
    tests := []
    Yunit.SetOptions({TimingWarningThreshold: 20})
        
    tests.push(this._runTest("Category1", "test1", "abc", "abc", 5))
    tests.push(this._runTest("Category1", "test2", "def", "def", 21))
    tests.push(this._runTest("Category1", "test3", "def", "ghi", 5))
    
    for index, outputInfo in tests {
      m.Update(outputInfo)
    }
    
    expectedSummary := { passed: {count: 2, timeTaken: 26}
    , failed: {count: 1}
    , slowTests: {count: 1, timeTaken: 21}
    , overall: {count: 3} }
    Yunit.expect(m.test_thisValue.tests).toEqual(tests)
    Yunit.expect(m.test_thisValue.summary).toEqual(expectedSummary)
  }
  
}
