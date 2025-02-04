;############################
; description: Generate output for Yunit-Framework (https://github.com/Uberi/Yunit) using OutputDebug
;
; author: hoppfrosch
; date: 20170427
;############################
class YunitOutputDebug{
  __new(instance) {
    this.tests := {}
    this.tests.pass := 0
    this.tests.fail := 0
    this.tests.overall := 0
    this.prefix := "[YUnit] "
    OutputDebug % this.prefix "*** START OF UNITTEST *************************************************************************************" 
    Return this
  }

  __Delete() { 
    status := "PASS"
    if (this.tests.fail > 0) {
      Status := "FAIL"
    }
    OutputDebug % this.prefix "***** " status ": Overall UnitTestSuite (Tests performed: " this.tests.overall " (failed: " this.tests.fail " - passed: " this.tests.pass "))" 
  }

  Update(objOutputInfo)	{
    ; category, testMethod, result, methodTime_ms
    this.tests.overall := this.tests.overall + 1
    if IsObject(objOutputInfo.Result) {
      this.tests.fail := this.tests.fail + 1
      Details := "at line " objOutputInfo.Result.Line " (" objOutputInfo.Result.Message ") - (" objOutputInfo.result.file ")"
      Status := "FAIL"
    } else {
      this.tests.pass := this.tests.pass + 1
      Details := ""
      Status := "PASS"
    }
    cnt := format("{:3}", this.tests.overall) 
    msg := "(" cnt ") " status ": " objOutputInfo.Category "." objOutputInfo.testMethod " " details
    OutputDebug % this.prefix msg
  }
}
