Class YunitTest {
  Class Matchers {
    tobe_integer_true() {
      matcher := new Yunit.MatcherToBe()
      
      ret := matcher.Assert(5, 5)
      
      Yunit.expect(ret).toBe(true)
      Yunit.expect(matcher).toEqual({actual: 5, expected: 5, hasPassedTest: 1})
    }

    tobe_integer_false() {
      matcher := new Yunit.MatcherToBe()
      
      ret := matcher.Assert(5, 6)
      
      Yunit.expect(ret).toBe(false)
      Yunit.expect(matcher).toEqual({actual: 5, expected: 6, hasPassedTest: 0})
    }
    
    toEqual_obj_true() {
      matcher := new Yunit.MatcherToEqual()
      actual   := {a: 1}
      expected := {a: 1}
      
      ret := matcher.Assert(actual, expected)
      
      Yunit.expect(ret).toBe(true)
      Yunit.expect(matcher.actual).toBe(actual)
      Yunit.expect(matcher.expected).toBe(expected)
    }
    
    toEqual_obj_false() {
      matcher := new Yunit.MatcherToEqual()
      actual   := {a: 1}
      expected := {a: 2}
      
      ret := matcher.Assert(actual, expected)
      
      Yunit.expect(ret).toBe(false)
      Yunit.expect(matcher.actual).toBe(actual)
      Yunit.expect(matcher.expected).toBe(expected)
    }
    
    toBeCloseTo_true() {
      matcher := new Yunit.MatcherToBeCloseTo()
      actual   := 0.1 + 0.2
      expected := 0.3
      
      ret := matcher.Assert(actual, expected)
      
      Yunit.expect(ret).toBe(true)
      ;; TODO: replace with ToContain matcher -> object
      Yunit.expect(matcher.actual.value).toBe(actual)
      Yunit.expect(matcher.expected.value).toBe(expected)
      Yunit.expect(matcher.expected.digits).toBe(2)
      Yunit.expect(matcher.expected.difference).toBe(0.005)
    }
    
    toBeCloseTo_false() {
      matcher := new Yunit.MatcherToBeCloseTo()
      actual   := 0.1 + 0.2
      expected := 0.29
      
      ret := matcher.Assert(actual, expected)
      
      Yunit.expect(ret).toBe(false)
      ;; TODO: replace with ToContain matcher -> object
      Yunit.expect(matcher.actual.value).toBe(actual)
      Yunit.expect(matcher.expected.value).toBe(expected)
      Yunit.expect(matcher.expected.digits).toBe(2)
      Yunit.expect(matcher.expected.difference).toBe(0.005)
    }
  }
}