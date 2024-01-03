SetWorkingDir(A_ScriptDir)

#Include ../Yunit.ahk
#Include ../Stdout.ahk
#Include ../StdoutMin.ahk
#Include ../ConsoleOutputBase.ahk
#Include ./testclasses/ConsoleOutputTest.ahk
#Include ./testclasses/YunitHookTest.ahk

Yunit.SetOptions({ outputRenderWhiteSpace: true })
; Yunit.Use(YunitStdout).Test(YunitHookTest, ConsoleOutputTest)
Yunit.Use(YunitStdoutMin).Test(YunitHookTest, ConsoleOutputTest)
