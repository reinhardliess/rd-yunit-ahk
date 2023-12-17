class TestOutput
{
  __New(instance) {
    this.listOutputInfo := []
  }
  
  __Delete() {
    global test_listOutputInfo
    test_listOutputInfo := this.listOutputInfo
  }
  
  ; category, testMethod, result, methodTime_ms
  Update(objOutputInfo) {
    switch {
      case Yunit.Util.GetType(outputInfo.result) = "Yunit.AssertionError":
    }
    this.listOutputInfo.push(objOutputInfo)
  }
}