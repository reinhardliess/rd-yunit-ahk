#Requires AutoHotkey v2.0-beta.1

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
    if (!Yunit._validateHooks(cls)) {
      throw Error("Please use either 'begin/end' or 'beforeEach/afterEach' but don't mix.")
    }
    environment := cls() ; calls __New
    for k in cls.prototype.OwnProps()
    {
      if !(cls.prototype.%k% is Func)
        continue
      if (!Yunit._isTestMethod(k))
        continue
      if environment.HasMethod("Begin")
        environment.Begin()
      if environment.HasMethod("BeforeEach")
        environment.BeforeEach()
      result := 0
      Yunit.Util.QPCInterval()
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
      methodTime_ms := Yunit.Util.QPCInterval()
      ; OutputDebug (k ": " methodTime_ms)
      results[k] := result
      environment.DeleteProp("ExpectedException")
      this.Update(cls.prototype.__class, k, results[k], methodTime_ms)
      if environment.HasMethod("End")
        environment.End()
      if environment.HasMethod("AfterEach")
        environment.AfterEach()
    }
    for k, v in cls.OwnProps()
      if (v is Class && Yunit._isTestCategory(v.Prototype.__class))
        this.classes.InsertAt(++this.current, v)
  }

  /** 
  * Checks whether BeforeEach/AfterEach and Begin/End are used in a mutually
  * exclusive way 
  * @param {string} classObj - class object to test 
  * @returns {boolean} 
  */
  static _validateHooks(classObj) {
    isBeforeAfterEach := classObj.Prototype.HasMethod("BeforeEach") || classObj.Prototype.HasMethod("AfterEach")
    isBeforeEnd       := classObj.Prototype.HasMethod("Begin") || classObj.Prototype.HasMethod("End")
    return !(isBeforeAfterEach && isBeforeEnd)
  }

  /**
  * Checks whether the method name belongs to a test method
  * @param {string} name - name of method to check
  * @returns {boolean} 
  */
  static _isTestMethod(name) {
    basicRegex := "i)(^begin$|^end$|^beforeEach$|^afterEach$|^__New$|^__Delete${1})"
    regex := format(basicRegex, Yunit.Options.EnablePrivateProps ? "|^_" : "")
		return !!!RegExMatch(name, regex)
	}

  /**
  * Checks whether the class name belongs to a test category
  * @param {string} name - name of class to check
  * @returns {boolean} 
  */
  static _isTestCategory(name) {
    if (!Yunit.Options.EnablePrivateProps) {
      return true
    }
    classesArray := StrSplit(name, ".")
    last := classesArray.Pop()
    return !!!(last~= "^_")
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
    * Checks whether a variable is an array
    * Empty objects/arrays will return true
    * @param {*} var - variable to check
    * @returns {boolean} 
    */
    static IsArray(var) {
      return (var is Array)
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
    
    /**
    * Checks whether a search value is included in an array
    * @param {array} arrayObj - array
    * @param {string | number} searchValue - value to search for 
    * @param {boolean} [caseSense:=false]
    * @returns {boolean} 
    */
    static Includes(arrayObj, searchValue, caseSense := false) {
      if (isObject(searchValue)) {
        throw TypeError(A_ThisFunc " - TypeError: 2nd parameter must be number or string", -2)
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
    * @param {any*} params - arguments passed to matcher
    * @returns {object} matcher info 
    */
    __Call(methodName, params) {
      ; OutputDebug, % methodname ", " Yunit.Util.Print(params)
      if (!Yunit.Util.Includes(this.matchers, methodName)) {  
        Throw MethodError(format("The matcher '{1}' doesn't exist.", methodName))
      }
      
      ret := Yunit.Matchers.%methodName%(this.actualValue, params*)
      ret.matcherType := methodName
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
