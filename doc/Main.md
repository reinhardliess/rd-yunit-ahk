# Yunit

Super simple testing framework for AutoHotkey.

Yunit is designed to aid in the following tasks:

- Automated code testing.
- Automated benchmarking.
- Basic result reporting and collation.
- Test management.

## Stuff to Add

- reword certain paragraphs (ChatGPT, DeepL)
- backwards compatibility
- New examples
- Yunit testing itself = examples

## Example

See [doc/Example.ahk](Example.ahk) for a working example script that demonstrates Yunit being used for testing.

A basic test setup looks like the following:

```autohotkey
Yunit.Use(YunitStdout).Test(TestSuite)
    
class TestSuite
{
  SomeTest()
  {
    Yunit.expect(5).toBe(4) ; fails
  }
}
```

## Installation

Installation is simply a matter of adding the Yunit folder to the library path of your project.

An example directory structure is shown below:

    + SomeProject
    |    + Lib
    |    |    + Yunit
    |    |    |    LICENSE.txt
    |    |    |    README.md
    |    |    |    ...
    |    |    + OtherLibrary
    |    |    |    ...
    |    README.md
    |    SomeProject.ahk
    |    ...

In AutoHotkey, library locations are checked as follows:

1. Local library: %A_ScriptDir%\Lib\
2. User library: %A_MyDocuments%\Lib\
3. Standard library: %A_AhkPath%\Lib\

## Importing

Yunit and its modules must be imported to be used:

```autohotkey
#Include <Yunit\Yunit>             ; import the basic test routines (mandatory)
#Include <Yunit\ConsoleOutputBase> ; mandatory for Stdout/StdoutMin output modules
#Include <Yunit\Stdout>            ; import the Stdout output module (optional)
#Include <Yunit\StdoutMin>         ; import the StdoutMin output module (optional)
#Include <Yunit\OutputDebug>       ; import the OutputDebug output module (optional)
#Include <Yunit\Window>            ; import the window output module (optional)
#Include <Yunit\JUnit>             ; import the JUnit output module (optional)
```

Output modules only need to be imported if they are going to be used.

## Usage

Yunit is implemented as a class, conveniently named `Yunit`.
This class is static, which basically means you do not need to make a new instance of `Yunit` it to use it.

To begin, first we need to select the output modules to use (a list of available modules is documented in the *Modules* section below).
In other words, where the results of the tests should go.

This is done using the `Yunit.Use(Modules*)` method, where `Modules*` represents zero or more modules to use.
When called, the method returns a `Yunit.Tester` object, which represents the options and settings for a group of tests:

```autohotkey
Tester := Yunit.Use(YunitStdout, YunitWindow)
```

This code creates a `Yunit.Tester` object that uses the `YunitStdout` and `YunitWindow` modules for output.

Now that the `Yunit.Tester` object has been created, we can run a set of tests against it.
This is done using the `Yunit.Tester.Test(Classes*)` method, where `Classes*` represents zero or more test classes to use (the format is documented in the *Tests* section below).
When called, the method starts the tests and manages the results:

    Tester.Test(FirstTestSet, SecondTestSet, ThirdTestSet)

This code runs all tests in all three sets.

This method is synchronous and blocks the current thread until complete.
Results will be shown while the method is running.

Instead of using the two lines above, it may be preferable to simply chain them together:

```autohotkey
Yunit.Use(YunitStdout, YunitWindow).Test(FirstTestSet, SecondTestSet, ThirdTestSet)
```

## Configuration Settings

```autohotkey
Yunit.SetOptions({TimingWarningThreshold: 20})
Yunit.RestoreOptions()
```



| Key                                                       | Default | Options          | Applies to        | Description                                                  |
| --------------------------------------------------------- | ------- | ---------------- | ----------------- | ------------------------------------------------------------ |
| EnablePrivateProps                                        | true    |                  | globally          | Enable private methods and classes with a `_` prefix, e.g. `_testFoo()` or `_UtilityClass {}` |
| TimingWarningThreshold, rename to OutputSlowTestThreshold | 100     |                  | Stdout, StdoutMin | Set threshold in milliseconds for slow tests                 |
| OutputRenderWhitespace                                    | false   |                  | Stdout, StdoutMin | Print strings on one line, displaying whitespace characters in grey: cr/lf, esc, tab |
| *OutputNameFormat                                         | “keep”  | “keep”, “pretty” | Stdout, StdoutMin | • keep: no changes <br />• pretty: Convert `_` to spaces in output, capitalize name |
| *OutputHighlightChanges                                   | false   |                  | Stdout, StdoutMin | Prints first change inverted for strings, printed objects    |

## Test Suites and Categories

Test suites are written as classes. Class methods are considered tests; nested classes are considered categories.
Classes nested within these nested classes are considered subcategories, and so on:

```autohotkey
class TestSuite
{
  This_Is_A_Test()
  {
    ;...
  }

  class This_Is_A_Category
  {
    This_Is_A_Test()
    {
      ;...
    }
    
    This_Is_Another_Test()
    {
      ;...
    }
  }
}
```

The above corresponds to the following test structure:

    TestSuite:
      This_Is_A_Test
      This_Is_A_Category:
        This_Is_A_Test
        This_Is_Another_Test

The test and category names are determined from their identifiers in the code. Test and category names may be duplicated as long as they are in different categories.

The order in which tests are called is arbitrary.

## Output Modules

