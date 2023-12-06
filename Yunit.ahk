;#NoEnv

;; Class Yunit
class Yunit
{
  class Tester extends Yunit
  {
    __New(Modules)
    {
      this.Modules := Modules
    }
  }

  Use(Modules*)
  {
    return new this.Tester(Modules)
  }

  Test(classes*) ; static method
  {
    instance := new this("")
    instance.results := {}
    instance.classes := classes
    instance.Modules := []
    for k,module in instance.base.Modules
      instance.Modules[k] := new module(instance)
    while (A_Index <= classes.Length())
    {
      cls := classes[A_Index]
      instance.current := A_Index
      instance.results[cls.__class] := obj := {}
      instance.TestClass(obj, cls)
    }
    if (!WinExist("Yunit Testing ahk_class AutoHotkeyGUI")) {
      ExitApp
    }
  }

  Update(Category, Test, Result)
  {
    for k,module in this.Modules
      module.Update(Category, Test, Result)
  }

  TestClass(results, cls)
  {
    environment := new cls() ; calls __New
    for k,v in cls
    {
      if IsObject(v) && IsFunc(v) ;test
      {
        if (k = "Begin") or (k = "End") or (k = "__New") or (k == "__Delete")
          continue
        if ObjHasKey(cls,"Begin")
          && IsFunc(cls.Begin)
          environment.Begin()
        result := 0
        try
        {
          %v%(environment)
          if ObjHasKey(environment, "ExpectedException")
            throw Exception("ExpectedException")
        }
        catch error
        {
          if !ObjHasKey(environment, "ExpectedException")
            || !this.CompareValues(environment.ExpectedException, error)
            result := error
        }
        results[k] := result
        ObjDelete(environment, "ExpectedException")
        this.Update(cls.__class, k, results[k])
        if ObjHasKey(cls,"End")
          && IsFunc(cls.End)
          environment.End()
      }
      else if IsObject(v)
        && ObjHasKey(v, "__class") ;category
        this.classes.InsertAt(++this.current, v)
    }
  }

  Assert(Value, params*)
  {
    Message := (params[1] = "") ? "FAIL" : params[1]
    if (!Value)
      throw Exception(Message, -1)
  }

  CompareValues(v1, v2)
  { ; Support for simple exceptions. May need to be extended in the future.
    if !IsObject(v1) || !IsObject(v2)
      return v1 = v2 ; obey StringCaseSense
    if !ObjHasKey(v1, "Message") || !ObjHasKey(v2, "Message")
      return False
    return v1.Message = v2.Message
  }

  Expect(actualValue) {
    return new Yunit._Expect(actualValue)
  }
  
  ;; Class Util
  Class Util {
    IsNumber(var) {
      return this.isInteger(var) || this.isFloat(var)
    }

    IsInteger(var) {
      if var is integer
      {
        return true
      }
      return false
    }

    IsFloat(var) {
      if var is float
      {
        return true
      }
      return false
    }

    /**
    * Returns the type of the variable
    * @param {*} var - variable to check
    * @returns {string}
    */
    GetType(var) {
      switch {
        case isObject(var) && className := var.__class:
          return (var.base.__class = className) ? className : "Class"
        case isObject(var):
          return "Object"
        case this.IsInteger(var):
          return "Integer"
        case this.IsFloat(var):
          return "Float"
        default:
          return "String"
      }
    }

    /**
    * Checks whether an object is callable
    * @param {object} obj - object to check
    * @returns {boolean}
    */
    IsFunction(obj) {
      if (!isObject(obj)) {
        return false
      }
      funcReference := numGet(&(_ := Func("inStr").bind()), "ptr")
      return (isFunc(obj) || (numGet(&obj, "ptr") = funcReference))
    }

    /**
    * Stringifies variable
    * @param {*} value - variable to stringify 
    * @returns {string} 
    */
    Print(value) {
      out := (isObject(value) ? this._stringify(value) : value)
      return out
    }

    _stringify(param_value) {
      output := ""

      for key, value in param_value {
        
        ; skip callable objects
        if (this.IsFunction(value)) {
          continue
        }
        
        switch {
          case this.IsNumber(key):
            output .= key . ":"
          default:
            output .= """" . key . """:"
        }

        switch {
          case IsObject(value):
            output .= "[" . this._stringify(value) . "]"
          case this.IsNumber(value):
            output .= value
          default:
            output .= """" . value . """"
        }
        output .= ", "
      }

      return subStr(output, 1, -2)
    }
  }
  
  ;; Class _ExpectBase
  Class _ExpectBase {
    
    matchers := ["toBe", "toEqual"]
        
    /**
    * Meta function: routes matcher to Yunit.Matchers
    * @param {string} methodName - method name of matcher 
    * @param {any} params - arguments passed to matcher
    * @returns {object} matcher info 
    */
    __Call(methodName, params*) {
      ; OutputDebug, % methodname ", " Yunit.Util.Print(params)
      if (!this._findMatcher(methodName)) {  
        Throw Exception(format("The matcher '{1}' doesn't exist.", methodName))
      }
      
      ret := Yunit["Matchers"][methodName](this.actualValue, params*)
      ret.matcherType := methodName
      ; OutputDebug, % Yunit.Util.Print(ret)
      if (!ret.hasPassedTest) {
        throw new Yunit.AssertionError("Assertion error", -2, , ret)
      }
      return ret
    }
  }
  
  ;; Class Expect
  Class _Expect extends Yunit._ExpectBase {
    
    __New(Value) {
      this.actualValue := value
    }
    
    /**
    * Checks whether a matcher exists
    * @param {string} name - name of matcher to check
    * @returns {boolean} 
    */
    _findMatcher(name) {
      for _, value in this.matchers {
        if (value = name) {
          return true
        }
      }
      return false
    }
  }
  
  ;; Class AssertionError
  Class AssertionError {
    __New(message, what := -1, extra :="", matcherInfo := "") {
      err := Exception(message, what, extra)
      for key, value in err {
        this[key] := value
      }
      this.matcherInfo := matcherInfo
    }  
  }

  ;; Class Matchers
  Class Matchers {
    
    /**
    * Matcher: compares two values for equality
    * objects are compared by object reference
    * @param {any} actual 
    * @param {any} expected 
    * @returns {matcherInfo} 
    */
    ToBe(actual, expected) {
      info := {actual: actual, expected: expected}
      ; OutputDebug, % info.actual
,      info.hasPassedTest := (actual == expected) 
        ? true
        : false
      return info
    }
    
    /**
    * Matcher: compares two values for equality
    * 2 numbers are compared numerically,
    * objects are compared by their stringified contents
    * @param {any} actual 
    * @param {any} expected 
    * @returns {matcherInfo} 
    */
    toEqual(actual, expected) {
      if (Yunit.Util.IsNumber(actual) 
        && Yunit.Util.IsNumber(expected)) {
        return this.ToBe(actual, expected)
      }
      if (isObject(actual)) {
        actual := Yunit.Util.Print(actual)
      }
      if (isObject(expected)) {
        expected := Yunit.Util.Print(expected)
      }
      ; OutputDebug, % actual
      return this.ToBe(actual, expected)
    }
  }
  
}
