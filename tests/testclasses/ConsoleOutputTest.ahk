; cspell:ignore dont ansi
;; ConsoleOutputTest
Class ConsoleOutputTest {
  
  ;; static helper methods
  
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

  beforeEachAll(thisArg) {
    thisArg.m := new Test_ConsoleOutput("")
  }
  
  ;; Printing
  Class Printing {
    convert_indentation_level_to_spaces() {
      noSpaces   := this.m.indentationToSpaces(0)
      twoSpaces  := this.m.indentationToSpaces(1)
      fourSpaces := this.m.indentationToSpaces(2)
  
      Yunit.expect(noSpaces).toBe("")
      Yunit.expect(twoSpaces).toBe("  ")
      Yunit.expect(fourSpaces).toBe("    ")
    }
    
    print_text_with_lf() {
      this.m.printLine(0, "Test data")
  
      Yunit.expect(this.m.test_printOutput).toBe("Test data`n")
    }
  
    print_one_line_with_indentation_level1() {
      this.m.print(1, "Test data")
  
      Yunit.expect(this.m.test_printOutput).toBe("  Test data")
    }
  
    print_multiline_text_with_indentation_level1() {
      this.m.print(1, "Test data`nSecond line")
  
      Yunit.expect(this.m.test_printOutput)
            .toBe("  Test data`n  Second line")
    }
  }
  
  ;; Ansi
  Class Ansi {
    remove_ansi_placeholders_from_formatString() {
      this.m.print(0, "{format.text}Test data{reset}")
      
      Yunit.expect(this.m.test_printOutput).toBe("Test data")
    }
  
    replace_ansi_placeholders_in_formatString() {
      this.m.test_useAnsiEscapes := true
      esc := chr(27)
      formattedString := esc "[0;37mTest data" esc "[0m"
      
      this.m.print(0, "{format.text}Test data{reset}")
      
      Yunit.expect(this.m.test_printOutput).toEqual(formattedString)
    }
    
    perform_an_ansi_reset_before_printing_an_lf() {
      this.m.test_useAnsiEscapes := true
      esc := chr(27)
      formattedString := esc "[0;37mTest data" esc "[0m`n"
      
      this.m.printLine(0, "{format.text}Test data")
      
      Yunit.expect(this.m.test_printOutput).toEqual(formattedString)
    }
  
    inject_ansi_placeholders_into_matcher_output() {
      matcherOutput := "
      (LTrim
      Actual:   5
      Expected: 6
      )"
      expected := "
      (LTrim
      {format.text}Actual:   {format.error}5
      {format.text}Expected: {format.ok}6
      )"
      
      output := this.m.injectAnsiPlaceholdersIntoMatcherOutput(matcherOutput)
      
      Yunit.expect(output).toEqual(expected)
    
    }
  }
  
  ;; Print test results
  Class Print_test_results {
    
    print_categories_if_not_already_printed() {
      expected := "Category1`n  sub1`n"
      
      this.m.printNewCategories("Category1.sub1")
      
      Yunit.expect(this.m.test_printOutput).toEqual(expected)
    }
    
    dont_print_categories_that_are_already_printed() {
      this.m.printNewCategories("Category1.sub1")
      this.m.printNewCategories("Category1.sub1")
      
      Yunit.expect(this.m.test_printOutput).toEqual("Category1`n  sub1`n")
    }
  
    print_new_categories_after_other_categories_already_printed() {
      expected := "Category1`n  sub1`nCategory2`n  sub2`n"
      
      this.m.printNewCategories("Category1.sub1")
      this.m.printNewCategories("Category2.sub2")
      
      Yunit.expect(this.m.test_printOutput).toEqual(expected)
    }
    
    _runPrintInfoTest(category, testName, actual, expected, timeTaken) {
      this.m.printNewCategories(category)
      outputInfo := ConsoleOutputTest._runTest(category, testName, actual, expected, timeTaken)
      this.m.printTestInfo(outputInfo)
    }
    
    print_test_info_for_passed_test_with_time() {
      this._runPrintInfoTest("Category1", "tests_a_behavior", "def", "def", 5)
      
      Yunit.expect(this.m.test_printOutput).toBe("Category1`n  [Pass] tests_a_behavior (5 ms)`n")
    }
    
    print_test_info_for_passed_test_dont_show_time_below1ms() {
      this._runPrintInfoTest("Category1", "tests_a_behavior", "def", "def", 0)
      
      Yunit.expect(this.m.test_printOutput).toBe("Category1`n  [Pass] tests_a_behavior`n")
    }
  
    print_test_info_for_failed_test() {
      this._runPrintInfoTest("Category1", "tests_a_behavior", "def", "ghi", 5)
      
      Yunit.expect(this.m.test_printOutput).toBe("Category1`n  [Fail] tests_a_behavior`n")
    }
  
  }
  
  ;; Error details
  Class Print_error_details {
    print_categories_and_testname_as_breadcrumbs_for_error() {
      outputInfo := ConsoleOutputTest._runTest("Category1.sub1", "test3", "def", "ghi", 5)
      expected := "* Category1 > sub1 > test3`n"
      
      this.m.printErrorPath(outputInfo)
      
      Yunit.expect(this.m.test_PrintOutput).toEqual(expected)
    }
    
    ; print_expect_header_with_additional_expect_parameter() {
    ;   err := ConsoleOutputTest._runMatcher("toBeCloseTo", 0.3, 0.29)
    ;   expected := "  expect(actual).ToEqual(expected)`n"
      
    ;   this.m.printErrorHeader(err.matcher)
      
    ;   Yunit.expect(this.m.test_PrintOutput).toEqual(expected)
    ; }
  
    ; print_expect_header_with_message() {
    ;   err := ConsoleOutputTest._runMatcher("toEqual", 5, 6)
    ;   err.matcher.message := "error message"
    ;   expected := "  expect(actual).ToEqual(expected)`n`n  error message`n"
      
    ;   this.m.printErrorHeader(err.matcher)
      
    ;   Yunit.expect(this.m.test_PrintOutput).toEqual(expected)
    ; }
    
    print_file_path_error_info() {
      err := ConsoleOutputTest._runMatcher("toEqual", 5, 6)
      err.file := "d:\src\test.ahk"
      err.line := 25
  
      this.m.printErrorFilePath(err)
      
      expected := "  (d:\src\test.ahk:25)`n"
      Yunit.expect(this.m.test_PrintOutput).toEqual(expected)
    }
    
    update_summary_data_for_tests() {
      tests := []
      Yunit.SetOptions({TimingWarningThreshold: 20})
          
      tests.push(ConsoleOutputTest._runTest("Category1", "test1", "abc", "abc", 5))
      tests.push(ConsoleOutputTest._runTest("Category1", "test2", "def", "def", 21))
      tests.push(ConsoleOutputTest._runTest("Category1", "test3", "def", "ghi", 5))
      
      for index, outputInfo in tests {
        this.m.Update(outputInfo)
      }
      
      expectedSummary := { passed: {count: 2, timeTaken: 26}
      , failed: {count: 1}
      , slowTests: {count: 1, timeTaken: 21}
      , overall: {count: 3} }
      Yunit.expect(this.m.test_thisValue.tests).toEqual(tests)
      Yunit.expect(this.m.test_thisValue.summary).toEqual(expectedSummary)
    }
    
    print_test_summary() {
      this.m.summary := { passed: {count: 2, timeTaken: 26}
      , failed: { count: 1}
      , slowTests: { count: 1, timeTaken: 21} }
      
      printedSummary := "
      (
  2 passing (26 ms)
  1 failing
  1 slow test (21 ms)`n
      )"
        
      this.m.printTestSummary()
      
      Yunit.expect(this.m.test_PrintOutput).toEqual(printedSummary)
    }
  }
}
