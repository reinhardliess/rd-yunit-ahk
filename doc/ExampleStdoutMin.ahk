#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include ../Yunit.ahk
#Include ../StdoutMin.ahk
#Include ./OutputModuleTest.ahk

Yunit.Use(YunitStdoutMin).Test(OutputModuleTest)
