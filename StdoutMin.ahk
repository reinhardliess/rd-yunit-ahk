class YunitStdOutMin
{
  Update(objOutputInfo) ;wip: this only supports one level of nesting?
  {
    category := objOutputInfo.category
    , test := objOutputInfo.testMethod
    , result := objOutputInfo.result
    , methodTime_ms := objOutputInfo.methodTime_ms
    
    if IsObject(Result)
    {
      Details := " at line " Result.Line " " Result.Message "(" Result.File ")"
      Status := "FAIL"
    }
    else
    {
      Details := ""
      Status := "PASS"
    }
    FileAppend, %Status%: %Category%.%Test% %Details%`n, *
  }
}