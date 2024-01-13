#Requires AutoHotkey v2.0-beta.1

;; Class Yunit
class Yunit
{
  static options := {EnablePrivateProps: true
    , TimingWarningThreshold: 100
    , OutputRenderWhiteSpace: false}

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
      Yunit.executeGlobalHook(cls, "BeforeEachAll", environment)
      Yunit.executeHook(cls, "Begin", environment)
      Yunit.executeHook(cls, "BeforeEach", environment)
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
      methodTime_ms := Round(Yunit.Util.QPCInterval())
      ; OutputDebug (k ": " methodTime_ms)
      results[k] := result
      environment.DeleteProp("ExpectedException")
      this.Update(cls.prototype.__class, k, results[k], methodTime_ms)
      Yunit.executeHook(cls, "End", environment)
      Yunit.executeHook(cls, "afterEach", environment)
      Yunit.executeGlobalHook(cls, "AfterEachAll", environment)
    }
    for k, v in cls.OwnProps()
      if (v is Class && Yunit._isTestCategory(v.Prototype.__class))
        this.classes.InsertAt(++this.current, v)
  }

  /**
  * Execute hook if it exists
  * @param {string} cls - class
  * @param {string} method - method to execute
  * @param {string} instance - instance
  * @returns {void}
  */
  static executeHook(cls, method, instance, params*) {
    if (cls.Prototype.hasMethod(method))
      instance.%method%(params*)
  }

  /**
  * Executes global hook if it exists
  * Global hooks are executed in the top level and all nested classes
  * @param {string} cls - class object
  * @param {string} method
  * @param {string} instance
  * @returns {void}
  */
  static executeGlobalHook(cls, method, instance) {
    topLevelClass := StrSplit(Type(instance), ".")[1] 
    classObj := %topLevelClass%
    ; Yunit.executeHook(classObj, method, classObj, instance)
    if (classObj.HasMethod(method)) {
      classObj.%method%(instance)
    }
  }

  /**
  * Checks whether BeforeEach/AfterEach and Begin/End are used in a
  * mutually exclusive way
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
    basicRegex := "i)(^begin$|^end$|^beforeEach$|^beforeEachAll$|^afterEach$|^afterEachAll$|^__New$|^__Delete${1})"
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

  /**
  * Expect gives access to a number of matchers
  * @throws Yunit.AssertionError if expectation fails
  * @param {string} actualValue - the value to test
  * @param {string} [message] - optional error message for output module
  * to print
  * @returns {any}
  */
  static Expect(actualValue, message := "") {
    return Yunit._Expect(actualValue, message)
  }

  ;; Class Util
  Class Util {
    static IsNumber(var) {
      return this.isInteger(var) || this.isFloat(var)
    }

    static IsPureNumber(var) {
      return this.isPureInteger(var) || this.isPureFloat(var)
    }

    static IsInteger(var) {
      if IsInteger(var) {
        return true
      }
      return false
    }

    static IsPureInteger(var) {
      if var is integer {
        return true
      }
      return false
    }

    static IsFloat(var) {
      if IsFloat(var) {
        return true
      }
      return false
    }
    
    static IsPureFloat(var) {
      if var is float {
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
    * @param {any} value - variable to stringify
    * @param {boolean} usePureNumbers - no auto-conversion between
    *   string and integer (V1) or all numbers (V2)
    * @returns {string}
    */
    static Print(value, usePureNumbers := false) {

      if (!IsObject(value)) {
        return value
      }
  
      return this._stringify(value, usePureNumbers)
    }
  
    static _stringify(param_value, usePureNumbers) {
      if (!isObject(param_value)) {
        return '"' param_value '"'
      }
      
      output := ""
      iterator := (param_value is Array || param_value is Map) 
        ? param_value 
        : param_value.OwnProps()
  
      for key, value in iterator {
        if (param_value is Map && Type(key) = "String") {
          switch param_value.CaseSense {
            case "Off":
              key := toLowerCaseAscii(key)
            case "Locale":
              key := StrLower(key)
          }
        }
        output .= this._stringifyGenerate(key, value, usePureNumbers)
      }
      output := subStr(output, 1, -2)
      return output
      
      toLowerCaseAscii(str) {
        VarSetStrCapacity(&newStr, StrLen(str))
        Loop StrLen(str) {
          char := Substr(str, A_Index, 1)
          code := Ord(char)
          newStr .= (code >= 65 && code <= 90) ? Chr(code + 32) : char
        }
        return newStr
      }
    }
  
    static _stringifyGenerate(key, value, usePureNumbers) {
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
          output .= "[" . this._stringify(value, usePureNumbers) . "]"
        case !usePureNumbers && this.IsNumber(value):
            output .= value
        case usePureNumbers && this.IsPureNumber(value):
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
    * Retrieves the elapsed time in ms since the last call to QPCInterval()
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
        found := caseSense ? searchValue == value : searchValue = value
        if (found) {
          return true
        }
      }
      return false
    }
    
    /**
    * Joins elements of an array into a string, JavaScript like
    * @param {array} arr - Array to convert
    * @param {string} [sep:=","] - delimiter e.g. ','
    * @returns {string} separated list
    */
    static Join(arr, delimiter := ",") {
      joinedStr := ""
      for i, element in arr {
        joinedStr .= (i > 1 ? delimiter : "") element
      }
      return joinedStr
    }
  }

  ;; Class _ExpectBase
  Class _ExpectBase {

    /**
    * Meta function: routes method name to matcher
    * @param {string} methodName - method name of matcher
    * @param {any*} params - arguments passed to matcher
    * @returns {any} return value from matcher
    */
    __Call(methodName, params) {
      try {
        classMatcher := Yunit.Matchers.%methodName%
      } catch Error as e {
        Throw MethodError(format("The matcher '{1}' doesn't exist.", methodName))
      }
      matcher := classMatcher({message: this.message})
      ret := matcher.assert(this.actualValue, params*)
      if (!ret) {
        throw Yunit.AssertionError("Assertion error", -2, , matcher)
      }
      return ret
    }
  }

  ;; Class Expect
  Class _Expect extends Yunit._ExpectBase {

    __New(value, message := "") {
      this.actualValue := value
      this.message := message
    }
  }

  ;; Class AssertionError
  Class AssertionError extends Error {
    __New(message, what := -1, extra :="", matcher := "") {
      super.__New(message, what, extra)
      this.matcher := matcher
    }  
  }

  Class Matchers {
    ;; MatcherBase class
    Class MatcherBase {
      
      ; TODO: remove comment and fix tests with toContain matcher
      ; message := ""
      
      __New(options := "") {
        if (options.HasProp("message")) {
          this.message := options.message
        }
      }

      /**
      * Runs actual matcher
      * @abstract
      * @param {string} actual
      * @param {string} expected
      * @returns {boolean}
      */
      Assert(actual, expected) {
        this.actual := actual, this.expected := expected
      }

      /**
      * Returns the error output to print in the error details section
      * @virtual
      * @returns {string | string[]}
      */
      GetErrorOutput() {
        actual := this.formatActualTestValue(this.actual)
        expected := this.formatExpectedTestValue(this.expected)
        return format("Actual:   {1}`nExpected: {2}", actual, expected)
      }

      /**
      * Formats test value for output in actual/expected block
      * @param {string} type - "actual" or "expected"
      * @param {string} value
      * @returns {string}
      */
      formatTestValue(type, value) {
        newValue := value
        switch {
        case isObject(value):
          newValue := Yunit.Util.Print(value)
          if (!newValue) {
            newValue := "{}"
          }
        case Yunit.Util.IsFloat(value):
          newValue := Format("{1:.17g}", value)
        case Yunit.Util.GetType(value) = "String":
          textFormat := type = "actual" ? "{format.error}" : "{format.ok}"
          newValue := this.renderWhiteSpace(value, textFormat)
          newValue := '"' newValue '"'
        }
        return newValue
      }

      formatActualTestValue(value) {
        return this.formatTestValue("actual", value)
      }

      formatExpectedTestValue(value) {
        return this.formatTestValue("expected", value)
      }

      /**
      * Renders white space characters
      * @param {string} string
      * @param {string} textFormat - Ansi placeholder to set after
      * rendering whitespace
      * @returns {string}
      */
      renderWhiteSpace(string, textFormat) {
        if (!Yunit.options.outputRenderWhiteSpace) {
          return string
        }
        buffer := StrReplace(string, "`r`n", "{format.textDimmed}``r``n" textFormat)
        buffer := StrReplace(buffer, "`n", "{format.textDimmed}``n" textFormat)
        buffer := StrReplace(buffer, chr(27), "{format.textDimmed}``e" textFormat)

        return buffer
      }

      /**
      * Returns the names of additional expect matcher parameters
      * to be printed in the error details header
      * e.g. for expect(value).toBeCloseTo(expected, digits)
      *   => ["digits"]
      * @virtual
      * @returns {string[] | ""}
      */
      GetAdditionalExpectParams() {
        return ""
      }

      /**
      * Returns the text of a dynamic comment for the expect matcher
      * to be printed in the error details header
      * @abstract
      * @returns {string}
      */
      GetExpectComment() {
        return ""
      }

      /**
      * Returns the name of the matcher
      * @virtual
      * @returns {string}
      */
      GetMatcherType() {
        return StrSplit(this.__class, ".").Pop()
      }
    }

    ;; ToBe
    Class ToBe extends Yunit.Matchers.MatcherBase {

      Assert(actual, expected) {
        super.Assert(actual, expected)
        return this.hasPassedTest := (actual == expected)
      }
      
      GetExpectComment() {
        switch {
          case isObject(this.expected):
            return "compares object references"
          default:
            return "compares with =="
          }
        }
    }

    ;; toEql
    Class toEql extends Yunit.Matchers.MatcherBase {
      
      Assert(actual, expected) {
        super.Assert(actual, expected)
        if (isObject(actual)) {
          actual := Yunit.Util.Print(actual)
        }
        if (isObject(expected)) {
          expected := Yunit.Util.Print(expected)
        }
        return this.hasPassedTest := (actual == expected)
      }

      /**
      * Returns the text of a dynamic comment for the expect matcher
      * to be printed in the error details header
      * @override
      * @returns {string}
      */
      GetExpectComment() {
        switch {
          case isObject(this.expected):
            return "deep stringified equality, no type checking"
          default:
            return "compares with =="
        }
      }
    }

    ;; Class ToBeCloseTo
    Class ToBeCloseTo extends Yunit.Matchers.MatcherBase {
      
      assert(actual, expected, digits := 2) {
        this.actual := {value: actual, difference: Abs(expected - actual)}
        this.expected := {value: expected, digits: digits, difference: 10 ** -digits / 2}
        return this.hasPassedTest := this.actual.difference < this.expected.difference
      }

      getErrorOutput() {
        formatBlock :="
        (Ltrim
          Actual:   {1}
          Expected: {2}
        )"
        formatDetails := "
        (LTrim
          Actual difference:     {1}
          Expected difference: < {2:.$$f}
          Expected precision:    {3}
        )"
        expected := this.expected
        actual := this.actual
        
        output := []
        output.Push(format(formatBlock
          , this.formatActualTestValue(actual.value)
          , this.formatExpectedTestValue(expected.value)))

        formatDetails := StrReplace(formatDetails, "$$", expected.digits + 1)
        output.Push(format(formatDetails
          , this.formatActualTestValue(actual.difference)
          , expected.difference
          , expected.digits))
        return output
      }
      
      GetAdditionalExpectParams() {
        return ["precision"]
      }
    }
  }
}
