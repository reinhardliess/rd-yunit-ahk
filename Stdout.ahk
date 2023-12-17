class YunitStdOut
{
  Update(objOutputInfo) ;wip: this only supports one level of nesting?
  {
    Category := objOutputInfo.category
    , Test := objOutputInfo.testMethod
    , Result := objOutputInfo.result
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