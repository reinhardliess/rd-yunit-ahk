#Requires AutoHotkey v2.0-beta.1

class Yunit
{
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
    if (!WinExist("Yunit Testing ahk_class AutoHotkeyGUI")) {
      ExitApp
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
        case key is number:
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
        case value is number:
          output .= value
        default:
          output .= '"' . value . '"'
      }
  
      return output .= ", "
    }
  }
}
