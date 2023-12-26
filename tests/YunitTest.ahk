#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include ../Yunit.ahk
#Include ../StdoutMin.ahk

Yunit.Use(YunitStdoutMin).Test(YunitTest)

Class YunitTest {
  
  ; helper methods
  ; method to test expect() returning error object
  
  ; tests:
  ; indentation (get)
  ; printCategories, identifyCategories (get)
}
