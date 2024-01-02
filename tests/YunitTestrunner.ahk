#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include ../Yunit.ahk
#Include ../Stdout.ahk
#Include ../StdoutMin.ahk
#Include ../ConsoleOutputBase.ahk
#Include ./Test_ConsoleOutput.ahk
#Include ./testclasses/ConsoleOutputTest.ahk
#Include ./testclasses/YunitHookTest.ahk

; Yunit.Use(YunitStdout).Test(YunitHookTest, ConsoleOutputTest)
Yunit.Use(YunitStdoutMin).Test(YunitHookTest, ConsoleOutputTest)
