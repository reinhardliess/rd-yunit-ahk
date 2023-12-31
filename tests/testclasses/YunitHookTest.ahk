Class YunitHookTest {
  
  var1 := 0
  
  Class _TestHooks {
    
    var1 := 0
    
    _beforeEach() {
      this.var1 := 1
    }
    
    Class Nested1 {
      
    }
    
  }
  
  _beforeEachAll(thisArg) {
    thisArg.var1 := 1
  }
  
  beforeEach() {
    ; OutputDebug, % A_ThisFunc
  }
  
  afterEach() {
    ; OutputDebug, % A_ThisFunc
  }
  
  executes_a_hook() {
    obj := new YunitHookTest._TestHooks()
    
    Yunit.expect(obj.var1).toBe(0)
    Yunit.executeHook(YunitHookTest._TestHooks, "_beforeEach", obj)
    Yunit.expect(obj.var1).toBe(1)
  }
  
  executes_a_global_hook_in_top_level_class() {
    obj := new YunitHookTest()
    
    Yunit.expect(this.var1).toBe(0)
    Yunit.executeGlobalHook(YunitHookTest, "_beforeEachAll", obj)
    Yunit.expect(obj.var1).toBe(1)
  }
  
  executes_a_global_hook_in_nested_class() {
    obj := new YunitHookTest._TestHooks()
    
    Yunit.expect(this.var1).toBe(0)
    Yunit.executeGlobalHook(YunitHookTest._TestHooks, "_beforeEachAll", obj)
    Yunit.expect(obj.var1).toBe(1)
  }
  
}