#Requires AutoHotkey v2.0

Class unittesting {

	__New() {
		this.testTotal := 0
		this.failTotal := 0
		this.successTotal := 0

		this.log := []

		this.groupVar := ""
		this.labelVar := ""
		this.lastlabel := ""

		this.logresult_dir := A_ScriptDir "\result.tests.log"
	}

	test(param_actual := "_Missing_Parameter_", param_expected := "_Missing_Parameter_") {
		if (A_IsCompiled) {
			return 0
		}

		; prepare
		if (IsObject(param_actual)) {
			param_actual := this._print(param_actual)
		}
		if (IsObject(param_expected)) {
			param_expected := this._print(param_expected)
		}

		; create
		this.testTotal++
		if (param_actual !== param_expected) {
			this._logTestFail(param_actual, param_expected)
			return false
		} else {
			this.successTotal++
			return true

		}
	}

	_logTestFail(param_actual, param_expected, param_msg := "") {
		if (A_IsCompiled) {
			return 0
		}

		; create
		this.failTotal++
		if (this.labelVar !== this.lastlabel) {
			this.lastlabel := this.labelVar
			if (this.groupVar) {
				this.log.push("`n== " this.groupVar " - " this.labelVar " ==`n")
			} else {
				this.log.push("`n== " this.labelVar " ==`n")
			}
		}
		this.log.push("Test Number: " this.testTotal "`n")
		this.log.push("Expected: " param_expected "`n")
		this.log.push("Actual:   " param_actual "`n")
		if (param_msg != "") {
			this.log.push(param_msg "`n")
		}
		this.log.push("`n")
	}

	true(param_actual := "_Missing_Parameter_") {
		if (A_IsCompiled) {
			return 0
		}

		; create
		if (param_actual == true) {
			this.test("true", "true")
			return true
		}
		if (param_actual == false) {
			this.test("false", "true")
			return false
		}
		this.test(param_actual, "true")
		return false
	}

	false(param_actual := "_Missing_Parameter_") {
		if (A_IsCompiled) {
			return 0
		}

		; create
		if (param_actual == false) {
			this.test("false", "false")
			return true
		}
		if (param_actual == true) {
			this.test("true", "false")
			return false
		}
		this.test(param_actual, "true")
		return false
	}

	equal(param_actual := "_Missing_Parameter_", param_expected := "_Missing_Parameter_") {
		if (A_IsCompiled) {
			return 0
		}

		; create
		return this.test(param_actual, param_expected)
	}

	notEqual(param_actual := "_Missing_Parameter_", param_expected := "_Missing_Parameter_") {
		if (A_IsCompiled) {
			return 0
		}

		; prepare
		param_actual := this._print(param_actual)
		param_expected := this._print(param_expected)

		; create
		this.testTotal += 1
		if (param_actual !== param_expected) {
			this.successTotal++
			return true
		} else {
			this._logTestFail(param_actual, param_expected, "They were Expected to be DIFFERENT")

			return false
		}
	}

	/**
	  * Matcher: expects function to throw error
	  * @param {function} param_function - function to check
	  * @param {object} [param_errType] - error class object
	  * @returns {boolean}
	  */
	toThrow(param_function, param_errType:="") {
		if (param_errType && !isObject(param_errType)) {
			throw TypeError("TypeError: Didn't receive object for param_errType",, param_errType)
		}

		hasPassedTest := false
		actual := "Didn't throw error"
		expected := "Should throw error"
		this.testTotal += 1

		try {
			param_function.call()
		} catch Any as err {
			hasPassedTest := true
			if (param_errType) {
				ret := this._toThrowCheckErrorClass(err, param_errType)
				hasPassedTest := ret.hasPassedTest, actual := ret.actual, expected := ret.expected
			}
		}

		if (hasPassedTest) {
			this.successTotal++
			return err
		} else {
			this._logTestFail(actual, expected)
			return false
		}
	}

	/**
	  * Checks whether actual error matches expected error
	  * @param {object} actualError
	  * @param {object} expectedError
	  * @returns {object} { hasPassedTest: boolean, actual: string, expected: string}
	  */
	_toThrowCheckErrorClass(actualError, expectedError) {
		hasPassedTest := true
		actualErrType   := Type(actualError)
		expectedErrType := Type(expectedError)
		if (expectedErrType = "Class") {
			expectedErrType := expectedError.Prototype.__Class 
		}
		actual := expected := ""
		if (actualErrType != expectedErrType) {
			hasPassedTest := false
			expected := format("Should throw '{1}'", expectedErrType)
			actual   := format("Threw '{1}'", actualErrType)
		}
	return {hasPassedTest: hasPassedTest, actual: actual, expected: expected}
}

	label(param) {
		if (A_IsCompiled) {
			return 0
		}

		this.labelVar := param
		return
	}

	group(param) {
		if (A_IsCompiled) {
			return 0
		}

		this.groupVar := param
		this.labelVar := ""
		this.lastlabel := "_"
		return
	}

	report() {
		if (A_IsCompiled) {
			return 0
		}

		MsgBox(this._buildReport())
		return true
	}

	fullReport() {
		if (A_IsCompiled) {
			return 0
		}

		msgReport := this._buildReport()
		if (this.failTotal > 0) {
			msgReport .= "`n=================================`n"
		}
		Loop this.log.Length {
			msgReport .= this.log[A_Index]
		}

		; choose the msgbox icon
		if (this.failTotal > 0) {
			l_options := 48
		} else {
			l_options := 64
		}
		this._stdOut(msgReport)
		MsgBox(msgReport, "unit-testing.ahk", l_options)
		return msgReport
	}

	writeResultsToFile(param_filepath := "", openFile := 0) {
		if (A_IsCompiled) {
			return 0
		}

		; prepare
		if (param_filepath != "") {
			logpath := param_filepath
		} else {
			logpath := this.logresult_dir
		}

		; create
		try {
			FileDelete(logpath)
		} catch {
			; do nothing
		}

		msgReport := this._buildReport()
		FileAppend(msgReport "`n`n", logpath)
		for key, value in this.log {
			FileAppend(value, logpath)
		}
		if (openFile) {
			Run(logpath)
		}
		return true
	}

	sendReportToDebugConsole() {
		if (A_IsCompiled) {
			return 0
		}

		msgReport := this._buildReport() . "`n"
		for _, value in this.log {
			msgReport .= value
		}
		OutputDebug(Rtrim(msgReport, "`r`n"))
	}

	; Internal functions
	_buildReport() {
		if (A_IsCompiled) {
			return 0
		}

		; create
		this.percentsuccess := floor((this.successTotal / this.testTotal) * 100)
		returntext := this.testTotal " tests completed with " this.percentsuccess "% success (" this.failTotal " failures)"
		if (this.failTotal = 1) {
			returntext := StrReplace(returntext, "failures", "failure")
		}
		if (this.testTotal = 1) {
			returntext := StrReplace(returntext, "tests", "test")
		}
		return returntext
	}

	_print(value) {

		if (!IsObject(value)) {
			return value
		}

		return this._stringify(value)
	}

	_stringify(param_value) {
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

	_stringifyGenerate(key, value) {
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

	_stdOut(output := "") {
		try {
			DllCall("AttachConsole", "int", -1) || DllCall("AllocConsole")
			FileAppend(output "`n", "CONOUT$")
			DllCall("FreeConsole")
		} catch error {
			return false
		}
		return true
	}
}
