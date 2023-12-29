; cspell:ignore ansi

#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include ../Yunit.ahk
#Include ../StdoutMin.ahk
#Include ../ConsoleOutputBase.ahk
#Include ./TestStdout.ahk
#Include ./ConsoleOutputTest.ahk

Yunit.Use(YunitStdoutMin).Test(ConsoleOutputTest)
