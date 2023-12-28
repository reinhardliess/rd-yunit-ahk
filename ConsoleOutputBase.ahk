Class ConsoleOutputBase {
  
  defaults := { indent: 2}
  ansiEscapes := {"format.text": "37", "format.textDimmed": "90", "format.ok": "92", "format.error": "91","format.errorPath": "91;1", "format.slowTest": "95", "format.slowTestPath": "95;1", "reset": "0" }
  
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
  * @param {string} formatStr - passed to Format()
  * @param {any*} values  - values for Format()
  * @returns {void} 
  */
  printLine(indentationLevel, formatStr, values*) {
    this.print(indentationLevel, formatStr "{reset}`n", values*)
  }
  
  /**
  * Prints text to console 
  * @param {integer} indentationLevel 
  * @param {string} formatStr - passed to Format()
  * @param {any*} values  - values for Format()
  * @returns {void} 
  */
  print(indentationLevel, formatStr, values*) {
    newFormatStr := this.printPreProcess(formatStr)
    text := format(newFormatStr, values*)
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
  * Removes Ansi escape placeholders or replaces them
  * @param {string} text - text to process
  * @param {integer} [AddRemove:=false] - true, to add Ansi escapes
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
}
