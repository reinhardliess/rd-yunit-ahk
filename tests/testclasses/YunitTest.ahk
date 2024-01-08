Class YunitTest {
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
      matcher := Yunit.Matchers.ToBe({message: "error"})
      
      Yunit.expect(matcher.message).toBe("error")
    }

    getMatcherType_should_return_matcher_display_name() {
      matcher := Yunit.Matchers.ToBe()
      matcherName := matcher.getMatcherType()
      
      Yunit.expect(matcherName).toBe("ToBe")
    }
    
    render_linefeeds_in_strings_if_option_set() {
      matcher := Yunit.Matchers.ToBe()
      lineLf := matcher.formatActualTestValue("Hello World!`nHow are you?")
      lineCrlf := matcher.formatActualTestValue("Hello World!`r`nHow are you?")
      
      Yunit.expect(lineLf).toBe('"Hello World!{format.textDimmed}``n{format.error}How are you?"')
      Yunit.expect(lineCrlf).toBe('"Hello World!{format.textDimmed}``r``n{format.error}How are you?"')
    }
    
    render_esc_in_strings_if_option_set() {
      matcher := Yunit.Matchers.ToBe()
      lineWithEsc := matcher.formatActualTestValue(chr(27) "[95m" "Hello World!")
      
      expected := format("{1}{format.textDimmed}``e{format.error}[95mHello World!{1}", chr(34), chr(27))
      Yunit.expect(lineWithEsc).toBe(expected)
    }
    
    Class ToBe {

      beforeEach() {
        this.m := Yunit.Matchers.ToBe()
      }

      integer_comparison_true() {
        ret := this.m.Assert(5, 5)

        Yunit.expect(ret).toBe(true)
        Yunit.expect(this.m).toEqual({actual: 5, expected: 5, hasPassedTest: 1})
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
        Yunit.expect(this.m).toEqual({actual: 5, expected: 6, hasPassedTest: 0})
        Yunit.expect(output).toEqual(expected)
      }

      string_comparison_true() {
        ret := this.m.Assert("Zoe", "Zoe")

        Yunit.expect(ret).toBe(true)
        Yunit.expect(this.m).toEqual({actual: "Zoe", expected: "Zoe", hasPassedTest: 1})
      }

      string_comparison_false() {
        expectedOutput := "
        (LTrim
        Actual:   "Zoi"
        Expected: "Zoe"
        )"

        ret := this.m.Assert("Zoi", "Zoe")
        output := this.m.GetErrorOutput()

        Yunit.expect(ret).toBe(false)
        Yunit.expect(this.m).toEqual({actual: "Zoi", expected: "Zoe", hasPassedTest: 0})
        Yunit.expect(output).toEqual(expectedOutput)
      }

      object_comparison_true() {
        obj1 := {a: 1}, obj1ref := obj1

        ret := this.m.Assert(obj1, obj1ref)

        Yunit.expect(ret).toBe(true)
        Yunit.expect(this.m.actual).toBe(this.m.expected)
      }

      object_comparison_false() {
        obj1 := {a: 1}, obj2 := {a: 1}
        expectedOutput := "
        (LTrim
        Actual:   "a":1
        Expected: "a":1
        )"

        ret := this.m.Assert(obj1, obj2)
        output := this.m.GetErrorOutput()

        Yunit.expect(ret).toBe(false)
        ; TODO: Yunit.expect(m.actual).not.toBe(m.expected)
        Yunit.expect(output).toEqual(expectedOutput)
      }
    }

    Class ToEqual {
      beforeEach() {
        this.m := Yunit.Matchers.ToEqual()
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
        expectedOutput := "
        (LTrim
        Actual:   "a":1
        Expected: "a":2
        )"

        ret := this.m.Assert(actual, expected)
        output := this.m.GetErrorOutput()

        Yunit.expect(ret).toBe(false)
        Yunit.expect(this.m.actual).toBe(actual)
        Yunit.expect(this.m.expected).toBe(expected)
        Yunit.expect(output).toEqual(expectedOutput)
      }
    }

    Class ToBeCloseTo {
      beforeEach() {
        this.m := Yunit.Matchers.ToBeCloseTo()
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
  
  Class Util {
    join_should_join_array_elements_with_separator() {
      Yunit.expect(Yunit.Util.Join([])).toEqual("")
      Yunit.expect(Yunit.Util.Join([1])).toEqual("1")
      Yunit.expect(Yunit.Util.Join([1,2])).toEqual("1,2")
      Yunit.expect(Yunit.Util.Join(["a","b"])).toEqual("a,b")
      Yunit.expect(Yunit.Util.Join([1,2], ";")).toEqual("1;2")
    }
  }
}