SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%
#Include ../lib/unit-testing.ahk/export.ahk
#Include ../Yunit.ahk
#Include, ./TestClasses.ahk
#Include, ./TestOutput.ahk

global assert := new unittesting()

OnError("ShowError")

;; TODO: When converting to Yunit, think of meaningful test and variable names
; https://osherove.com/blog/2005/4/3/naming-standards-for-unit-tests.html

assert.group("Yunit class")
test_Yunit()

assert.group("Yunit.TestClass")
test_Yunit_TestClass()

assert.group("Yunit.Util class")
test_Yunit_Util()

assert.group("Yunit.AssertionError class")
test_AssertionError()

assert.group("Expect()")
test_Expect()

assert.group("Matchers")
test_Matchers()

; wrap up
assert.writeResultsToFile()
; assert.fullReport()
assert.sendReportToDebugConsole()
Exit % assert.failTotal

restoreYunitOptions() {
  Yunit.SetOptions({EnablePrivateProps: true, TimingWarningThreshold: 100}) 
}

test_Yunit() {
  
  ;; SetOptions
  restoreYunitOptions()
  Yunit.SetOptions({TimingWarningThreshold: 50})
  assert.test(Yunit.options, {EnablePrivateProps: true, TimingWarningThreshold: 50})
  
  ;; _validateHooks()
  assert.label("BeforeEach/AfterEach and Begin/End should be mutually exclusive")
  assert.false(Yunit._validateHooks(TestClass1))
  assert.true(Yunit._validateHooks(TestClass1_1))
  
  ;; _isTestMethod()
  restoreYunitOptions()
  assert.label("should check whether a method name is that of a test method")
  assert.false(Yunit._isTestMethod("Begin"))
  assert.false(Yunit._isTestMethod("BeforeEach"))
  assert.false(Yunit._isTestMethod("_helperMethod"))
  assert.true(Yunit._isTestMethod("Test_Division"))
  restoreYunitOptions()
  Yunit.SetOptions({EnablePrivateProps: false})
  assert.true(Yunit._isTestMethod("_Test_Addition"))
  
  ;; _isTestCategory()
  restoreYunitOptions()
  assert.label("should check whether a class name belongs to a test category")
  assert.false(Yunit._isTestCategory("MyClass._PrivateClass"))
  assert.true(Yunit._isTestCategory("Multiplication"))
  Yunit.SetOptions({EnablePrivateProps: false})
  assert.true(Yunit._isTestCategory("MyClass._Multiplication"))
}

filterOutputInfo(listInfo) {
  newList := []
  for _, value in listInfo {
    newList.push({category: (value.category), testMethod: (value.testMethod)})
  }
  return newList
}

test_Yunit_TestClass() {
  global test_listOutputInfo
  
  restoreYunitOptions()
  Yunit.Use(TestOutput).Test(TestClass2)
  
  assert.label("should throw the correct error type when using expect()")
  errType := Yunit.Util.GetType(test_listOutputInfo[1].result)
  assert.test(errType, "Yunit.AssertionError")
  
  assert.label("should retrieve timing information for tests")
  timeType := Yunit.Util.GetType(test_listOutputInfo[1].methodTime_ms)
  assert.test(timeType, "Float")
  
  assert.label("should execute all test methods")
  actual := filterOutputInfo(test_listOutputInfo)
  expected := [{category: "TestClass2", testMethod: "Test_Fails"}
    , {category: "TestClass2", testMethod: "Test_Passes"}
    , {category: "TestClass2.CategoryOne", testMethod: "Test1"}]
  assert.test(actual, expected)
}

