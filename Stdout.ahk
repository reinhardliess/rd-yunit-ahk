#Include %A_LineFile%\..\ConsoleOutputBase.ahk

class YunitStdOut extends ConsoleOutputBase {
  
  __Delete() {
    this.printTestResults()
    if (this.summary.slowTests.count > 0) {
      this.printLine()
      this.printSlowTestOverview()
    }
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
  * Should return true if Ansi escapes should be used
  * @override
  * @returns {boolean} 
  */
  useAnsiEscapes() {
    return true
  }
}
