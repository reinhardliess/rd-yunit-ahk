SetWorkingDir(A_ScriptDir)

#Include ../Yunit.ahk
#Include ../Stdout.ahk
#Include ../StdoutMin.ahk
#Include ../ConsoleOutputBase.ahk
#Include ./testclasses/ConsoleOutputTest.ahk
#Include ./testclasses/YunitHookTest.ahk
#Include ./testclasses/YunitTest.ahk

Yunit.SetOptions({ outputRenderWhiteSpace: true })
Yunit.Use(YunitStdoutMin).Test(YunitTest, YunitHookTest, ConsoleOutputTest)
; Yunit.Use(YunitStdout).Test(YunitTest, YunitHookTest, ConsoleOutputTest)
