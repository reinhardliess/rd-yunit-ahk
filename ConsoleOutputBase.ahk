Class ConsoleOutputBase {
  
  defaults := { indent: 2}
  
  __New(instance) {
    
  }
  
  ; category, testName, result, methodTime_ms
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
  
  printLn(text, indentationLevel := 0) {
    this.print(text "`n", indentationLevel)
  }
  
  print(text, indentationLevel := 0) {
    replaceStr := this.indentationToSpaces(indentationLevel) "$0"
    newText := RegexReplace(text, "`am)^.", replaceStr)
    this.printOutput(newText)
    return 
  }
  
  /**
  * Prints to console
  * @abstract
  * @param {string} text - text to print 
  * @returns {void} 
  */
  printOutput(text) {
    
  }
}
