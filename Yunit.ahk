;#NoEnv

;; Class Yunit
class Yunit
{
  static options := {EnablePrivateProps: true, TimingWarningThreshold: 100}
  
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

  /**
  * Sets Yunit options
  * @param {object} options - object with options 
  * @returns {void} 
  */
  SetOptions(options) {
    for key, value in options {
      Yunit["options"][key] := value
    }
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
  }

  Update(Category, Test, Result, methodTime_ms)
  {
    for k,module in this.Modules
      module.Update({category: (category)
        , testMethod: (test)
        , result: (result)
        , methodTime_ms: (methodTime_ms)})
  }

  TestClass(results, cls)
  {
    if (!this._validateHooks(cls)) {
      throw Exception("Please use either 'begin/end' or 'beforeEach/afterEach' but don't mix.")
    }
    environment := new cls() ; calls __New
    for k,v in cls
    {
      if IsObject(v) && IsFunc(v) ;test
      {
        if (!this._isTestMethod(k))
          continue
        if ObjHasKey(cls,"Begin") && IsFunc(cls.Begin)
          environment.Begin()
        if ObjHasKey(cls,"beforeEach") && IsFunc(cls.beforeEach)
          environment.beforeEach()
        result := 0
        Yunit.Util.QPCInterval()
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
        methodTime_ms := Yunit.Util.QPCInterval()
        OutputDebug % (k ": " methodTime_ms)
        results[k] := result
        ObjDelete(environment, "ExpectedException")
        this.Update(cls.__class, k, results[k], methodTime_ms)
        if ObjHasKey(cls,"End") && IsFunc(cls.End)
          environment.End()
        if ObjHasKey(cls,"afterEach") && IsFunc(cls.afterEach)
          environment.afterEach()
      }
      else if IsObject(v)
        && ObjHasKey(v, "__class") ;category
        this.classes.InsertAt(++this.current, v)
    }
  }

  /** 
  * Checks whether BeforeEach/AfterEach and Begin/End are used in a mutually
  * exclusive way 
  * @param {string} classObj - class object to test 
  * @returns {boolean} 
  */
  _validateHooks(classObj) {
    isBeforeAfterEach := classObj.HasKey("BeforeEach") || classObj.HasKey("AfterEach")
    isBeforeEnd       := classObj.HasKey("Begin") || classObj.HasKey("End")
    return !(isBeforeAfterEach && isBeforeEnd)
  }

  /**
  * Checks whether the method name belongs to a test method
  * @param {string} name - name of method to check
  * @returns {boolean} 
  */
  _isTestMethod(name) {
    basicRegex := "i)(^begin$|^end$|^beforeEach$|^afterEach$|^__New$|^__Delete${1})"
    regex := format(basicRegex, Yunit.Options.EnablePrivateProps ? "|^_" : "")
		return !!!RegExMatch(name, regex)
	}

  /**
  * Checks whether the class name belongs to a test category
  * @param {string} name - name of class to check
  * @returns {boolean} 
  */
  _isTestCategory(name) {
    if (!Yunit.Options.EnablePrivateProps) {
      return true
    }
    return !!!(name ~= "^_")
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
    * Checks whether a variable is an array
    * Empty objects/arrays will return true
    * @param {*} var - variable to check
    * @returns {boolean} 
    */
    IsArray(var) {
      switch {
        case !IsObject(var):
          return false
        case ObjCount(var) == 0:
          return true
      }
      enum := var._newEnum()
      enum.next(key, value)
      return this.IsInteger(key)
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
          case this.IsInteger(key):
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
    
    /** 
    * Performance counter is a high resolution (<1us) time stamp
    * that can be used for time-interval measurements.
    *
    * Retrieves the elapsed time in ms since the last call to QPC()
    * https://docs.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter
    * @returns {float} 
    */
    QPCInterval(){
      Static qpcFreq := 0, qpcNow := 0, qpcLast := 0
    
      if (!qpcFreq && !DllCall("QueryPerformanceFrequency", "Int64 *", qpcFreq)) {
          throw Exception("Failure executing 'QueryPerformanceFrequency'")
      }
    
      qpcLast := qpcNow
      if (!DllCall("QueryPerformanceCounter", "Int64 *", qpcNow)) {
        throw Exception("Failure executing 'QueryPerformanceCounter'")
      }
      return (qpcNow - qpcLast) / qpcFreq * 1000
    }
    
    /**
    * Checks whether a search value is included in an array
    * @param {object} arrayObj - array
    * @param {string | number} searchValue - value to search for 
    * @param {integer} [caseSense:=false] - case insensitive
    * @returns {boolean} 
    */
    Includes(arrayObj, searchValue, caseSense := false) {
      if (isObject(searchValue)) {
        throw Exception(A_ThisFunc " - TypeError: 2nd parameter must be number or string", -2)
      }
      for _, value in arrayObj {
        condition := caseSense ? searchValue == value : searchValue = value
        if (condition) {
          return true
        }
      }
      return false
    }
  }
  
  ;; Class _ExpectBase
  Class _ExpectBase {
    
    matchers := ["toBe", "toEqual", "toBeCloseTo"]
        
    /**
    * Meta function: routes matcher to Yunit.Matchers
    * @param {string} methodName - method name of matcher 
    * @param {any} params - arguments passed to matcher
    * @returns {object} matcher info 
    */
    __Call(methodName, params*) {
      ; OutputDebug, % methodname ", " Yunit.Util.Print(params)
      if (!Yunit.Util.Includes(this.matchers, methodName)) {  
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
    * @typedef matcherInfo
    * @property {boolean} hasPassedTest
    * @property {any} actual
    * @property {any} expected
    * @property {string} [matcherType] - e.g. "ToBe", set by expect()
    * @property {object} [err] - error object, set by .toThrow()
    */
    
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
    * numbers are compared numerically,
    * objects are compared by their stringified contents
    * @param {any} actual 
    * @param {any} expected 
    * @returns {matcherInfo} 
    */
    ToEqual(actual, expected) {
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
    
    /**
    * Matcher: compares 2 float numbers for proximate equality
    * @param {float} actual
    * @param {float} expected
    * @param {integer} digits - number of digits
    * @returns {matcherInfo} 
    */
    ToBeCloseTo(actual, expected, digits := 15) {
      actual := Round(actual, digits)
      expected := Round(expected, digits)
      return this.ToBe(actual, expected)
    }
  }
  
}
