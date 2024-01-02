class YunitStdOut extends ConsoleOutputBase {
  
  __Delete() {
    this.printTestResults()
    if (this.summary.failed.count > 0) {
      this.printLine()
      this.printErrorOverview()
    }
    this.printLine()
    this.printTestSummary()
  }
  
  /**
  * Prints to console
  * @override
  * @param {string} text - text to print 
  * @returns {void} 
  */
  printOutput(text) {
    FileAppend, %text%, *, UTF-8
  }
  
  /**
  * Pre-processes text
  * Must be used to add/remove Ansi escapes
  * @override
  * @param {string} text - text to pre-process 
  * @returns {void} 
  */
  printPreProcess(text) {
    text := this.convertAnsiPlaceholders(text, true)
    return text
  }
}
