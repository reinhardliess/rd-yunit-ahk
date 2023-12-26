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
  ; printCategories, identifyCategories (get)
  ; create toMatch

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
  
  should_print_text_to_console_with_lf() {
    this.module.printLn("Test data")

    Yunit.expect(this.module.test_printOutput).toBe("Test data`n")
  }
  
  should_print_one_line_to_console_with_indentation_level1() {
    this.module.print("Test data", 1)
    
    Yunit.expect(this.module.test_printOutput).toBe("  Test data")
  }
  
  should_print_multiline_text_to_console_with_indentation_level1() {
    this.module.print("Test data`nSecond line", 1)
    
    Yunit.expect(this.module.test_printOutput).toBe("  Test data`n  Second line")
  }
  
  
}
