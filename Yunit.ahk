#Requires AutoHotkey v2.0-beta.1

;; Class Yunit
class Yunit
{
  static options :=  {EnablePrivateProps: true, TimingWarningThreshold: 100}
  
  class Tester extends Yunit
  {
    __New(Modules)
    {
      this.Modules := Modules
    }
  }

  static Use(Modules*)
  {
    return (this.Tester)(Modules)
  }

  New(p*) => (o := { base: this }, o.__new(p*), o)

  /**
  * Sets Yunit options
  * @param {object} options - object with options 
  * @returns {void} 
  */
  static SetOptions(options) {
    for key, value in options.OwnProps() {
      Yunit.options.%key% := value
    }
  }
  
  Test(classes*) ; static method
  {
    instance := this.new("")
    instance.results := Map()
    instance.classes := classes
    instance.Modules := Array()
    for module in instance.base.Modules
      instance.Modules.Push(module(instance))
    for cls in classes
    {
      instance.current := A_Index
      instance.results[cls.prototype.__class] := obj := Map()
      instance.TestClass(obj, cls)
    }
  }

  Update(Category, Test, Result)
  {
    for module in this.Modules
      module.Update(Category, Test, Result)
  }

  TestClass(results, cls)
  {
    environment := cls() ; calls __New
    for k in cls.prototype.OwnProps()
    {
      if !(cls.prototype.%k% is Func)
        continue
      if (k = "Begin") or (k = "End") or (k = "__New") or (k == "__Delete")
        continue
      if environment.HasMethod("Begin")
        environment.Begin()
      result := 0
      try
      {
        environment.%k%()
        if ObjHasOwnProp(environment, "ExpectedException")
          throw Error("ExpectedException")
      }
      catch Error as err
      {
        if !ObjHasOwnProp(environment, "ExpectedException")
          || !this.CompareValues(environment.ExpectedException, err)
          result := err
      }
      results[k] := result
      environment.DeleteProp("ExpectedException")
      this.Update(cls.prototype.__class, k, results[k])
      if environment.HasMethod("End")
        environment.End()
    }
    for k, v in cls.OwnProps()
      if v is Class
        this.classes.InsertAt(++this.current, v)
  }

  static Assert(Value, params*)
  {
    try
      Message := params[1]
    catch
      Message := "FAIL"
    if (!Value)
      throw Error(Message, -1)
  }

  CompareValues(v1, v2)
  {   ; Support for simple exceptions. May need to be extended in the future.
    if !IsObject(v1) || !IsObject(v2)
      return v1 = v2   ; obey StringCaseSense
    if !ObjHasOwnProp(v1, "Message") || !ObjHasOwnProp(v2, "Message")
      return False
    return v1.Message = v2.Message
  }

  static Expect(actualValue) {
    return Yunit._Expect(actualValue)
  }
  
  ;; Class Util
  Class Util {
    static IsNumber(var) {
      return this.isInteger(var) || this.isFloat(var)
    }

    static IsInteger(var) {
      if var is integer
      {
        return true
      }
      return false
    }

    static IsFloat(var) {
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
    static GetType(var) {
      return Type(var)
    }

    /**
    * Checks whether an object is callable
    * @param {object} obj - object to check
    * @returns {boolean}
    */
    static IsFunction(obj) {
      return HasMethod(obj) 
    }

    /**
    * Stringifies variable
    * @param {*} value - variable to stringify 
    * @returns {string} 
    */
    static Print(value) {

      if (!IsObject(value)) {
        return value
      }
  
      return this._stringify(value)
    }
  
    static _stringify(param_value) {
      if (!isObject(param_value)) {
        return '"' param_value '"'
      }
      
      output := ""
      iterator := (param_value is Array || param_value is Map) 
        ? param_value 
        : param_value.OwnProps()
  
      for key, value in iterator {
        output .= this._stringifyGenerate(key, value)
      }
      output := subStr(output, 1, -2)
      return output
    }
  
    static _stringifyGenerate(key, value) {
      output := ""
  
      switch {
        case IsObject(key):
          ; Skip map elements with object references as keys
          return ""
        case key is integer:
          output .= key . ":"
        default:
          output .= '"' . key . '":'
      }
  
      switch {
        case IsObject(value) && value.HasMethod():
          ; Skip callable objects
          return ""
        case IsObject(value):
          output .= "[" . this._stringify(value) . "]"
        case IsNumber(value):
          output .= value
        default:
          output .= '"' . value . '"'
      }
  
      return output .= ", "
    }
    
    /** 
    * Performance counter is a high resolution (<1us) time stamp
    * that can be used for time-interval measurements.
    *
    * Retrieves the elapsed time in ms since the last call to QPC()
    * https://docs.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter
    * @returns {float} 
    */
    static QPCInterval(){
      Static qpcFreq := 0, qpcNow := 0, qpcLast := 0
    
      if (!qpcFreq && !DllCall("QueryPerformanceFrequency", "Int64 *", &qpcFreq)) {
        throw Error("Failure executing 'QueryPerformanceFrequency'")
      }
    
      qpcLast := qpcNow
      if (!DllCall("QueryPerformanceCounter", "Int64 *", &qpcNow)) {
        throw Error("Failure executing 'QueryPerformanceCounter'")
      }
    
      return (qpcNow - qpcLast) / qpcFreq * 1000
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
    __Call(methodName, params) {
      ; OutputDebug, % methodname ", " Yunit.Util.Print(params)
      if (!this._findMatcher(methodName)) {  
        Throw MethodError(format("The matcher '{1}' doesn't exist.", methodName))
      }
      
      ret := Yunit.Matchers.%methodName%(this.actualValue, params*)
      ret.matcherType := methodName
      ; OutputDebug, % Yunit.Util.Print(ret)
      if (!ret.hasPassedTest) {
        throw Yunit.AssertionError("Assertion error", -2, , ret)
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
  Class AssertionError extends Error {
    __New(message, what := -1, extra :="", matcherInfo := "") {
      super.__New(message, what, extra)
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
    static ToBe(actual, expected) {
      info := {actual: actual, expected: expected}
      ; OutputDebug, % info.actual
      info.hasPassedTest := (actual == expected) 
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
    static toEqual(actual, expected) {
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
    static ToBeCloseTo(actual, expected, digits := 15) {
      actual := Round(actual, digits)
      expected := Round(expected, digits)
      return this.ToBe(actual, expected)
    }
  }
  
}
