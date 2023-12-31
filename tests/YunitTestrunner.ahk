#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include ../Yunit.ahk
#Include ../StdoutMin.ahk
#Include ../ConsoleOutputBase.ahk
#Include ./Test_ConsoleOutput.ahk
#Include ./testclasses/ConsoleOutputTest.ahk

Yunit.Use(YunitStdoutMin).Test(ConsoleOutputTest)
