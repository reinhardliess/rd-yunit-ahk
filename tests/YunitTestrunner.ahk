#Warn All, OutputDebug
SetWorkingDir(A_ScriptDir)

#Include ../Yunit.ahk
#Include ../StdoutMin.ahk
; #Include ../Window.ahk
#Include ./Test_ConsoleOutput.ahk
#Include ./testclasses/ConsoleOutputTest.ahk
#Include ./testclasses/YunitHookTest.ahk
#Include ./testclasses/YunitTest.ahk

Yunit.SetOptions({ outputRenderWhiteSpace: true })
Yunit.Use(YunitStdoutMin).Test(YunitTest, YunitHookTest, ConsoleOutputTest)