test_Yunit_Util() {
  u := Yunit.Util
  assert.label("should determine the correct type for numbers")
  assert.true(u.isInteger(5))
  assert.true(u.isNumber(5))
  assert.true(u.isFloat(5.0))
  assert.true(u.isNumber(5.0))
  
  ;; GetType()
  assert.label("GetType() should return the correct variable type")
  assert.test(u.GetType(5), "Integer")
  assert.test(u.GetType(5.0), "Float")
  assert.test(u.GetType("green"), "String")
  assert.test(u.GetType({a:1}), "Object")
  assert.test(u.GetType(new TestClass1()), "TestClass1")
  assert.test(u.GetType(TestClass1), "Class")

  ;; IsArray()
  assert.label("IsArray() - true")
  assert.true(u.IsArray([]))
  assert.true(u.IsArray(["a", "b"]))
  assert.label("IsArray() - false")
  assert.false(u.IsArray(5))
  assert.false(u.IsArray({a: 1}))
  assert.false(u.IsArray({1a: 1}))
  
  ;; IsFunction()
  assert.label("IsFunction() should determine whether an object is callable")
  assert.true(u.IsFunction(Func("Substr")))
  assert.true(u.IsFunction(Func("Substr").bind()))
  assert.false(u.IsFunction("Substr"))
  
  ;; QPCInterval()
  assert.label("QueryPerformanceCounter is working")
  assert.test(u.GetType(u.QPCInterVal()), "Float")
  
  ;; Includes()
  strArray := ["a", "b", "c", "d"]
  numArray := [1, 2, 3, 4]
  assert.label("Includes() - true")
  assert.true(u.Includes(numArray, 1))
  assert.true(u.Includes(numArray, 4))
  assert.true(u.Includes(strArray, "a"))
  assert.true(u.Includes(strArray, "D"))
  assert.label("Includes() - false")
  assert.false(u.Includes(numArray, 5))
  assert.false(u.Includes(strArray, "f"))
  assert.false(u.Includes(strArray, "D", true))
  assert.toThrow(ObjBindMethod(u, "includes", strArray, {a: 1}))
  
  ;; Print()
  assert.label("Print() should stringify the contents of a variable correctly")
  assert.test(u.Print(33), 33)
  assert.test(u.Print([1, 2, 3]), "1:1, 2:2, 3:3")
  
  actualValue := {name: "Zoe", age: 20, address: { street: "Jardin des Roses"} }
  expected =  
  ( ltrim
    "address":["street":"Jardin des Roses"], "age":20, "name":"Zoe"
  )
  assert.test(u.Print(actualValue), expected)
  
  actualValue := [{type: 1, value: "abc"}, {type: 2, value: "def"}]
  expected = 
  ( ltrim
  1:["type":1, "value":"abc"], 2:["type":2, "value":"def"]
  )
  assert.test(u.Print(actualValue), expected)
  assert.test(u.Print({ a: 1, fn: Func("Instr")}), """a"":1")
  
}

test_AssertionError() {
  assert.label("should create an assertion error with all necessary properties")
  err := new Yunit.AssertionError("message", "what", "extra", {hasPassedTest: false})
  
  assert.test(err.message, "message")
  assert.test(err.what, "what")
  assert.test(err.extra, "extra")
  assert.test(err.matcherInfo, {hasPassedTest: false})
}

expectAssertionError() {
  Yunit.expect(5, "message").toBe(6)
}

expectWrongMatcher() {
  Yunit.expect(0).toBeZero()
}

test_Expect() {
  assert.label("if the expectation fails, 'expect' should throw a Yunit.AssertionError")
  err := assert.toThrow(func("expectAssertionError"), Yunit.AssertionError)
  
  assert.label("if the expectation fails, the error object should contain the correct matchinfo object")
  assert.test(err.matcherInfo, {actual: 5, expected: 6, hasPassedTest: 0, matcherType: "toBe", message: "message"})
  
  assert.label("if a matcher is used that doesn't exist, 'expect' should throw an error")
  assert.toThrow(func("expectWrongMatcher"))
}

test_Matchers() {
  static m := Yunit.Matchers
  obj1 := {a: 1}, obj2 := {a: 1}, objref := obj1
  
  ;; ToBe
  assert.label("ToBe")
  assert.test(m.ToBe(5, 5), {actual: 5, expected: 5, hasPassedTest: 1})
  assert.test(m.ToBe(5, 6), {actual: 5, expected: 6, hasPassedTest: 0})
  assert.test(m.ToBe("abc", "abc"), {actual: "abc", expected: "abc", hasPassedTest: 1})
  assert.test(m.ToBe("abc", "Abc"), {actual: "abc", expected: "Abc", hasPassedTest: 0})
  assert.test(m.ToBe(obj1, objref), {actual: (obj1), expected: (objref), hasPassedTest: 1})
  assert.test(m.ToBe(obj1, obj2), {actual: (obj1), expected: (obj2) , hasPassedTest: 0})
  
  ;; ToEqual
  assert.label("ToEqual")
  assert.test(m.ToEqual(5, 5), {actual: 5, expected: 5, hasPassedTest: 1})
  assert.test(m.ToEqual(5, 6), {actual: 5, expected: 6, hasPassedTest: 0})
  assert.test(m.ToEqual("abc", "abc"), {actual: "abc", expected: "abc", hasPassedTest: 1})
  assert.test(m.ToEqual("abc", "Abc"), {actual: "abc", expected: "Abc", hasPassedTest: 0})
  assert.test(m.ToEqual(obj1, obj2), {actual: """a"":1", expected: """a"":1", hasPassedTest: 1})
  assert.test(m.ToEqual(obj1, {a: 2}), {actual: """a"":1", expected: """a"":2", hasPassedTest: 0})
  
  ;; ToBeCloseTo
  assert.label("ToBeCloseTo")
  value := "0.300000000000000"
  assert.test(m.ToBeCloseTo(0.1 + 0.2, 0.3, 15), {actual: (value), expected: (value), hasPassedTest: 1})
}

ShowError(exception) {
  OutputDebug % ("Error in " exception.file ":" exception.Line "`n" exception.Message " (" A_LastError ")" exception.extra  "`n")
  return true
}
