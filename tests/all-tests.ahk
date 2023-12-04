SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%
#Include ../lib/unit-testing.ahk/export.ahk
#Include ../Yunit.ahk

global assert := new unittesting()

assert.group("Yunit.Util class")
test_Yunit_Util()

; wrap up
assert.writeResultsToFile()
; assert.fullReport()
assert.sendReportToDebugConsole()
Exit % assert.failTotal

Class TestClass {
  
}

test_Yunit_Util() {
  assert.label("should determine the correct type for numbers")
  assert.true(Yunit.Util.isInteger(5))
  assert.true(Yunit.Util.isNumber(5))
  assert.true(Yunit.Util.isFloat(5.0))
  assert.true(Yunit.Util.isNumber(5.0))
  
  assert.label("GetType should return the correct variable type")
  u := Yunit.Util
  assert.test(u.GetType(5), "integer")
  assert.test(u.GetType(5.0), "float")
  assert.test(u.GetType("green"), "string")
  assert.test(u.GetType({a:1}), "object")
  assert.test(u.GetType(new TestClass()), "TestClass")
  assert.test(u.GetType(TestClass), "class")

