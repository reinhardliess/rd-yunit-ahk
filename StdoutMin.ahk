class YunitStdOutMin extends YunitStdout
{
  __Delete() {
    this.printErrorOverview()
    if (this.summary.failed.count > 0) {
      this.printLine()
    }
    this.printTestSummary()
  }
}