- Update all output modules to keep backwards compatibility while enabling new features

Multiple output modules are available:

### YunitStdout

```autohotkey
Tester := Yunit.Use(YunitStdout)
```

#### Configuring Stdout

This module writes the test results to the standard output. To see the output, use one of the following methods.

1. [vscode-autohotkey-debug](https://marketplace.visualstudio.com/items?itemName=zero-plusplus.vscode-autohotkey-debug) is probably the best debugger available for Autohotkey, it also shows `stdout` output in the debug console

2. PowerShell: [Correct](https://www.reddit.com/r/rust/comments/we4y3p/why_utf8_characters_get_broken_when_piped_in/) UTF-8 piping requires PowerShell Core 7.x. It’s necessary to add the following line to the PowerShell profile (or to the script running the tests):

    ```powershell
    $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
    ```

    Tests can then be run by typing:

    ```powershell
    # V1
    & "$env:programfiles\AutoHotkey\AutoHotkey.exe" 'tests.ahk' | Write-Host
    # v2
    & "$env:programfiles\AutoHotkey\V2\AutoHotkey.exe" 'tests.ahk' | Write-Host
    ```
    
    

Theoretically it's also possible to use `cmd.exe`, but UTF-8 characters will be broken, so it's not recommended

#### Output Format

The first block of results is formatted in a hierarchical way, with the tests grouped by category (nested classes).

The second block displays any slow tests.

The third block displays the failed tests in detail including the filename formatted as `filename:line` so it becomes clickable in a code editor like VS Code.

### YunitStdoutMin

```autohotkey
Tester := Yunit.Use(YunitStdoutMin)
```

This output module behaves just like the Stdout module, but it only prints test that have failed and slow tests.

### YunitOutputDebug

    Tester := Yunit.Use(YunitOutputDebug)

This module writes the test results via OutputDebug. To see the output, see how to use [OutputDebug](https://autohotkey.com/docs/commands/OutputDebug.htm)

The results are formatted one per line, each entry being in the following form:

    (Counter) Result: Category.TestName Data

- *Counter* - Number of the performed test
- *Result* - result of the test ("PASS" or "FAIL").
- *Category* - category or categories that the test is located under, with subcategories separated by dots (Category.Subcategory.OtherCategory).
- *TestName* - name of the test being run.
- *Data* - data given by the test, such as specific error messages or benchmark numbers.

### YunitJUnit

    Tester := Yunit.Use(YunitJUnit)

This module writes the test results  JUnit compatible XML-Output. The XML-File is generated in the *directory where the Test-script* resides and
has the name *junit.xml*.

The JUnit format is commonly used on Continuous-Integration servers (like [Jenkins](https://jenkins.io/))

See [here for more information on the JUnit-format](https://pzolee.blogs.balabit.com/2012/11/jenkins-vs-junit-xml-format/)

### YunitWindow

    Tester := Yunit.Use(YunitWindow)

This module displays the test results in a window with icons showing the status of each test.

The results are shown in the form of a tree control, with each test suite having a top level node, and categories or tests having child nodes.

Beside each node is an icon:

- *Green up arrow* - test passed successfully.
- *Yellow triangle with exclamation mark* - test failed.
- *Two papers* - test result/description.

Tests that result in data will have an additional child node that can be expanded to show it.

## Writing Tests

### Using Matchers

A test is a class method that takes no arguments and has no return value.

Yunit uses "matchers" to let you test values in different ways.

The `expect` function is used every time you want to test a value. You will rarely call `expect` by itself. Instead, you will use `expect` along with a "matcher" function to assert something about a value.

```autohotkey
Yunit.Expect(value, message?).matcher(params*)
```

#### Parameters

| Name     | Type   | Description                                      |
| -------- | ------ | ------------------------------------------------ |
| value    | any    | The value to test                                |
| message? | string | Optional message to print if the assertion fails |

```autohotkey
This_Is_A_Test()
{
   Yunit.Expect(1).toBe(1) ; test passes
}
```

### Matchers

#### toBe

- Same as `.toEql` for numbers and strings
- Compares object references whereas `toEql` checks stringified deep equality

#### toBeCloseTo

Use `toBeCloseTo` to compare floating point numbers for approximate equality.

#### toEql

For primitive types, `toEql` behaves like `toBe`, but it compares objects by deep stringified equality

##### Limitations

- Ignores object properties with callable objects
- Ignores object references as keys in maps (V2)

#### toMatch

- RegexMatch wrapper
- returns object

#### toThrow

Use `.toThrow` to test that a function throwing an error/exception when it is called.

- Must be a function object, in V2 also a lambda expression
- V2: tests for instance of expected error

### Hooks

Often while writing tests you have some setup work that needs to happen before tests run, and you have some finishing work that needs to happen after tests run. Jest provides helper functions to handle this.

| Name                        | Arguments | Description                                                  |
| --------------------------- | --------- | ------------------------------------------------------------ |
| BeforeEach, AfterEach       |           | Will be called on the instance of the class before and after *each test*, respectively. |
| Begin, End                  |           | Same as above, kept for compatibility with original Yunit library |
| BeforeEachAll, AfterEachAll | thisArg   | Similar to BeforeEach, but will be called in the top level class and all nested classes. It must be declared in the top level class, and in V2, it must be declared `static` |
| \_\_New, \_\_Delete         |           | Will be called before testing starts on a category and after it finishes, respectively |

