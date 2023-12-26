Class TestStdout extends ConsoleOutputBase {

  _test_printOutput := ""
  
  __Delete() {

  }
  
  test_PrintOutput {
    get {
      return this._test_printOutput
    }
  
    set {
      return this._test_printOutput := value
    }
  }  
  
  /**
  * Prints to console
  * @override
  * @param {string} text - text to print 
  * @returns {void} 
  */
  printOutput(text) {
    ; global test_printOutput
    this.test_PrintOutput .= text    
  }
}
  
