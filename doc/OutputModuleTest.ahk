#Include ../Yunit.ahk

class OutputModuleTest {

  Class Numbers {
    integer_addition_true() {
      Yunit.expect(1 + 4).toBe(5)
    }

    integer_addition_false() {
      Yunit.expect(1 + 4).toBe(6)
    }
    
    float_addition_false() {
      Yunit.expect(0.1 + 0.2, "calculate 0.1 + 0.2").toBe(0.3)
    }

    floats_proximate_equal() {
      Yunit.expect(0.1 + 0.2).ToBeCloseTo(0.3)
    }

    floats_proximate_not_equal() {
      Yunit.expect(0.1 + 0.19).ToBeCloseTo(0.3)
    }
  }
  
  class Strings {
    match_a_string_true() {
      match := Yunit.expect("abcXYZ123").toMatch("abc(.*)123")
      Yunit.expect(match[1]).toBe("XYZ")
    }
    
    match_a_string_false() {
      Yunit.expect("abcdef").toMatch("BC")
    }
    
    string_comparison_false() {
      Yunit.expect("Zoi").toBe("Zoe")
    }
  }
  
  Class Objects {

    object_comparison_false() {
      Yunit.expect({a:1}).toBe({a:1})
    }
    
    objects_equal() {
      ; force a slow test
      Sleep 30
      Yunit.expect({b: 2, a: 1}).toEql({a:1, b:2})
    }
  
    objects_not_equal() {
      Yunit.expect({a:1}).toEql({a:1, b:2})
    }
  }
  
  Class toThrow {
    Class _TypeError {
      message := "TypeError"
    }

    _fn_does_not_throw() {
      return true
    }
    
    _fn_throws_an_assertion_error() {
      throw Yunit.AssertionError("message", , "extra", {hasPassedTest: false})
    }

    throws_wrong_error_type() {
      actual   := ObjBindMethod(this, "_fn_throws_an_assertion_error")
      expected := OutputModuleTest.toThrow._TypeError

      Yunit.expect(actual).toThrow(expected)
    }
    
    throws_correct_error_type() {
      actual   := ObjBindMethod(this, "_fn_throws_an_assertion_error")
      expected := Yunit.AssertionError

      err := Yunit.expect(actual).toThrow(expected)
      Yunit.expect(err.message).toBe("message")
    }
    
    does_not_throw_an_error() {
      actual   := ObjBindMethod(this, "_fn_does_not_throw")

      err := Yunit.expect(actual).toThrow()
    }
  }
}