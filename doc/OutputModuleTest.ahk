#Include ../Yunit.ahk

class OutputModuleTest {

  class assert {
    integer_addition_correct_result() {
      Yunit.assert(1 + 3 == 4)
    }

    integer_addition_error() {
      Yunit.assert(1 + 3 == 5)
    }

    integer_addition_error_message() {
      Yunit.assert(1 + 3 == 5, "An error happened")
    }
  }

  class toBe {

    integer_addition_correct_result() {
      Sleep 30
      Yunit.expect(1 + 4).toBe(5)
    }

    integer_addition_error() {
      Yunit.expect(1 + 4).toBe(6)
    }
    
    string_comparison_error() {
      Yunit.expect("Zoi").toBe("Zoe")
    }

    float_addition_error() {
      Yunit.expect(0.1 + 0.2).toBe(0.3)
    }

    object_comparison_error() {
      Yunit.expect({a:1}).toBe({a:1})
    }
  }
  
  Class toEql {
    objects_equal() {
      Yunit.expect({b: 2, a: 1}).toEql({a:1, b:2})
    }

    objects_not_equal() {
      Yunit.expect({a:1}).toEql({a:1, b:2})
    }

  }
  
  Class toBeCloseTo {
      
    floats_proximate_equal() {
      Yunit.expect(0.1 + 0.2).ToBeCloseTo(0.3)
    }

    floats_proximate_not_equal() {
      Yunit.expect(0.1 + 0.19).ToBeCloseTo(0.3)
    }
  }

}