
#Include %A_ScriptDir%
#Include "../lib/unit-testing.ahk/export.ahk"
#Include "../Yunit.ahk"

global assert := unittesting()

assert.group("Yunit class")
test_Yunit()

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
Exit(assert.failTotal)

Class TestClass {
  
}

test_Yunit() {
  
  ;; SetOptions
  oldOptions := Yunit.options
  Yunit.options := {EnablePrivateProps: true, TimingWarningThreshold: 100}
  Yunit.SetOptions({TimingWarningThreshold: 50})
  assert.test(Yunit.options, {EnablePrivateProps: true, TimingWarningThreshold: 50})
  Yunit.options := oldOptions
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
  assert.test(u.GetType(TestClass()), "TestClass")
  assert.test(u.GetType(TestClass), "Class")

  ;; IsFunction()
  assert.label("IsFunction() should determine whether an object is callable")
  assert.true(u.IsFunction(Substr))
  assert.true(u.IsFunction(Substr.bind()))
  assert.false(u.IsFunction("Substr"))
  
  ;; QPCInterval()
  assert.label("QueryPerformanceCounter is working")
  assert.test(u.GetType(u.QPCInterval()), "Float")
  
  ;; Print()
  assert.label("Print() should stringify the contents of a variable correctly")
  assert.test(u.Print(33), 33)
  assert.test(u.Print([1, 2, 3]), "1:1, 2:2, 3:3")
  
  actualValue := {name: "Zoe", age: 20, address: { street: "Jardin des Roses"} }
  expected := "  
  ( ltrim
  "address":["street":"Jardin des Roses"], "age":20, "name":"Zoe"
  )"
  assert.test(u.Print(actualValue), expected)
  
  actualValue := [{type: 1, value: "abc"}, {type: 2, value: "def"}]
  expected := " 
  ( ltrim
  1:["type":1, "value":"abc"], 2:["type":2, "value":"def"]
  )"
  assert.test(u.Print(actualValue), expected)
  assert.test(u.Print({ a: 1, fn: Instr}), '"a":1')
  
}

test_AssertionError() {
  assert.label("should create an assertion error with all necessary properties")
  err := Yunit.AssertionError("message", "what", "extra", {hasPassedTest: false})
  
  assert.test(err.message, "message")
  assert.test(err.what, "what")
  assert.test(err.extra, "extra")
  assert.test(err.matcherInfo, {hasPassedTest: false})
}

expectAssertionError() {
  Yunit.expect(5).toBe(6)
}

expectWrongMatcher() {
  Yunit.expect(0).toBeZero()
}

test_Expect() {
  assert.label("if the expectation fails, expect should throw a Yunit.AssertionError")
  err := assert.toThrow(expectAssertionError, Yunit.AssertionError)
  
  assert.label("if the expectation fails, the error object should contain the correct matchinfo object")
  assert.test(err.matcherInfo, {actual: 5, expected: 6, hasPassedTest: 0, matcherType: "toBe"})
  
  assert.label("if a matcher is used, that doesn't exist, expect should throw an error")
  assert.toThrow(expectWrongMatcher, MethodError)
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
  assert.test(m.ToEqual(obj1, obj2), {actual: '"a":1', expected: '"a":1', hasPassedTest: 1})
  assert.test(m.ToEqual(obj1, {a: 2}), {actual: '"a":1', expected: '"a":2', hasPassedTest: 0})
  
  ;; ToBeCloseTo
  value := "0.300000000000000"
  assert.test(m.ToBeCloseTo(0.1 + 0.2, 0.3, 15), {actual: value, expected: value, hasPassedTest: 1})
}