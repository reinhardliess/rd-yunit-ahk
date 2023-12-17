Class TestClass1 {
  Begin() {
    
  }
  
  BeforeEach() {
    
  }
  
}

Class TestClass2 {
  
  __New() {
    
  }

  Begin() {
    
  }
  
  Test_Passes() {
    Yunit.expect(5).toBe(5)
  }
  
  Test_Fails() {
    Yunit.expect(5).toBe(6)
  }
}
