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

test_Yunit_Util() {
  assert.label("should check for numbers correctly")
  assert.true(Yunit.Util.isInteger(5))
  assert.true(Yunit.Util.isNumber(5))
  assert.true(Yunit.Util.isFloat(5.0))
  assert.true(Yunit.Util.isNumber(5.0))
  
  ; assert.test("hello", "hello")

}

