SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%
#Include ../lib/unit-testing.ahk/export-v1.ahk
#Include ../Yunit.ahk
#Include, ./testclasses/TestClasses.ahk
#Include, ./testclasses/TestOutput.ahk

global assert := new unittesting()

OnError("ShowError")

assert.group("Yunit.TestClass")
test_Yunit_TestClass()

; wrap up
assert.writeResultsToFile()
; assert.fullReport()
assert.sendReportToDebugConsole()
Exit % assert.failTotal

filterOutputInfo(listInfo) {
  newList := []
  for _, value in listInfo {
    newList.push({category: (value.category), testMethod: (value.testMethod)})
  }
  return newList
}

test_Yunit_TestClass() {
  global test_listOutputInfo
  
  Yunit.Use(TestOutput).Test(TestClass2)
  
  assert.label("should throw the correct error type when using expect()")
  errType := Yunit.Util.GetType(test_listOutputInfo[1].result)
  assert.test(errType, "Yunit.AssertionError")
  
  assert.label("should retrieve timing information for tests")
  timeType := Yunit.Util.GetType(test_listOutputInfo[1].methodTime_ms)
  assert.test(timeType, "Integer")
  
  assert.label("should execute all test methods")
  actual := filterOutputInfo(test_listOutputInfo)
  expected := [{category: "TestClass2", testMethod: "Test_Fails"}
    , {category: "TestClass2", testMethod: "Test_Passes"}
    , {category: "TestClass2.CategoryOne", testMethod: "Test1"}]
  assert.test(actual, expected)
}

ShowError(exception) {
  OutputDebug % ("Error in " exception.file ":" exception.Line "`n" exception.Message " (" A_LastError ")" exception.extra  "`n")
  return true
}
