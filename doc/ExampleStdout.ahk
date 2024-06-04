#Requires AutoHotkey 2.0

SetWorkingDir(A_ScriptDir)

#Include ../Yunit.ahk
#Include ../ConsoleOutputBase.ahk
#Include ../Stdout.ahk
#Include ./OutputModuleTest.ahk

Yunit.SetOptions({TimingWarningThreshold: 20})
Yunit.Use(YunitStdout).Test(OutputModuleTest)
