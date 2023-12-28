; cspell:ignore ansi

#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include ../Yunit.ahk
#Include ../StdoutMin.ahk
#Include ../ConsoleOutputBase.ahk
#Include ./TestStdout.ahk

Yunit.Use(YunitStdoutMin).Test(YunitOutputTest)

;; YunitOutputTest
Class YunitOutputTest {
  
  ;; ConsoleOutput
  Class ConsoleOutput {

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
      this.module.printLine(0, "Test data")

      Yunit.expect(this.module.test_printOutput).toBe("Test data`n")
    }

    should_print_one_line_to_console_with_indentation_level1() {
      this.module.print(1, "Test data")

      Yunit.expect(this.module.test_printOutput).toBe("  Test data")
    }

    should_print_multiline_text_to_console_with_indentation_level1() {
      this.module.print(1, "Test data`nSecond line")

      Yunit.expect(this.module.test_printOutput)
            .toBe("  Test data`n  Second line")
    }
    
    should_remove_ansi_placeholders_from_formatString() {
      this.module.print(0, "{format.text}Test data{reset}")
      
      Yunit.expect(this.module.test_printOutput).toBe("Test data")
    }
  
    should_replace_ansi_placeholders_in_formatString() {
      this.module.useAnsiEscapes := true
      esc := chr(27)
      formattedString := esc "[0;37mTest data" esc "[0m"
      
      this.module.print(0, "{format.text}Test data{reset}")
      
      Yunit.expect(this.module.test_printOutput).toBe(formattedString)
    }
    
    should_perform_an_ansi_reset_before_printing_an_lf() {
      this.module.useAnsiEscapes := true
      esc := chr(27)
      formattedString := esc "[0;37mTest data" esc "[0m`n"
      
      this.module.printLine(0, "{format.text}Test data")
      
      Yunit.expect(this.module.test_printOutput).toBe(formattedString)
    }
    
  
  }

}
