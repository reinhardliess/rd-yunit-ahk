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
}