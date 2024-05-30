#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%
#Include ../Yunit.ahk
#Include ../ConsoleOutputBase.ahk
#Include ../Stdout.ahk
#Include ../StdoutMin.ahk
#Include ./OutputModuleTest.ahk

Yunit.SetOptions({OutputRenderWhiteSpace: true})
Yunit.Use(YunitStdoutMin).Test(OutputModuleTest)
