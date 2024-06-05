class YunitStdOutMin extends YunitStdout
{
  __Delete() {
    this.printSlowTestOverview()
    if (this.summary.slowTests.count > 0) {
      this.printLine()
    }
    this.printErrorOverview()
    if (this.summary.failed.count > 0) {
      this.printLine()
    }
    this.printTestSummary()
  }
}