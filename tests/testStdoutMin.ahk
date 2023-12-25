#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include ../Yunit.ahk
#Include ../StdoutMin.ahk

Yunit.Use(YunitStdoutMin).Test(StdoutMinTest)

class StdoutMinTest {
  /*
  - Only errors with colored output, following the design document
  - Format floating point numbers as `.17g`
  - [ToBe](#tobe): display object references as `[object]`
  */
  
  class toBe {
    
    addition_correct_result() {
      Yunit.expect(1 + 4).toBe(5)
    }

    addition_error() {
      Yunit.expect(1 + 4).toBe(6)
    }

  }
  
}