Class Test_ConsoleOutput extends ConsoleOutputBase {

  test_printOutput := ""
  test_thisValue := {}
  useAnsiEscapes := false
  
    Update(objOutputInfo) {
    base.Update(objOutputInfo)
    this.test_thisValue := {tests: (this.tests), summary: (this.summary)}  
  }
  
  /**
  * Prints to console
  * @override
  * @param {string} text - text to print 
  * @returns {void} 
  */
  printOutput(text) {
    this.test_printOutput .= text    
  }
  
  /**
  * Pre-processes text
  * Must be used to add/remove Ansi escapes
  * @override
  * @param {string} text - text to pre-process 
  * @returns {void} 
  */
  printPreProcess(text) {
    text := this.convertAnsiPlaceholders(text, this.useAnsiEscapes)
    return text
  }

}

