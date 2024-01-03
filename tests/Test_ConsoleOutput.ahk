#Include ../ConsoleOutputBase.ahk

Class Test_ConsoleOutput extends ConsoleOutputBase {

  test_printOutput := ""
  test_thisValue := {}
  test_useAnsiEscapes := false
  
  Update(objOutputInfo) {
    super.Update(objOutputInfo)
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
  * Should return true if Ansi escapes should be used
  * @override
  * @returns {boolean} 
  */
  useAnsiEscapes() {
    return this.test_useAnsiEscapes
  }

}

