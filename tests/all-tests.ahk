
#Include %A_ScriptDir%
#Include "../lib/unit-testing.ahk/export.ahk"

global assert := unittesting()

; wrap up
assert.writeResultsToFile()
; assert.fullReport()
assert.sendReportToDebugConsole()
Exit(assert.failTotal)
