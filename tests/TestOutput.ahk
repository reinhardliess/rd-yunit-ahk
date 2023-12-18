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
    this.listOutputInfo.push(objOutputInfo)
  }
}