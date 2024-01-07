Class ConsoleOutputBase {
  
  ; config data
  defaults := { indent: 2}
  ansiEscapes := {"format.text": "37", "format.textDimmed": "90"
    , "format.ok": "92", "format.error": "91","format.errorPath": "91;1"
    , "format.slowTest": "96", "format.slowTestPath": "96;1", "reset": "0" }
  
  ; test data
  categories := {}
  tests := []
  summary := { passed: {count: 0, timeTaken: 0}
    , failed: {count: 0}
    , slowTests: {count: 0, timeTaken: 0}
    , overall: {count: 0} }
  
  __New(instance) {
    
  }
  
  /**
  * Called by Yunit tester to send test data to output module
  * @param {outputInfo} objOutputInfo
  * {category, testName, result, methodTime_ms}
  * @returns {void}
  */
  Update(objOutputInfo) {
    this.tests.push(objOutputInfo)
    this.summary.overall.count++
    switch {
      case this.isError(objOutputInfo.result):
        this.summary.failed.count++
      default:
        this.summary.passed.count++
        this.summary.passed.timeTaken += objOutputInfo.methodTime_ms
        if (objOutputInfo.methodTime_ms > Yunit.options.TimingWarningThreshold) {
          this.summary.slowTests.count++
          this.summary.slowTests.timeTaken += objOutputInfo.methodTime_ms
        }
    }
  }
  
  /**
  * Tests whether a variable is an error object
  * @param {any} var - variable to test 
  * @returns {boolean} 
  */
  isError(var) {
    if (IsObject(var) 
      && var.hasKey("message")
      && var.hasKey("what")
      && var.hasKey("file")
      && var.hasKey("line")) {
      return true
    }
    return false
  }

  /**
  * Prints test results with categories
  * @returns {void} 
  */
  printTestResults() {
    for testNumber, test in this.tests {
      this.printNewCategories(test.category)
      this.printTestInfo(test)
    }
  }
  
  /**
  * Prints new categories with indentation
  * @param {string} newCategories
  * @returns {void} 
  */
  printNewCategories(newCategories) {
    if (this.categories.hasKey(newCategories)) {
      return
    }
    splitCategories := StrSplit(newCategories, ".")
    category := ""
    for index, value in splitCategories {
      category .= index == 1 ? value : "." value
      if (!this.categories.hasKey(category)) {
        this.categories[category] := index
        this.printLine(index - 1, "{format.text}{1}", value)
      }
    }
  }
  
  /**
  * Prints text to console with LF (formatted)
  * @param {integer} [indentationLevel:=0] 
  * @param {string} [formatStr:""] - passed to Format()
  * @param {any*} values  - values for Format()
  * @returns {void} 
  */
  printLine(indentationLevel := 0, formatStr := "", values*) {
    this.print(indentationLevel, formatStr "{reset}`n", values*)
  }
  
  /**
  * Prints text to console 
  * @param {integer} indentationLevel 
  * @param {string} formatStr - passed to Format(), printPreProcess()
  * @param {any*} values  - values for Format()
  * @returns {void} 
  */
  print(indentationLevel, formatStr, values*) {
    formatted := format(formatStr, values*)
    text := this.printPreProcess(formatted)
    replaceStr := this.indentationToSpaces(indentationLevel) "$0"
    newText := RegexReplace(text, "`am)^.", replaceStr)
    this.printOutput(newText)
  }

  /**
  * Pre-processes text
  * Adds/removes Ansi escapes
  * @param {string} text - text to pre-process 
  * @returns {string} 
  */
  printPreProcess(text) {
    useEscapes := this.useAnsiEscapes()
    return this.convertAnsiPlaceholders(text, useEscapes)
  }

  
  /**
  * Should return true if Ansi escapes should be used
  * @abstract
  * @returns {boolean} 
  */
  useAnsiEscapes() {
    
  }
  
  /**
  * Removes or replaces Ansi escape placeholders
  * @param {string} text - text to process
  * @param {boolean} [AddRemove:=false] - true, to add Ansi escapes
  * @returns {string} 
  */
  convertAnsiPlaceholders(text, AddRemove := false) {
    startPos := 1
    out := ""
    ; https://regex101.com/r/PLZInp/latest
    while (pos := RegexMatch(text, "iO){([a-z.]+)}", m, startPos)) {
      out .= SubStr(text, startPos, pos - startPos)
      startPos := pos + m.len[0]
      if (addRemove) {
        out .= this.buildAnsiEscape(m[1])
      } else {
        continue
      }
    }
    return out SubStr(text, startPos)
  }
  
  /**
  * Converts placeholder into Ansi escape sequence
  * @param {string} placeholder
  * @returns {string} 
  */
  buildAnsiEscape(placeholder) {
    ansiString := this["ansiEscapes"][placeholder]
    if !(placeholder ~= "i)^format\.") {
      return chr(27) "[" ansiString "m"
    }
    out := format("{1}[{2};{3}m", chr(27), this.ansiEscapes.reset, ansiString)
    return out
  }

  /**
  * converts indentation level to # of spaces
  * @param {number} level - indentation level
  * @returns {string}
  */
  indentationToSpaces(level) {
    indentInSpaces := ""
    Loop % (level * this.defaults.indent) {
      indentInSpaces .= A_Space
    }
    return indentInSpaces
  }
  
  /**
  * Prints text to output
  * @abstract
  * @param {string} text - text to print 
  * @returns {void} 
  */
  printOutput(text) {
  }

  /**
  * Prints test info (one line)
  * @param {OutputInfo} outputInfo 
  * @returns {void} 
  */
  printTestInfo(outputInfo) {
    ; 1: statusFormat, 2: status, 3: testMethod, 4: methodTime_ms
    methodTime_ms := outputInfo.methodTime_ms
    formatStr := "{1}[{2}] {format.textDimmed}{3}"
    switch {
      case this.isError(outputInfo.result):
        status := "Fail"
        statusFormat := "{format.error}"
      default:
        status := "Pass"
        statusFormat := "{format.ok}"
        switch {
          case methodTime_ms > Yunit.options.timingWarningThreshold:
            formatStr .= " {format.slowTest}({4} ms)"
          case methodTime_ms > 0:
            formatStr .= " ({4} ms)"
        }
    }
    indent := this.categories[outputInfo.category]
    this.printLine(indent, formatStr, statusFormat, status
      , outputInfo.testMethod, methodTime_ms)
  }
  
  /**
  * Prints detailed info for each error
  * @returns {void} 
  */
  printErrorOverview() {
    errorCount := 0
    for testNumber, test in this.tests {
      if (!this.isError(test.result)) {
        continue
      }
      errorCount++
      if (errorCount > 1) {
        this.printLine()
      }
      this.printErrorPath(test)
      this.printLine()
      switch Yunit.Util.GetType(test.result) {
        case "Yunit.AssertionError":
          this.printErrorHeader(test.result)
          this.printLine()
          this.printErrorDetails(test.result)
        default:
          this.printLine(1, "{format.text}{1}", test.result.message )
      }
      this.printLine()
      this.printErrorFilePath(test.result)
    }
  }

  /**
  * Prints categories and test name as breadcrumbs
  * @param {outputInfo} outputInfo
  * @returns {void} 
  */
  printErrorPath(outputInfo) {
    formatHeading := "{format.errorPath}* {1}"
    this.printLine(0, formatHeading, StrReplace(outputInfo.category "." outputInfo.testMethod, "." , " > "))
  }
  
  /**
  * Prints header for matcher output
  * @param {object} errorObj
  * @returns {void} 
  */
  printErrorHeader(errorObj) {
    formatHeader := "{format.text}expect({format.error}actual{format.text}).{1}({format.ok}expected{format.text})"
    this.printLine(1, formatHeader, errorObj.matcherInfo.getMatcherType())
    message := errorObj.matcherInfo.message
    if (message) {
      this.printLine()
      this.printLine(1, message)
    }
  }
  
  /**
  * Prints actual/expected error details
  * @param {object} errorObj
  * @returns {void} 
  */
  printErrorDetails(err) {
    ; matcher := "getMatcherOutput" err.matcherInfo.matcherType
    ; output := this[matcher](err)
    output := err.matcherInfo.GetErrorOutput()
    output := this.injectAnsiPlaceholdersIntoMatcherOutput(output)
    this.printLine(1, output)
  }
  
  getMatcherOutputToBe(err) {
    actual   := err.matcherInfo.actual
    expected := err.matcherInfo.expected
    
    switch {
      case isObject(actual):
        actual := "[object]"
      default:
        actual := this.formatActualTestValue(actual)
    }
    
    switch {
      case isObject(expected):
        expected := "[object]"
      default:
        expected := this.formatExpectedTestValue(expected)
    }
    
    formatStr := "Actual:   {1}`nExpected: {2}"
    return format(formatStr, actual, expected)
  }
  
  formatActualTestValue(value) {
    return this.formatTestValue("actual", value)  
  }
  
  formatExpectedTestValue(value) {
    return this.formatTestValue("expected", value)  
  }
  
  /**
  * Formats test value for output in actual/expected block
  * @param {string} type - "actual" or "expected"
  * @param {string} value
  * @returns {string} 
  */
  formatTestValue(type, value) {
    newValue := value
    switch {
      case isObject(value):
        newValue := Yunit.Util.Print(value)
        if (!newValue) {
          newValue := "{}"
        }
      case Yunit.Util.IsFloat(value):
        newValue := Format("{1:.17g}", value)
      case Yunit.Util.GetType(value) = "String":
        textFormat := type = "actual" ? "{format.error}" : "{format.ok}"
        newValue := this.renderWhiteSpace(value, textFormat)
        newValue := """" newValue """"
    }
    return newValue
  }
  
  /**
  * Renders white space characters
  * @param {string} string
  * @param {string} textFormat - Ansi placeholder 
  * @returns {string} 
  */
  renderWhiteSpace(string, textFormat) {
    if (!Yunit.options.outputRenderWhiteSpace) {
      return string
    }
    buffer := StrReplace(string, "`r`n", "{format.textDimmed}``r``n" textFormat)
    buffer := StrReplace(buffer, "`n", "{format.textDimmed}``n" textFormat)
    buffer := StrReplace(buffer, chr(27), "{format.textDimmed}``e" textFormat)
    
    return buffer
  }

  getMatcherOutputToEqual(err) {
    actual   := err.matcherInfo.actual
    expected := err.matcherInfo.expected
    
    actual := this.formatActualTestValue(actual)
    expected := this.formatExpectedTestValue(expected)
    
    formatStr := "Actual:   {1}`nExpected: {2}"
    return format(formatStr, actual, expected)
  }
  
  getMatcherOutputToBeCloseTo(err) {
    formatStr :="
    (Ltrim
    Actual:   {1}
    Expected: {2}
    
    Actual difference:     {3}
    Expected difference: < {4:.$$f}
    Expected precision:    {5}
    )"
    
    expected  := err.matcherInfo.expected
    actual    := err.matcherInfo.actual
    formatStr := StrReplace(formatStr, "$$", expected.digits + 1)
    
    output := format(formatStr
      , this.formatActualTestValue(actual.value)
      , this.formatExpectedTestValue(expected.value)
      , this.formatActualTestValue(actual.difference)
      , expected.difference
      , expected.digits)
    
    return output
  }
  
  /**
  * Inserts Ansi placeholders into actual/expected output
  * @param {string} output
  * @returns {string} 
  */
  injectAnsiPlaceholdersIntoMatcherOutput(output) {
    text := RegexReplace(output, "`aim)(^actual|^expected).*?:\s+", "{format.text}$0")
    text := RegexReplace(text, "`aim)^{format\.text}+actual.*?:\s+", "$0{format.error}")
    text := RegexReplace(text, "`aim)^{format\.text}+expected.*?:\s+", "$0{format.ok}")
    return text
  }
  
  /**
  * Prints clickable file name in error output
  * @param {string} err - error object
  * @returns {void} 
  */
  printErrorFilePath(err) {
    this.printLine(1, "{format.textDimmed}({1}:{2})", err.file, err.line)
  }
  
  printTestSummary() {
    passed := this.summary.passed
    failed := this.summary.failed
    slowTests := this.summary.slowTests
    
    if (passed.count > 0) {
      statusPassed := "{format.ok}{1:3d} passing ({2:d} ms)"
      this.printLine(0, statusPassed, passed.count, passed.timeTaken)
    }
    if (failed.count > 0) {
      statusFailed := "{format.error}{1:3d} failing"
      this.printLine(0, statusFailed, failed.count)
    }
    if (slowTests.count > 0) {
      statusSlow := "{format.slowTest}{1:3d} slow {2} ({3:d} ms)"
      this.printLine(0, statusSlow
        , slowTests.count
        , slowTests.count > 1 ? "tests" : "test"
        , slowTests.timeTaken)
    }
  }
  
}
