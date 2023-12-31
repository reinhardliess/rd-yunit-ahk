Class TestClass1 {
  Begin() {
    
  }
  
  BeforeEach() {
    
  }
  
}

Class TestClass1_1 {
  
  BeforeEach() {
    
  }
  
}

Class TestClass2 {
  
  __New() {
    ; OutputDebug, % A_ThisFunc
  }

  __Delete() {
    ; OutputDebug, % A_ThisFunc
  }
  
  beforeEach() {
    ; OutputDebug, % A_ThisFunc
  }

  afterEach() {
    ; OutputDebug, % A_ThisFunc
  }
  
  Test_Passes() {
    Yunit.expect(5).toBe(5)
  }
  
  Test_Fails() {
    Yunit.expect(5).toBe(6)
  }
  
  Class CategoryOne {
    Test1() {
      
    }
  }
  Class _PrivateClass {
    Test2() {
      
    }
  }
}
