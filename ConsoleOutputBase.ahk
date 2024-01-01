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
  * Must be used to add/remove Ansi escapes
  * @abstract
  * @param {string} text - text to pre-process 
  * @returns {void} 
  */
  printPreProcess(text) {
    
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
    formatHeader := "expect({format.error}actual{format.text}).{1}({format.ok}expected{format.text})"
    this.printLine(1, formatHeader, errorObj.matcherInfo.matcherType)
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
    matcher := "getMatcherOutput" err.matcherInfo.matcherType
    output := this[matcher](err)
    ; output := this.injectAnsiPlaceholdersIntoMatcherOutput(output)
    this.printLine(1, output)
  }
  
  /**
  * Inserts Ansi placeholders into actual/expected output
  * @param {string} output
  * @returns {string} 
  */
  injectAnsiPlaceholdersIntoMatcherOutput(output) {
    text := RegexReplace(output, "`aim)(actual|expected).*:\s+", "{format.text}$0")
    text := RegexReplace(text, "`aim)^{format\.text}+actual.*:\s+", "$0{format.error}")
    text := RegexReplace(text, "`aim)^{format\.text}+expected.*:\s+", "$0{format.ok}")
    return text
  }
  
  formatTestValue(value) {
    newValue := value
    switch {
      case isObject(value):
        newValue := Yunit.Util.Print(value)
      case Yunit.Util.IsFloat(value):
        newValue := Format("{1:.17g}", value)
      case Yunit.Util.GetType(value) = "String":
        ; actual := StrReplace(actual, chr(27), Chr(27) "[90m" "esc" chr(27) "[91m")
        newValue := """" value """"
    }
    return newValue
  }
  
  getMatcherOutputToBe(err) {
    actual   := err.matcherInfo.actual
    expected := err.matcherInfo.expected
    
    switch {
      case isObject(actual):
        actual := "[object]"
      default:
        actual := this.formatTestValue(actual)
    }
    
    switch {
      case isObject(expected):
        expected := "[object]"
      default:
        expected := this.formatTestValue(expected)
    }
    
    formatStr := "Actual:   {1}`nExpected: {2}"
    return format(formatStr, actual, expected)
  }
  
  getMatcherOutputToEqual(err) {
    actual   := err.matcherInfo.actual
    expected := err.matcherInfo.expected
    
    actual := this.formatTestValue(actual)
    expected := this.formatTestValue(expected)
    
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
      , this.formatTestValue(actual.value)
      , this.formatTestValue(expected.value)
      , this.formatTestValue(actual.difference)
      , expected.difference
      , expected.digits)
    
    return output
  }
}
