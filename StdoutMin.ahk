class YunitStdOutMin
{
  reset := chr(27) "[0m"
  brightGreen := Chr(27) "[92m"
  brightRed := chr(27) "[91m"
  brightMagenta := chr(27) "[95m"
  white := chr(27) "[37m"
  brightBlack := Chr(27) "[90m"
  
  isFirstError := true
  indent := "  "
  
  tests := {}
  tests.pass := 0
  tests.passTime := 0
  tests.fail := 0
  tests.overall := 0
  
  __New(instance) {
  }
  
  __delete() {
    this.writeStatusReport()
  }
  
  Update(objOutputInfo) {
    category := objOutputInfo.category
      , testName := objOutputInfo.testMethod
      , result := objOutputInfo.result
      , methodTime_ms := objOutputInfo.methodTime_ms

      this.tests.overall++
      if (!this.isError(result)) {
        this.tests.pass++
        this.tests.passTime += methodTime_ms
        return
      }
      this.tests.fail++
      if (this.isFirstError) {
        this.isFirstError := false
      } else {
        this.writeLn()
      }
      ; * ShoppingCart > Subtotal > Items_CalculatePrice
      errorHeading := this.brightRed "* " StrReplace(category "." testName, "." , " > ") "`n"
      this.writeLn(errorHeading)
      
      switch {
        case Yunit.Util.GetType(result) = "Yunit.AssertionError":
          this.writeExpectErrorBlock(result)
        default:
          this.writeLn(this.indent this.white result.message)
      }
      ; write file:line
      this.writeFilepath(result)
  }

  isError(var) {
    if (IsObject(var) 
      && var.hasKey("message")
      && var.hasKey("what")
      && var.hasKey("file")
      && var.hasKey("line")) {
      return true
    }
    return false
  }
  
  write(line) {
    lineToPrint := line this.reset 
    FileAppend, %lineToPrint%, *, UTF-8
  }

  writeLn(line := "") {
    this.write(line "`n")
  }
  
  writeExpectErrorBlock(errorObj) {
    actual := errorObj.matcherInfo.actual
    expected := errorObj.matcherInfo.expected
    matcher := errorObj.matcherInfo.matcherType
    
    switch {
      case isObject(actual):
        actual := "[object]"
      case matcher != "toBeCloseTo" && Yunit.Util.IsFloat(actual):
        actual := Format("{1:.17g}", actual)
      case Yunit.Util.GetType(actual) = "String":
        actual := """" actual """"
    }
    
    switch {
      case isObject(expected):
        expected := "[object]"
      case matcher != "toBeCloseTo" && Yunit.Util.IsFloat(expected):
        expected := Format("{1:.17g}", expected)
      case Yunit.Util.GetType(expected) = "String":
        expected := """" expected """"
    }
    
    this.writeLn(this.indent this.white "Matcher: " errorObj.matcherInfo.matcherType "`n")
    this.writeLn(this.indent this.white "Actual:   " this.brightRed actual)
    this.writeLn(this.indent this.white "Expected: " this.brightGreen expected)
  }
  
  writeFilepath(result) {
    this.writeLn()
    output := format("{1}{2}({3}:{4})", this.indent, this.brightBlack, result.file, result.line)
    this.writeLn(output)
  }
  
  writeStatusReport() {
    if (this.tests.fail > 0) {
      this.writeLn()
    }
    
    if (this.tests.pass > 0) {
      statusPassed := format("{1}{:3d} passing ({:d} ms)", this.brightGreen, this.tests.pass, this.tests.passTime)
      this.writeLn(statusPassed)
    }
    if (this.tests.fail > 0) {
      statusFailed := format("{1}{2:3d} failing", this.brightRed, this.tests.fail)
      this.writeLn(statusFailed)
    }
    
  }
}