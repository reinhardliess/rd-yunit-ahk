#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include ../Yunit.ahk
#Include ../StdoutMin.ahk
#Include ../ConsoleOutputBase.ahk
#Include ./TestStdout.ahk

Yunit.Use(YunitStdoutMin).Test(YunitTest)

Class YunitTest {

  ; helper methods
  ; method to test expect() returning error object

  ; tests:
  ; indentation (get)
  ; printCategories, identifyCategories (get)

  beforeEach() {
    this.module := new TestStdout("")
  }

  should_convert_indentation_level_to_number_of_spaces() {
    noSpaces   := this.module.indentationToSpaces(0)
    twoSpaces  := this.module.indentationToSpaces(1)
    fourSpaces := this.module.indentationToSpaces(2)

    Yunit.expect(noSpaces).toBe("")
    Yunit.expect(twoSpaces).toBe("  ")
    Yunit.expect(fourSpaces).toBe("    ")
  }
}
