Class YunitTest {
  
  ;; TODO: integrate when stubs are available ↓
  
  /*  
  filterOutputInfo(listInfo) {
    newList := []
    for _, value in listInfo {
      newList.push({category: (value.category), testMethod: (value.testMethod)})
    }
    return newList
  }

  test_Yunit_TestClass() {
    global test_listOutputInfo
    
    Yunit.Use(TestOutput).Test(TestClass2)
    
    assert.label("should throw the correct error type when using expect()")
    errType := Yunit.Util.GetType(test_listOutputInfo[1].result)
    assert.test(errType, "Yunit.AssertionError")
    
    assert.label("should retrieve timing information for tests")
    timeType := Yunit.Util.GetType(test_listOutputInfo[1].methodTime_ms)
    assert.test(timeType, "Integer")
    
    assert.label("should execute all test methods")
    actual := filterOutputInfo(test_listOutputInfo)
    expected := [{category: "TestClass2", testMethod: "Test_Fails"}
      , {category: "TestClass2", testMethod: "Test_Passes"}
      , {category: "TestClass2.CategoryOne", testMethod: "Test1"}]
    assert.test(actual, expected)
  }
  */
    
  ;; Class YunitMain
  Class YunitMain {
    
    set_and_restore_options() {
      oldOptions := Yunit.options.Clone()
      Yunit.SetOptions({TimingWarningThreshold: 0})
      Yunit.RestoreOptions()
      Yunit.expect(oldOptions).toEql(Yunit.Options)
    }
    
    _fn_set_invalid_option() {
      Yunit.SetOptions({invalid: true})
    }
    
    throw_error_if_option_does_not_exist() {
      boundFunc := ObjBindMethod(this, "_fn_set_invalid_option")
      Yunit.expect(boundFunc).toThrow()
    }
    
    should_convert_non_object_to_error_object_for_output() {
      errString := "An error"
      err := Yunit.processErrorForOutput(errString)
      
      Yunit.expect(Yunit.Util.IsError(err)).toBe(true)
      Yunit.expect(err.message).toEql(errString)
    }
    
    should_convert_non_error_object_to_error_object_for_output() {
      obj := {errorNo: 5}
      err := Yunit.processErrorForOutput(obj)
      
      Yunit.expect(Yunit.Util.IsError(err)).toBe(true)
      Yunit.expect(err.message).toBe("A non-standard error occurred.")
    }
    
    should_check_whether_a_method_name_is_that_of_a_test_method() {
      Yunit.expect(Yunit._isTestMethod("Begin")).toBe(false)
      Yunit.expect(Yunit._isTestMethod("BeforeEach")).toBe(false)
      Yunit.expect(Yunit._isTestMethod("AfterEachAll")).toBe(false)
      Yunit.expect(Yunit._isTestMethod("_helperMethod")).toBe(false)
      Yunit.expect(Yunit._isTestMethod("Test_Division")).toBe(true)
    
      Yunit.SetOptions({EnablePrivateProps: false})
      Yunit.expect(Yunit._isTestMethod("_Test_Addition")).toBe(true)
      Yunit.RestoreOptions()
    }
  
    should_check_whether_a_class_name_belongs_to_a_test_category() {
      Yunit.expect(Yunit._isTestCategory("MyClass._PrivateClass")).toBe(false)
      Yunit.expect(Yunit._isTestCategory("Multiplication")).toBe(true)
      
      Yunit.SetOptions({EnablePrivateProps: false})
      Yunit.expect(Yunit._isTestCategory("MyClass._Multiplication")).toBe(true)
      Yunit.RestoreOptions()
    }
  }
  
  Class Expect {
    
    should_create_an_assertion_error_with_all_necessary_properties() {
      err := new Yunit.AssertionError("message", "what", "extra", {hasPassedTest: false})
      
      Yunit.expect(err.message).toBe("message")
      Yunit.expect(err.what).toBe("what")
      Yunit.expect(err.extra).toBe("extra")
      Yunit.expect(err.matcher).toEql({hasPassedTest: false})
    }
    
    _expect_assertion_error() {
      Yunit.expect(5, "message").toBe(6)
    }
    
    _expect_wrong_matcher() {
      Yunit.expect(0).toBeZero()
    }
    
    if_the_expectation_fails_throw_an_assertion_error() {
      boundFunc := ObjBindMethod(this, "_expect_assertion_error")
      err := Yunit.expect(boundFunc).toThrow(Yunit.AssertionError)
      
      err.matcher.matcherType := err.matcher.GetMatcherType()
      Yunit.expect(err.matcher, "The error object should contain the correct matcher object")
        .toEql({actual: 5, expected: 6, hasPassedTest: 0, matcherType: "ToBe", message: "message"})
    }
    
    if_a_matcher_is_used_that_does_not_exist_throw_an_error() {
      boundFunc := ObjBindMethod(this, "_expect_wrong_matcher")
      Yunit.expect(boundFunc).toThrow()
    }
    
  }
  
  ;; Class Matchers
  Class Matchers {

    matcher_options_should_be_set_by_constructor() {
      matcher := new Yunit.Matchers.ToBe({message: "error"})

      Yunit.expect(matcher.message).toBe("error")
    }

    getMatcherType_should_return_matcher_display_name() {
      matcher := new Yunit.Matchers.ToBe()
      matcherName := matcher.getMatcherType()

      Yunit.expect(matcherName).toBe("ToBe")
    }
    
    ;; Class RenderWhiteSpace
    Class RenderWhiteSpace {
      
      __New() {
        Yunit.SetOptions({outputRenderWhitespace: true})
      }

      __Delete() {
        Yunit.RestoreOptions()
      }
      
      render_linefeeds_in_strings_if_option_set() {
        matcher := new Yunit.Matchers.ToBe()
        lineLf := matcher.formatActualTestValue("Hello World!`nHow are you?")
        lineCrlf := matcher.formatActualTestValue("Hello World!`r`nHow are you?")
  
        Yunit.expect(lineLf).toBe("""Hello World!{format.textDimmed}``n{format.error}How are you?""")
        Yunit.expect(lineCrlf).toBe("""Hello World!{format.textDimmed}``r{format.error}{format.textDimmed}``n{format.error}How are you?""")
      }
  
      render_linefeed_in_an_object_string_property_if_option_set() {
        matcher := new Yunit.Matchers.ToBe()
        lineLf := matcher.formatActualTestValue({a: "line1`nline2"})
        expected := """a"":""line1{format.textDimmed}``n{format.error}line2"""
        Yunit.expect(lineLf).toBe(expected)
      }
      
      render_esc_in_strings_if_option_set() {
        matcher := new Yunit.Matchers.ToBe()
        lineWithEsc := matcher.formatActualTestValue(chr(27) "[95m" "Hello World!")
  
        expected := format("{1}{format.textDimmed}``e{format.error}[95mHello World!{1}", chr(34), chr(27))
        Yunit.expect(lineWithEsc).toBe(expected)
      }
  
      render_tab_in_strings_if_option_set() {
        matcher := new Yunit.Matchers.ToBe()
        lineWithTab := matcher.formatActualTestValue("Hello`tWorld!")
  
        expected := format("{1}Hello{format.textDimmed}``t{format.error}World!{1}", chr(34))
        Yunit.expect(lineWithTab).toBe(expected)
      }
    
    }
    
    ;; Class ToBe
    Class ToBe {

      beforeEach() {
        this.m := new Yunit.Matchers.ToBe()
      }

      integer_comparison_true() {
        ret := this.m.Assert(5, 5)

        Yunit.expect(ret).toEql(true)
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

        Yunit.expect(ret).toEql(false)
        Yunit.expect(this.m).toEql({actual: 5, expected: 6, hasPassedTest: 0})
        Yunit.expect(output).toEql(expected)
      }

      string_comparison_true() {
        ret := this.m.Assert("Zoe", "Zoe")

        Yunit.expect(ret).toEql(true)
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

        Yunit.expect(ret).toEql(false)
        Yunit.expect(this.m).toEql({actual: "Zoi", expected: "Zoe", hasPassedTest: 0})
        Yunit.expect(output).toEql(expectedOutput)
      }

      object_comparison_true() {
        obj1 := {a: 1}, obj1ref := obj1

        ret := this.m.Assert(obj1, obj1ref)

        Yunit.expect(ret).toEql(true)
        Yunit.expect(this.m.hasPassedTest).toEql(true)
        Yunit.expect(m.actual = m.expected).toEql(true)
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

        Yunit.expect(ret).toEql(false)
        Yunit.expect(this.m.hasPassedTest).toEql(false)
        Yunit.expect(output).toEql(expectedOutput)
      }
    }

    ;; Class toEql
    Class toEql {
      beforeEach() {
        this.m := new Yunit.Matchers.toEql()
      }
      
      ; TODO: replace toEql -> toEqual/toStrictlyEqual when available
      object_comparison_true() {
        actual   := {a: 1}
        expected := {a: 1}

        ret := this.m.Assert(actual, expected)

        Yunit.expect(ret).toBe(true)
        Yunit.expect(this.m)
          .toEql({hasPassedTest: true
          , actual: (actual)
          , expected: (expected)})
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
        Yunit.expect(this.m)
          .toEql({hasPassedTest: false
          , actual: (actual)
          , expected: (expected)})
        Yunit.expect(output).toEql(expectedOutput)
      }
    }
    
    ;; Class ToBeCloseTo
    Class ToBeCloseTo {
      beforeEach() {
        this.m := new Yunit.Matchers.ToBeCloseTo()
      }

      proximate_equality_true() {
        actual   := 0.1 + 0.2
        expected := 0.3

        ret := this.m.Assert(actual, expected)

        Yunit.expect(ret).toBe(true)
        Yunit.expect(this.m.hasPassedTest).toBe(true)
        ;; TODO: replace with ToContain/ToMatchObject matcher -> future
        Yunit.expect(this.m.actual.value).toBe(actual)
        Yunit.expect(this.m.expected.value).toBe(expected)
        Yunit.expect(this.m.expected.digits).toBe(2)
        Yunit.expect(this.m.expected.difference).toBe(0.005)
      }

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
        Yunit.expect(this.m.hasPassedTest).toBe(false)
        ;; TODO: replace with ToContain/ToMatchObject matcher -> future
        Yunit.expect(this.m.actual.value).toBe(actual)
        Yunit.expect(this.m.expected.value).toBe(expected)
        Yunit.expect(this.m.expected.digits).toBe(2)
        Yunit.expect(this.m.expected.difference).toBe(0.005)
        Yunit.expect(output).toEql([errorBlock, errorDetails])
      }
    }
    
    ;; Class ToThrow
    Class toThrow {
      
      Class _TypeError {
        message := "TypeError"
      }
      
      beforeEach() {
        this.m := new Yunit.Matchers.ToThrow()
      }
      
      _fn_does_not_throw() {
        return true
      }
      
      _fn_throws_a_string() {
        throw "An error"
      }
      
      _fn_throws_an_assertion_error() {
        throw new Yunit.AssertionError("message", "what", "extra", {hasPassedTest: false})
      }
            
      does_not_throw_an_error() {
        actual   := ObjBindMethod(this, "_fn_does_not_throw")
        expected := ""
        expectedOutput := "Received function did not throw."

        ret := this.m.Assert(actual, expected)
        output := this.m.GetErrorOutput()
        Yunit.expect(output).toEql(expectedOutput)
        
        Yunit.expect(this.m.actual.hasThrown).toBe(false)
        Yunit.expect(ret).toBe(false)
        Yunit.expect(this.m.hasPassedTest).toBe(false)
      }
      
      throws_an_error() {
        actual   := ObjBindMethod(this, "_fn_throws_a_string")
        expected := ""

        ret := this.m.Assert(actual, expected)
        
        Yunit.expect(ret).toBe(true)
        Yunit.expect(this.m.hasPassedTest).toBe(true)
        Yunit.expect(this.m.actual.hasThrown).toBe(true)
        Yunit.expect(this.m.retVal).toBe("An error")
        
        err := Yunit.expect(actual).toThrow()
        Yunit.expect(err).toBe("An error")
      }
      
      throws_an_error_correct_errortype() {
        actual   := ObjBindMethod(this, "_fn_throws_an_assertion_error")
        expected := Yunit.AssertionError

        ret := this.m.Assert(actual, expected)
        
        Yunit.expect(ret).toBe(true)
        Yunit.expect(this.m.hasPassedTest).toBe(true)
        Yunit.expect(this.m.actual.hasThrown).toBe(true)
        Yunit.expect(this.m.actual.errorType).toBe("Yunit.AssertionError")
        Yunit.expect(this.m.expected.errorType).toBe("Yunit.AssertionError")
      }
      
      throws_an_error_wrong_errortype() {
        actual   := ObjBindMethod(this, "_fn_throws_an_assertion_error")
        expected := YunitTest.Matchers.toThrow._TypeError
        expectedOutput := "
        (LTrim
        Actual error type:   Yunit.AssertionError
        Expected error type: YunitTest.Matchers.toThrow._TypeError
        
        Actual message:      message
        Actual what:         what
        Actual extra:        extra
        )"

        ret := this.m.Assert(actual, expected)
        output := this.m.GetErrorOutput()
        Yunit.expect(output).toEql(expectedOutput)
        
        Yunit.expect(ret).toBe(false)
        Yunit.expect(this.m.hasPassedTest).toBe(false)
        Yunit.expect(this.m.actual.hasThrown).toBe(true)
        Yunit.expect(this.m.actual.errorType).toBe("Yunit.AssertionError")
        Yunit.expect(this.m.expected.errorType).toBe("YunitTest.Matchers.toThrow._TypeError")
      }
    }
    
    ;; Class ToMatch
    Class ToMatch {
      
      beforeEach() {
        this.m := new Yunit.Matchers.ToMatch()
      }
      
      matches_a_string_true() {
        actual   := "ABC123456"
        expected := "i)abc\d"

        ret := this.m.Assert(actual, expected)
        
        Yunit.expect(ret).toBe(true)
        Yunit.expect(this.m.hasPassedTest).toBe(true)
        Yunit.expect(this.m.retVal[0]).toBe("ABC1")
      }

      matches_a_string_false() {
        actual   := "ABC123456"
        expected := "i)abd\d"
        
        expectedOutput =
        (LTrim
        Actual value:     "ABC123456"
        Expected pattern: "i)abd\d"
        )

        ret := this.m.Assert(actual, expected)
        output := this.m.GetErrorOutput()

        Yunit.expect(ret).toBe(false)
        Yunit.expect(this.m.hasPassedTest).toBe(false)
        Yunit.expect(output).toEql(expectedOutput)
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
        
        ; COM objects
        dict := ComObjCreate("Scripting.Dictionary")
        Yunit.expect(Yunit.Util.GetType(dict)).toBe("Dictionary")
        
        vt_empty := ComObject(0, &empty := {})
        Yunit.expect(Yunit.Util.GetType(vt_empty)).toBe("ComObject")
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

        printedObj1 := Yunit.Util.Print(obj1, {usePureNumbers: true})

        Yunit.expect(printedObj1).toEql("""a"":1")
      }

      print_an_object_with_integer_value_usePureNumbers_false() {
        obj1 := {a: 1}

        printedObj1 := Yunit.Util.Print(obj1)

        Yunit.expect(printedObj1).toEql("""a"":1")
      }

      print_an_object_with_a_string_integer_value_usePureNumbers_true() {
        obj1 := {a: "1"}

        printedObj1 := Yunit.Util.Print(obj1, {usePureNumbers: true})

        Yunit.expect(printedObj1).toEql("""a"":""1""")
      }

      print_an_object_with_a_string_integer_value_usePureNumbers_false() {
        obj1 := {a: "1"}

        printedObj1 := Yunit.Util.Print(obj1)

        Yunit.expect(printedObj1).toEql("""a"":1")
      }

      print_an_object_with_a_float_value_usePureNumbers_true() {
        obj1 := {a: 5.0}

        printedObj1 := Yunit.Util.Print(obj1, {usePureNumbers: true})

        Yunit.expect(printedObj1).toEql("""a"":5.0")
      }

      print_an_object_with_a_float_value_usePureNumbers_false() {
        obj1 := {a: 5.0}

        printedObj1 := Yunit.Util.Print(obj1)

        Yunit.expect(printedObj1).toEql("""a"":5.0")
      }

      print_an_object_with_a_string_float_value_usePureNumbers_true() {
        obj1 := {a: "5.0"}

        printedObj1 := Yunit.Util.Print(obj1, {usePureNumbers: true})

        Yunit.expect(printedObj1).toEql("""a"":5.0")
      }

      print_an_object_with_a_string_float_value_usePureNumbers_false() {
        obj1 := {a: "5.0"}

        printedObj1 := Yunit.Util.Print(obj1)

        Yunit.expect(printedObj1).toEql("""a"":5.0")
      }
      
      print_an_object_with_a_multiline_string_useRenderWhiteSpace_false() {
        obj1 := {a: "line1`nline2"}

        printedObj1 := Yunit.Util.Print(obj1)

        Yunit.expect(printedObj1).toEql("""a"":""line1`nline2""")
      }
      
      print_an_object_with_a_multiline_string_useRenderWhiteSpace_true() {
        Yunit.SetOptions({ outputRenderWhiteSpace: true })
        
        obj1 := {a: "line1`nline2"}
        
        printedObj1 := Yunit.Util.Print(obj1, {renderWhiteSpace: true})
        expected := """a"":""line1{format.textDimmed}``n{format.text}line2"""
        Yunit.expect(printedObj1).toEql(expected)
        
        Yunit.RestoreOptions()
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