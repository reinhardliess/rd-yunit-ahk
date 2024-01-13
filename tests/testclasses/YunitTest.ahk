Class YunitTest {
  ;; Class Matchers
  Class Matchers {

    ;; TODO: use SetOptions/RestoreOptions when available
    ; beforeEach() {
    ;   this.oldRenderWhiteSpace := Yunit.options.outputRenderWhitespace 
    ;   Yunit.options.outputRenderWhitespace := true
    ; }
    
    ; afterEach() {
    ;   Yunit.options.outputRenderWhitespace := this.oldRenderWhiteSpace 
    ; }
    
    matcher_options_should_be_set_by_constructor() {
      matcher := new Yunit.Matchers.ToBe({message: "error"})
      
      Yunit.expect(matcher.message).toBe("error")
    }

    getMatcherType_should_return_matcher_display_name() {
      matcher := new Yunit.Matchers.ToBe()
      matcherName := matcher.getMatcherType()
      
      Yunit.expect(matcherName).toBe("ToBe")
    }
    
    render_linefeeds_in_strings_if_option_set() {
      matcher := new Yunit.Matchers.ToBe()
      lineLf := matcher.formatActualTestValue("Hello World!`nHow are you?")
      lineCrlf := matcher.formatActualTestValue("Hello World!`r`nHow are you?")
      
      Yunit.expect(lineLf).toBe("""Hello World!{format.textDimmed}``n{format.error}How are you?""")
      Yunit.expect(lineCrlf).toBe("""Hello World!{format.textDimmed}``r``n{format.error}How are you?""")
    }
    
    render_esc_in_strings_if_option_set() {
      matcher := new Yunit.Matchers.ToBe()
      lineWithEsc := matcher.formatActualTestValue(chr(27) "[95m" "Hello World!")
      
      expected := format("{1}{format.textDimmed}``e{format.error}[95mHello World!{1}", chr(34), chr(27))
      Yunit.expect(lineWithEsc).toBe(expected)
    }
    
    Class ToBe {

      beforeEach() {
        this.m := new Yunit.Matchers.ToBe()
      }

      integer_comparison_true() {
        ret := this.m.Assert(5, 5)

        Yunit.expect(ret).toBe(true)
        Yunit.expect(this.m).toEql({actual: 5, expected: 5, hasPassedTest: 1})
      }

      integer_comparison_false() {
        expected := "
        (LTrim
        Actual:   5
        Expected: 6
        )"

        ret := this.m.Assert(5, 6)
        output := this.m.GetErrorOutput()

        Yunit.expect(ret).toBe(false)
        Yunit.expect(this.m).toEql({actual: 5, expected: 6, hasPassedTest: 0})
        Yunit.expect(output).toEql(expected)
      }

      string_comparison_true() {
        ret := this.m.Assert("Zoe", "Zoe")

        Yunit.expect(ret).toBe(true)
        Yunit.expect(this.m).toEql({actual: "Zoe", expected: "Zoe", hasPassedTest: 1})
      }

      string_comparison_false() {
        expectedOutput =
        (LTrim
        Actual:   "Zoi"
        Expected: "Zoe"
        )

        ret := this.m.Assert("Zoi", "Zoe")
        output := this.m.GetErrorOutput()

        Yunit.expect(ret).toBe(false)
        Yunit.expect(this.m).toEql({actual: "Zoi", expected: "Zoe", hasPassedTest: 0})
        Yunit.expect(output).toEql(expectedOutput)
      }

      object_comparison_true() {
        obj1 := {a: 1}, obj1ref := obj1

        ret := this.m.Assert(obj1, obj1ref)

        Yunit.expect(ret).toBe(true)
        Yunit.expect(m.actual).toBe(m.expected)
      }

      object_comparison_false() {
        obj1 := {a: 1}, obj2 := {a: 1}
        expectedOutput =
        (LTrim
        Actual:   "a":1
        Expected: "a":1
        )

        ret := this.m.Assert(obj1, obj2)
        output := this.m.GetErrorOutput()

        Yunit.expect(ret).toBe(false)
        ; TODO: Yunit.expect(m.actual).not.toBe(m.expected)
        Yunit.expect(output).toEql(expectedOutput)
      }
    }

    Class toEql {
      beforeEach() {
        this.m := new Yunit.Matchers.toEql()
      }

      object_comparison_true() {
        actual   := {a: 1}
        expected := {a: 1}

        ret := this.m.Assert(actual, expected)

        Yunit.expect(ret).toBe(true)
        Yunit.expect(this.m.actual).toBe(actual)
        Yunit.expect(this.m.expected).toBe(expected)
      }

      object_comparison_false() {
        actual   := {a: 1}
        expected := {a: 2}
        expectedOutput =
        (LTrim
        Actual:   "a":1
        Expected: "a":2
        )

        ret := this.m.Assert(actual, expected)
        output := this.m.GetErrorOutput()

        Yunit.expect(ret).toBe(false)
        Yunit.expect(this.m.actual).toBe(actual)
        Yunit.expect(this.m.expected).toBe(expected)
        Yunit.expect(output).toEql(expectedOutput)
      }
    }

    Class ToBeCloseTo {
      beforeEach() {
        this.m := new Yunit.Matchers.ToBeCloseTo()
      }

      proximate_equality_true() {
        actual   := 0.1 + 0.2
        expected := 0.3

        ret := this.m.Assert(actual, expected)

        Yunit.expect(ret).toBe(true)
        ;; TODO: replace with ToContain matcher -> object
        Yunit.expect(this.m.actual.value).toBe(actual)
        Yunit.expect(this.m.expected.value).toBe(expected)
        Yunit.expect(this.m.expected.digits).toBe(2)
        Yunit.expect(this.m.expected.difference).toBe(0.005)
      }

      ; proximate_equality_false() {
      ;   actual   := 0.1 + 0.2
      ;   expected := 0.29
      ;   expectedOutput := "
      ;   (Ltrim
      ;   Actual:   0.30000000000000004
      ;   Expected: 0.28999999999999998

      ;   Actual difference:     0.010000000000000064
      ;   Expected difference: < 0.005
      ;   Expected precision:    2
      ;   )"

      ;   ret := this.m.Assert(actual, expected)
      ;   output := this.m.GetErrorOutput()

      ;   Yunit.expect(ret).toBe(false)
      ;   ;; TODO: replace with ToContain matcher -> object
      ;   Yunit.expect(this.m.actual.value).toBe(actual)
      ;   Yunit.expect(this.m.expected.value).toBe(expected)
      ;   Yunit.expect(this.m.expected.digits).toBe(2)
      ;   Yunit.expect(this.m.expected.difference).toBe(0.005)
      ;   Yunit.expect(output).toBe(expectedOutput)
      ; }
      
      proximate_equality_false() {
        actual   := 0.1 + 0.2
        expected := 0.29
        
        errorBlock := "
        (Ltrim
        Actual:   0.30000000000000004
        Expected: 0.28999999999999998
        )"
        errorDetails := "
        (Ltrim
        Actual difference:     0.010000000000000064
        Expected difference: < 0.005
        Expected precision:    2
        )"

        ret := this.m.Assert(actual, expected)
        output := this.m.GetErrorOutput()

        Yunit.expect(ret).toBe(false)
        ;; TODO: replace with ToContain matcher -> object
        Yunit.expect(this.m.actual.value).toBe(actual)
        Yunit.expect(this.m.expected.value).toBe(expected)
        Yunit.expect(this.m.expected.digits).toBe(2)
        Yunit.expect(this.m.expected.difference).toBe(0.005)
        Yunit.expect(output[1]).toBe(errorBlock)
        Yunit.expect(output[2]).toBe(errorDetails)
      }
    }
  }
  
  ;; Class Util
  Class Util {
    ;; Class Types
    Class Types {
      ;; Class Numbers
      Class Numbers {
        isInteger_should_check_if_var_converts_to_integer() {
          Yunit.expect(Yunit.Util.isInteger(5)).toBe(true)
          Yunit.expect(Yunit.Util.isInteger("5")).toBe(true)
        }
        
        isInteger_should_check_if_var_does_not_convert_to_integer() {
          Yunit.expect(Yunit.Util.isInteger(5.0)).toBe(false)
          Yunit.expect(Yunit.Util.isInteger("5.0")).toBe(false)
        }
        
        isPureInteger_should_check_if_var_is_integer() {
          Yunit.expect(Yunit.Util.isPureInteger(5)).toBe(true)
        }
        
        isPureInteger_should_check_if_var_is_not_integer() {
          Yunit.expect(Yunit.Util.isPureInteger("5")).toBe(false)
          Yunit.expect(Yunit.Util.isPureInteger(5.0)).toBe(false)
          Yunit.expect(Yunit.Util.isPureInteger("5.0")).toBe(false)
        }
      
        should_determine_the_correct_type_for_numbers() {
          Yunit.expect(Yunit.Util.isNumber(5)).toBe(true)
          Yunit.expect(Yunit.Util.isNumber(5.0)).toBe(true)
          Yunit.expect(Yunit.Util.isFloat(5.0)).toBe(true)
        }
      }  
          
      isArray_should_check_if_var_is_an_array() {
        Yunit.expect(Yunit.Util.IsArray(["a", "b"])).toBe(true)
      }
      
      isArray_should_check_if_var_is_not_an_array() {
        Yunit.expect(Yunit.Util.IsArray([])).toBe(false)
        Yunit.expect(Yunit.Util.IsArray(5)).toBe(false)
        Yunit.expect(Yunit.Util.IsArray({a: 1})).toBe(false)
        Yunit.expect(Yunit.Util.IsArray({1a: 1})).toBe(false)
        Yunit.expect(Yunit.Util.IsArray({1: 1, a: 2})).toBe(false)
      }
      getType_should_return_the_correct_variable_type() {
        Yunit.expect(Yunit.Util.GetType(5)).toBe("Integer")
        Yunit.expect(Yunit.Util.GetType(5.0)).toBe("Float")
        Yunit.expect(Yunit.Util.GetType("green")).toBe("String")
        Yunit.expect(Yunit.Util.GetType({a: 1})).toBe("Object")
        Yunit.expect(Yunit.Util.GetType(new Yunit.Util)).toBe("Yunit.Util")
        Yunit.expect(Yunit.Util.GetType(Yunit.Util)).toBe("Class")
      }
    
      isFunction_should_determine_whether_an_object_is_callable() {
        Yunit.expect(Yunit.Util.IsFunction(Func("Substr"))).toBe(true)
        Yunit.expect(Yunit.Util.IsFunction(Func("Substr").bind())).toBe(true)
        Yunit.expect(Yunit.Util.IsFunction("Substr")).toBe(false)
      }
    }
    
    ;; Class Print
    Class Print {
      print_a_primitive_type() {
        Yunit.expect(Yunit.Util.Print(33)).toBe(33)
        Yunit.expect(Yunit.Util.Print("33")).toBe("33")
      }
      
      print_an_array() {
        Yunit.expect(Yunit.Util.Print([1, 2, 3])).toEql("1:1, 2:2, 3:3")
        Yunit.expect(Yunit.Util.Print(["April", "Zoe", "Saga"])).toEql("1:""April"", 2:""Zoe"", 3:""Saga""")
      }
      
      print_an_object() {
        actualValue := { name: "Zoe", age: 20, address: { street: "Jardin des Roses"} }
        expected =  
        ( ltrim
          "address":["street":"Jardin des Roses"], "age":20, "name":"Zoe"
        )
        Yunit.expect(Yunit.Util.Print(actualValue)).toEql(expected)
      }
      
      print_an_array_of_objects() {
        actualValue := [{type: 1, value: "abc"}, {type: 2, value: "def"}]
        expected = 
        ( ltrim
        1:["type":1, "value":"abc"], 2:["type":2, "value":"def"]
        )
        Yunit.expect(Yunit.Util.Print(actualValue)).toEql(expected)
      }
      
      print_an_object_but_ignore_function_objects_as_props() {
        obj := { a: 1, fn: Func("Instr")}
        Yunit.expect(Yunit.Util.Print(obj)).toEql("""a"":1")  
      }
      
      print_an_object_with_integer_value_usePureNumbers_true() {
        obj1 := {a: 1}
        
        printedObj1 := Yunit.Util.Print(obj1, true) 
        
        Yunit.expect(printedObj1).toEql("""a"":1")  
      }

      print_an_object_with_integer_value_usePureNumbers_false() {
        obj1 := {a: 1}
        
        printedObj1 := Yunit.Util.Print(obj1, false) 
        
        Yunit.expect(printedObj1).toEql("""a"":1")  
      }

      print_an_object_with_a_string_integer_value_usePureNumbers_true() {
        obj1 := {a: "1"}
        
        printedObj1 := Yunit.Util.Print(obj1, true) 
        
        Yunit.expect(printedObj1).toEql("""a"":""1""")  
      }

      print_an_object_with_a_string_integer_value_usePureNumbers_false() {
        obj1 := {a: "1"}
        
        printedObj1 := Yunit.Util.Print(obj1, false) 
        
        Yunit.expect(printedObj1).toEql("""a"":1")  
      }
      
      print_an_object_with_a_float_value_usePureNumbers_true() {
        obj1 := {a: 5.0}
        
        printedObj1 := Yunit.Util.Print(obj1, true) 
        
        Yunit.expect(printedObj1).toEql("""a"":5.0")  
      }

      print_an_object_with_a_float_value_usePureNumbers_false() {
        obj1 := {a: 5.0}
        
        printedObj1 := Yunit.Util.Print(obj1, false) 
        
        Yunit.expect(printedObj1).toEql("""a"":5.0")  
      }

      print_an_object_with_a_string_float_value_usePureNumbers_true() {
        obj1 := {a: "5.0"}
        
        printedObj1 := Yunit.Util.Print(obj1, true) 
        
        Yunit.expect(printedObj1).toEql("""a"":5.0")  
      }

      print_an_object_with_a_string_float_value_usePureNumbers_false() {
        obj1 := {a: "5.0"}
        
        printedObj1 := Yunit.Util.Print(obj1, false) 
        
        Yunit.expect(printedObj1).toEql("""a"":5.0")  
      }
    }
    
    should_test_if_QueryPerformanceCounter_is_working() {
      timeCode := Yunit.Util.QPCInterVal()
      Yunit.expect(Yunit.Util.GetType(timeCode)).toBe("Float")
    }
    
    join_should_join_array_elements_with_delimiter() {
      Yunit.expect(Yunit.Util.Join([])).toEql("")
      Yunit.expect(Yunit.Util.Join([1])).toEql("1")
      Yunit.expect(Yunit.Util.Join([1,2])).toEql("1,2")
      Yunit.expect(Yunit.Util.Join(["a","b"])).toEql("a,b")
      Yunit.expect(Yunit.Util.Join([1,2], ";")).toEql("1;2")
    }
  }
}