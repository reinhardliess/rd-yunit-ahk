Class YunitTest {
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
    
    Class ToBe {

      beforeEach() {
        this.m := new Yunit.Matchers.ToBe()
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
        expectedOutput =
        (LTrim
        Actual:   "Zoi"
        Expected: "Zoe"
        )

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
        Yunit.expect(output).toEqual(expectedOutput)
      }
    }

    Class ToEqual {
      beforeEach() {
        this.m := new Yunit.Matchers.ToEqual()
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
        Yunit.expect(output).toEqual(expectedOutput)
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
}