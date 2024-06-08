#Include ./Yunit.ahk

Class ConsoleOutputBase {
  
  ; config data
  defaults := { indent: 2}
  ansiEscapes := Map("format.text", "37", "format.textDimmed", "90"
    , "format.ok", "92", "format.error", "91","format.errorPath", "91;1"
    , "format.slowTest", "96", "format.slowTestPath", "96;1", "reset", "0")
  
  ; test data
  categories := Map()
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
      case Yunit.Util.isError(objOutputInfo.result):
        this.summary.failed.count++
      default:
        this.summary.passed.count++
        this.summary.passed.timeTaken += objOutputInfo.methodTime_ms
        if (this.isSlowTest(objOutputInfo.methodTime_ms)) {
          this.summary.slowTests.count++
          this.summary.slowTests.timeTaken += objOutputInfo.methodTime_ms
        }
    }
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
    if (this.categories.has(newCategories)) {
      return
    }
    splitCategories := StrSplit(newCategories, ".")
    category := ""
    for index, value in splitCategories {
      category .= index == 1 ? value : "." value
      if (!this.categories.has(category)) {
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
    return false
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
    while (pos := RegexMatch(text, "i){([a-z.]+)}", &m, startPos)) {
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
    ansiString := this.ansiEscapes[placeholder]
    if !(placeholder ~= "i)^format\.") {
      return chr(27) "[" ansiString "m"
    }
    out := format("{1}[{2};{3}m", chr(27), this.ansiEscapes["reset"], ansiString)
    return out
  }

  /**
  * converts indentation level to # of spaces
  * @param {number} level - indentation level
  * @returns {string}
  */
  indentationToSpaces(level) {
    indentInSpaces := ""
    Loop (level * this.defaults.indent) {
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
      case Yunit.Util.isError(outputInfo.result):
        status := "Fail"
        statusFormat := "{format.error}"
      default:
        status := "Pass"
        statusFormat := "{format.ok}"
        switch {
          case this.isSlowTest(methodTime_ms):
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
  * Prints all slow tests
  * @returns {void} 
  */
  printSlowTestOverview() {
    slowTests := 0
    for testNumber, test in this.tests {
      if (Yunit.Util.isError(test.result) || !this.isSlowTest(test.methodTime_ms)) {
        continue
      }
      slowTests++
      if (slowTests > 1) {
        this.printLine()
      }
      this.printSlowTestPath(test)
    }
  }

  /**
  * Prints detailed info for each error
  * @returns {void} 
  */
  printErrorOverview() {
    errorCount := 0
    for testNumber, test in this.tests {
      if (!Yunit.Util.isError(test.result)) {
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
          this.printErrorHeader(test.result.matcher)
          this.printLine()
          this.printErrorDetails(test.result.matcher)
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
  * Prints categories and test name as breadcrumbs
  * @param {outputInfo} outputInfo
  * @returns {void} 
  */
  printSlowTestPath(outputInfo) {
    formatHeading := "{format.slowTestPath}* {1} ({2} ms)"
    this.printLine(0
      , formatHeading
      , StrReplace(outputInfo.category "." outputInfo.testMethod, "." , " > ")
      , outputInfo.methodTime_ms)
  }

  /**
  * Should a test be counted as a slow test
  * @param {number} elapsed_ms - time for test 
  * @returns {boolean} 
  */
  isSlowTest(elapsed_ms) {
    return elapsed_ms > Yunit.options.TimingWarningThreshold
  }
  
  /**
  * Prints header for matcher output
  * expect(actual).Matcher(expected, params) ; comment
  * @param {Yunit.Matchers.MatcherBase} matcher
  * @returns {void} 
  */
  printErrorHeader(matcher) {
    if (params := matcher.GetAdditionalExpectParams()) {
      params := ", " Yunit.Util.Join(params, ", ")
    }
    if (comment := matcher.GetExpectComment()) {
      comment := " `; " comment
    }
    
    formatHeader := "{format.text}expect({format.error}actual{format.text}).{1}({format.ok}expected{2}{format.text}){format.textDimmed}{3}"
    this.printLine(1, formatHeader
      , matcher.getMatcherType()
      , params
      , comment)
    
    if (matcher.HasProp("message") && matcher.message) {
      this.printLine()
      this.printLine(1, "{format.text}{1}", matcher.message )
    }
  }
  
  /**
  * Prints actual/expected error details
  * @param {Yunit.Matchers.MatcherBase} matcher
  * @returns {void} 
  */
  printErrorDetails(matcher) {
    output := matcher.GetErrorOutput()
    if (!isObject(output)) {
      output := [output]
    }
    for i, errorBlock in output {
      withAnsi := this.insertAnsiPlaceholdersIntoMatcherOutput(errorBlock)
      if (i > 1) {
        this.printLine()
      }
      this.printLine(1, withAnsi)
    }
  }
  
  /**
  * Inserts Ansi placeholders into actual/expected output
  * This heuristic will save lots of work in matcher output methods
  * but in rare cases might end up with wrong colors (That's OK)
  * @param {string} output
  * @returns {string} 
  */
  insertAnsiPlaceholdersIntoMatcherOutput(output) {
    text := "{format.text}" output
    text := RegexReplace(text, "`aim)(^actual|^expected).*?:\s+", "{format.text}$0")
    text := RegexReplace(text, "`aim)^{format\.text}+actual.*?:\s+", "$0{format.error}")
    text := RegexReplace(text, "`aim)^{format\.text}+expected.*?:\s+", "$0{format.ok}")
    text := RegexReplace(text, "`am)$", "{format.text}$0")
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
