Class ConsoleOutputBase {
  
  defaults := { indent: 2}
  ansiEscapes := {"format.text": "37", "format.textDimmed": "90", "format.ok": "92", "format.error": "91","format.errorPath": "91;1", "format.slowTest": "95", "format.slowTestPath": "95;1", "reset": "0" }
  categories := {}
  
  ; instance variables
  ; tests[] - object array
  ; summary = {passed: {count, timeTaken}, failed: {count}, slowTests: {count, timeTaken}, overall: {count}}
  
  __New(instance) {
    
  }
  
  /**
  * Called by Yunit tester to send test data to output module
  * @param {outputInfo} objOutputInfo
  * {category, testName, result, methodTime_ms}
  * @returns {void} 
  */
  Update(objOutputInfo) {
    
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
  * @param {integer} indentationLevel 
  * @param {string} [formatStr] - passed to Format()
  * @param {any*} values  - values for Format()
  * @returns {void} 
  */
  printLine(indentationLevel, formatStr := "", values*) {
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
        out .= this._buildAnsiEscape(m[1])
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
  _buildAnsiEscape(placeholder) {
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
    formatStr := "{1}[{2}] {format.textDimmed}{3}"
    switch {
      case this.isError(outputInfo.result):
        status := "Fail"
        statusFormat := "{format.error}"
      default:
        status := "Pass"
        statusFormat := "{format.ok}"
        switch {
          case outputInfo.methodTime_ms > Yunit.options.timingWarningThreshold:
            formatStr .= " {format.slowTest}({4} ms)"
          case outputInfo.methodTime_ms > 0:
            formatStr .= " ({4} ms)"
        }
    }
    indent := this.categories[outputInfo.category]
    this.printLine(indent, formatStr, statusFormat, status
      , outputInfo.testMethod, outputInfo.methodTime_ms)
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

}
