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

    convert_indentation_level_to_spaces() {
      noSpaces   := this.module.indentationToSpaces(0)
      twoSpaces  := this.module.indentationToSpaces(1)
      fourSpaces := this.module.indentationToSpaces(2)

      Yunit.expect(noSpaces).toBe("")
      Yunit.expect(twoSpaces).toBe("  ")
      Yunit.expect(fourSpaces).toBe("    ")
    }
    
    print_text_with_lf() {
      this.module.printLine(0, "Test data")

      Yunit.expect(this.module.test_printOutput).toBe("Test data`n")
    }

    print_one_line_with_indentation_level1() {
      this.module.print(1, "Test data")

      Yunit.expect(this.module.test_printOutput).toBe("  Test data")
    }

    print_multiline_text_with_indentation_level1() {
      this.module.print(1, "Test data`nSecond line")

      Yunit.expect(this.module.test_printOutput)
            .toBe("  Test data`n  Second line")
    }
    
    remove_ansi_placeholders_from_formatString() {
      this.module.print(0, "{format.text}Test data{reset}")
      
      Yunit.expect(this.module.test_printOutput).toBe("Test data")
    }
  
    replace_ansi_placeholders_in_formatString() {
      this.module.useAnsiEscapes := true
      esc := chr(27)
      formattedString := esc "[0;37mTest data" esc "[0m"
      
      this.module.print(0, "{format.text}Test data{reset}")
      
      Yunit.expect(this.module.test_printOutput).toEqual(formattedString)
    }
    
    perform_an_ansi_reset_before_printing_an_lf() {
      this.module.useAnsiEscapes := true
      esc := chr(27)
      formattedString := esc "[0;37mTest data" esc "[0m`n"
      
      this.module.printLine(0, "{format.text}Test data")
      
      Yunit.expect(this.module.test_printOutput).toEqual(formattedString)
    }
    
    print_categories_if_no_categories_printed() {
      expected := "Category1`n  sub1`n"
      
      this.module.printNewCategories("Category1.sub1")
      
      Yunit.expect(this.module.test_printOutput).toEqual(expected)
    }
    
    not_print_categories_if_already_printed() {
      m := this.module
      
      m.printNewCategories("Category1.sub1")
      m.printNewCategories("Category1.sub1")
      
      Yunit.expect(m.test_printOutput).toEqual("Category1`n  sub1`n")
    }
  
    print_new_categories_if_other_categories_already_printed() {
      m := this.module
      expected := "Category1`n  sub1`nCategory2`n  sub2`n"
      
      m.printNewCategories("Category1.sub1")
      m.printNewCategories("Category2.sub2")
      
      Yunit.expect(m.test_printOutput).toEqual(expected)
    }
  }

}
