
#Include %A_ScriptDir%
#Include "../lib/unit-testing.ahk/export.ahk"
#Include "../Yunit.ahk"

global assert := unittesting()

assert.group("Yunit.Util class")
test_Yunit_Util()

assert.group("Expect() matchers")
test_Expect()

; wrap up
assert.writeResultsToFile()
; assert.fullReport()
assert.sendReportToDebugConsole()
Exit(assert.failTotal)

Class TestClass {
  
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

test_Expect() {
  
  Yunit.expect(5).toBe(6)
  Yunit.expect(5).toBe(5)
  ; ret := Yunit.expect(5).toBeZero()
}
