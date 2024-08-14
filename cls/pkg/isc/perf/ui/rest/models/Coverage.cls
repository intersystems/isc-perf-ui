Include %occInclude

Class pkg.isc.perf.ui.rest.models.Coverage Extends (%RegisteredObject, %pkg.isc.rest.model.resource)
{

Parameter RESOURCENAME = "coverage";

XData ActionMap [ XMLNamespace = "http://www.intersystems.com/apps/rest/action" ]
{
<actions> 
<action name="start" target="class" call="StartTesting" method="POST"> 
    <argument target="pConfig" name="config" required="true" source="body" />
</action> 
<action name="results" target="class" call="GetResults" method="GET">
    <argument target="routine" name="routine" source="query" required="true" />
    <argument target="testpath" name="testpath" source="query"  required="true"/>
    <argument target="RunID" name="RunID" source="query"  required="true"/>
</action>
<action name="routinepaths" target="class" call="GetRoutinePaths" method="GET">
<argument target="RunID" name="RunID" source="query"  required="true"/>
</action> 
<action name="tabular" target="class" call="GetTabularData" method="GET">
<argument target="RunID" name="RunID" source="query"  required="true"/>
</action> 
<action name="RunIDs" target="class" call="GetRunIDs" method="GET"></action>
<action name="clear" target="class" call="ClearResults" method="POST"></action>
<action name="active" target="class" call="CheckActive" method="GET"></action>
</actions>
}

/// Jobs off the call to RunTest with the user inputted parameters
ClassMethod StartTesting(pConfig As pkg.isc.perf.ui.rest.models.CoverageConfig) As pkg.isc.perf.ui.rest.models.CoverageStatus
{
    Set tUnitTestRoot = $ZSTRIP(pConfig.UnitTestRoot, "<>W")
    // Validate UnitTestRoot
    If tUnitTestRoot'= "" {
        Set pathRegex = "^(?:[a-zA-Z]:(?:\\|\/)|\/)?(?:[\w\s.-]+(?:\\|\/))*([\w\s.-]+(?:\\|\/))?\s*$"
        If '$match(pConfig.UnitTestRoot, pathRegex) {
            Set tMsg = "Invalid file path for UnitTestRoot."
            $$$ThrowStatus($$$ERROR($$$GeneralError, tMsg))
        }
    }
    set tCoverageClasses = $zstrip(pConfig.CoverageClasses, "*W")
    // Validate CoverageClasses
    If tCoverageClasses '= "" {
        Set classesRegex = "^(\s*[\w.]+(?<!\.cls)\s*,)*\s*[\w.]+(?<!\.cls)\s*$"
        If '$match(pConfig.CoverageClasses, classesRegex) {
            Set tMsg = "Invalid CoverageClasses format. Must be a comma-separated list not ending in .cls."
            $$$ThrowStatus($$$ERROR($$$GeneralError, tMsg))
        }
    }

    set tCoverageRoutines = $zstrip(pConfig.CoverageRoutines, "*W")
    // Validate CoverageRoutines
    If tCoverageRoutines '= "" {
        Set routinesRegex = "^(\s*[\w.]+(?<!\.mac)\s*,)*\s*[\w.]+(?<!\.mac)\s*$"
        If '$match(pConfig.CoverageRoutines, routinesRegex) {
            Set tMsg = "Invalid CoverageRoutines format. Must be a comma-separated list not ending in .mac."
            $$$ThrowStatus($$$ERROR($$$GeneralError, tMsg))
        }
    }
    set tProcessIDs = $zstrip(pConfig.PidList, "*W")
    // Validate PidList
    If tProcessIDs '= "" {
        Set pidRegex = "^(Interop|[0-9]+)(\s*,\s*[0-9]+)*\s*$"
        If '$match(pConfig.PidList, pidRegex) {
            Set tMsg = "Invalid PidList format. Must start with Interop or be a comma-separated list of numbers."
            $$$ThrowStatus($$$ERROR($$$GeneralError, tMsg))
        }
    }
    Kill tCoverageParams
    set tTiming = pConfig.Timing
    set tCoverageClasses = $LISTFROMSTRING(tCoverageClasses)
    set tCoverageRoutines = $LISTFROMSTRING(tCoverageRoutines)
    set tProcessIDs = $LISTFROMSTRING(tProcessIDs)
    set tCoverageDetail = pConfig.CoverageLevel
    Job ..CoverageCall(tUnitTestRoot, tTiming, tCoverageClasses, tCoverageRoutines, tProcessIDs, tCoverageDetail)
    // the status doesn't actually get used, just has to be a JSON format
    quit ##class(pkg.isc.perf.ui.rest.models.CoverageStatus).%New()
}

/// Runs TestCoverage's RunTest in the background, live broadcasting progress to UI 
ClassMethod CoverageCall(pUnitTestRoot As %String, pTiming As %String, pCoverageClasses As %List, pCoverageRoutines As %List, pProcessIDs As %List, pCoverageDetail As %String) As %Status
{
    set tSC = $$$OK
    try {
        // set the TestCoverage parameters based on user input
        kill tCoverageParams
        set tCoverageParams("Timing") = pTiming
        set tCoverageParams("CoverageClasses") = pCoverageClasses
        set tCoverageParams("CoverageRoutines") = pCoverageRoutines
        set tCoverageParams("ProcessIDs") = pProcessIDs
        set tCoverageParams("CoverageDetail") = pCoverageDetail
        
        // create our listener instances in order to broadcast unit test progress to UI
        set tListenerManager = ##class(TestCoverage.Listeners.ListenerManager).%New()
        do tListenerManager.AddListener(##class(pkg.isc.perf.ui.socket.Listener).%New())
        set tCoverageParams("ListenerManager") = tListenerManager

        set ^UnitTestRoot = pUnitTestRoot
        
        // suppress output
        set buffer = ##class(%pkg.isc.json.util.buffer).%New()
        do buffer.BeginCaptureOutput()
        $$$ThrowOnError(##class(TestCoverage.Manager).RunTest(,"/nodelete",.tCoverageParams)) 
        set stream = ##class(%Stream.TmpCharacter).%New()
        do buffer.EndCaptureOutput(.stream)

        // figure out which run id this went into
        &sql(SELECT MAX(ID) INTO :tRunID FROM TestCoverage_Data.Run)
        If (SQLCODE < 0) {
            Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,%msg)
        }

        // divider at the end of the logs
        set msg = {"type": "TestCoverageOutput", "message": "========================="}
        do ##class(pkg.isc.perf.ui.socket.WebSocket).BroadCast(msg)

        // broadcast that we finished so that CoverageResultsDisplay knows to GetRoutinePaths
        set msg = {"message": "Finished RunTest", "type": "RunTestFinish"}
        do msg.%Set("RunID", tRunID)
        do ##class(pkg.isc.perf.ui.socket.WebSocket).BroadCast(msg)
        
    } catch e {
        Set tSC = e.AsStatus()
        // broadcast and log the exception
        do ##class(pkg.isc.perf.ui.socket.WebSocket).HandleException(e)
    }
    Quit tSC
}

/// get the html for the syntax colored line version of a line of python code
ClassMethod GetPythonColoredLine(pLine As %String) As %String [ Language = python ]
{
    from pygments import highlight
    from pygments.lexers import PythonLexer
    from pygments.formatters import HtmlFormatter
    # Use PythonLexer to tokenize the input code
    lexer = PythonLexer()
    
    # Use HtmlFormatter with inline styles
    formatter = HtmlFormatter(style='colorful', noclasses=True, nowrap=True)
    
    # Highlight the code and get the result as an HTML string
    highlighted_code = highlight(pLine, lexer, formatter)
    return highlighted_code
}

/// return the coverage results for a given routine, testpath, and run
ClassMethod GetResults(routine As %String = "", testpath As %String = "", RunID As %Integer) As pkg.isc.perf.ui.rest.models.CoverageResults
{
    // get the name and extension type of the routine
    set tName = $Piece(routine, ".", 1, *-1)
    set tType = $Piece(routine, ".", *)
    set tType = $ZCONVERT(tType, "U")
    if ((tType '= "PY") && (tType '= "CLS") && (tType '= "INT") && (tType '= "MAC")) {
        // this should never come up: the routine is selected from a dropdown
        Set tMsg = "File type not supported"
	    $$$ThrowStatus($$$ERROR($$$GeneralError,tMsg))
    }

    // store the codeunit for the routine we're tracking in tCodeUnit
    do ##class(TestCoverage.Data.CodeUnit).GetCurrentByName(routine, , .tCodeUnit, )
    set tHash = tCodeUnit.Hash 

    set response = ##class(pkg.isc.perf.ui.rest.models.CoverageResults).%New() // the response that we'll return from this call
    
    
    // first, figure out which coverage id this corresponds to (for the covered line data)
    &sql(SELECT ID INTO :tCoverageID FROM TestCoverage_Data.Coverage 
    WHERE Hash = :tHash
    AND TestPath = :testpath
    AND Run = :RunID)
    If (SQLCODE < 0) {
		Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,%msg)
    }
    ElseIf (SQLCODE = 100) {
        return response 
    }
    set tCoverage = ##class(TestCoverage.Data.Coverage).%OpenId(tCoverageID)


    // Create all the CoverageResult objects for each line, getting the information from tCodeUnit and tCoverage
    set codeStream = ##class(%Stream.GlobalCharacter).%New()
    set tObjsLines = "" 
    for tLineNumber = 1:1:tCodeUnit.Lines.Count() {
        set tLine = tCodeUnit.Lines.GetAt(tLineNumber) // line code
        set tExecutable = $Bit(tCodeUnit.ExecutableLines, tLineNumber) // is the line executable
        set tRtnLine = tCoverage.RtnLine.GetAt(tLineNumber) // # times line is run
        set tTime = tCoverage.Time.GetAt(tLineNumber) // time metric
        set tTotalTime = tCoverage.TotalTime.GetAt(tLineNumber) //totaltime metric
        set tColoredLine = tLine 
        If ($ZSTRIP(tLine, "<>W") = "") { // empty line
            set tColoredLine = "<span></span>" // otherwise, the coloredLine attribute doesn't get passed at all
        }
        ElseIf (tCodeUnit.LineIsPython.GetAt(tLineNumber)) {
            set tColoredLine = ..GetPythonColoredLine(tLine)
        } ElseIf ($$$isWINDOWS) {//  ##class(%Library.SyntaxColor).%New()  only works if it's a windows machine; otherwise we'll include the non colored line
            do codeStream.WriteLine(tLine) // we'll color these lines all together
            set tObjsLines = tObjsLines _ $ListBuild(tLineNumber)
        }
        do response.results.Insert(##class(pkg.isc.perf.ui.rest.models.CoverageResult).%New(routine, tLineNumber, tLine, tColoredLine ,tExecutable, tRtnLine, tTime, tTotalTime))
    }

    if ($$$isWINDOWS) {
        // get the colored versions of each objectscript line 
        set coloredStream = ##class(%Stream.GlobalCharacter).%New()
        set colorer = ##class(%Library.SyntaxColor).%New()
        set language = "MAC"
        set flags = "PFES"
        set tGood = colorer.Color(codeStream,coloredStream,language,flags,,,,.coloringErrors,.errorEnv,.coloringWarnings)
        if tGood {
            set tPointer = 0
            While $ListNext(tObjsLines, tPointer, lineNumber) {
                set coloredLine = coloredStream.ReadLine(,.sc)
                $$$ThrowOnError(sc)
                if (coloredStream.AtEnd) {
                    quit
                }
                
                // Sometimes there are random extra lines inserted. Detect these by looking for a colored line length shorter
                // than the non-colored line.
                set rawLine = response.results.GetAt(lineNumber).line
                if ($length(coloredLine) < $length(rawLine)) && $increment(lineNumber,-1) {
                    continue
                }

                if (coloredLine [ "COS_00") {
                    // this means that there was an error from the syntax colorer for this line
                    set response.results.GetAt(lineNumber).coloredLine = response.results.GetAt(lineNumber).code
                } else {
                    // Remove line breaks
                    set coloredLine = $replace(coloredLine,"<BR>","")
                    set response.results.GetAt(lineNumber).coloredLine = coloredLine
                }
            }
        }
    }

    // get the method cyclomatic complexities
    set sql = "SELECT Name, Complexity FROM TestCoverage_Data_CodeSubUnit.Method WHERE Parent = ? "
    set resultSet = ##class(%SQL.Statement).%ExecDirect(, sql, tHash)
    If (resultSet.%SQLCODE < 0) {
        Throw ##class(%Exception.SQL).CreateFromSQLCODE(resultSet.%SQLCODE, resultSet.%Message)
    }
    while resultSet.%Next(.tSC) {
        $$$ThrowOnError(tSC)
        set tName = resultSet.%GetData(1)
        set tComplexity = resultSet.%GetData(2)
        do response.MethodResults.Insert(##class(pkg.isc.perf.ui.rest.models.CoverageMethodResult).%New(tName, tComplexity))
    }

    quit response
}

/// get all routine + test path combinations for the given run + the aggregate coverage %
ClassMethod GetRoutinePaths(RunID As %Integer) As pkg.isc.perf.ui.rest.models.CoverageRoutinePaths
{
    set response = ##class(pkg.isc.perf.ui.rest.models.CoverageRoutinePaths).%New()

    // first, get the aggregate coverage statistic and store that 
    &sql(SELECT CoveredLines, ExecutableLines INTO :tCoveredLines, :tExecutableLines FROM TestCoverage_Data_Aggregate.ByRun WHERE Run = :RunID)
    If (SQLCODE < 0) {
		Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,%msg)
    }
    set response.CoveragePercent = $Number((tCoveredLines / tExecutableLines) * 100, 2)

    // get the routine name and test path
    set sql = "SELECT Hash->Name, Hash->Type, TestPath FROM TestCoverage_Data.Coverage " _
    "WHERE Run = ? " _
    "AND (Hash->Type = 'CLS' OR Hash->Type = 'MAC') " _
    "AND Hash->Generated = 0"
    set resultSet = ##class(%SQL.Statement).%ExecDirect(, sql, RunID)
    If (resultSet.%SQLCODE < 0) {
        Throw ##class(%Exception.SQL).CreateFromSQLCODE(resultSet.%SQLCODE, resultSet.%Message)
    }
   
    while resultSet.%Next(.tSC) {
        $$$ThrowOnError(tSC)
        set tName = resultSet.%GetData(1)
        set tType = resultSet.%GetData(2)
        set tFullName = tName _ "." _ tType
        set tTestPath = resultSet.%GetData(3)
        set path = ##class(pkg.isc.perf.ui.rest.models.CoverageRoutinePath).%New(tFullName, tTestPath)
        do response.covpaths.Insert(path)
    }

    // get the unit test result url
    Set tQuery("$NAMESPACE") = $namespace
    set tCoverageRun = ##class(TestCoverage.Data.Run).%OpenId(RunID)
	Set tQuery("Index") = tCoverageRun.TestResults.%Id()
	Set response.UnitTestURL = ##class(%CSP.Page).Link("/csp/sys/%25UnitTest.Portal.Indices.zen",.tQuery)
    
    return response
}

ClassMethod GetTabularData(RunID As %Integer) As pkg.isc.perf.ui.rest.models.CoverageTabularData
{
    set response = ##class(pkg.isc.perf.ui.rest.models.CoverageTabularData).%New()
    set sql = "select 'Overall' As Routine, " _
				"ROUND(100*CoveredLines/ExecutableLines,2) PercentCoverage, " _
				"ExecutableLines as ExecutableLines, " _
				"CoveredLines As LinesCovered, " _ 
				"CASE ExecutableMethods WHEN 0 THEN NULL ELSE ROUND(100*CoveredMethods/ExecutableMethods,2) END As MethodCoverage, " _ 
				"ExecutableMethods As ExecutableMethods, " _ 
				"CoveredMethods As MethodsCovered, " _ 
                "_TIME, " _  
                "TotalTime, " _
				"1 as TopSortOrder " _ 
			"from TestCoverage_Data_Aggregate.ByRun where ExecutableLines > 0 and Run = ? " _ 
			"union all " _
			"select CodeUnit->Name||'.'||CodeUnit->Type, " _ 
				"ROUND((CoveredLines/ExecutableLines)*100,2), " _
				"ExecutableLines, " _ 
				"CoveredLines, " _ 
				"CASE ExecutableMethods WHEN 0 THEN NULL ELSE ROUND((CoveredMethods/ExecutableMethods)*100,2) END, " _ 
				"ExecutableMethods, " _ 
				"CoveredMethods, " _ 
                "_TIME, " _ 
                "TotalTime, " _
				"2 " _ 
			"from TestCoverage_Data_Aggregate.ByCodeUnit where ExecutableLines > 0 and Run = ? " _ 
			"order by TopSortOrder,Routine"
    set resultSet = ##class(%SQL.Statement).%ExecDirect(, sql, RunID, RunID)
    If (resultSet.%SQLCODE < 0) {
        Throw ##class(%Exception.SQL).CreateFromSQLCODE(resultSet.%SQLCODE, resultSet.%Message)
    }
    
    while resultSet.%Next(.tSC) {
        $$$ThrowOnError(tSC)
        set tRoutine = resultSet.%GetData(1)
        set tPercentCoverage = resultSet.%GetData(2)
        set tExecutableLines = resultSet.%GetData(3)
        set tLinesCovered = resultSet.%GetData(4)
        set tMethodCoverage = resultSet.%GetData(5)
        set tExecutableMethods = resultSet.%GetData(6)
        set tMethodsCovered = resultSet.%GetData(7)
        set tTime = resultSet.%GetData(8)
        set tTotalTime = resultSet.%GetData(9)
        do response.results.Insert(##class(pkg.isc.perf.ui.rest.models.CoverageTabularDataRow).%New(tRoutine, tPercentCoverage, tExecutableLines, tLinesCovered, tMethodCoverage, tExecutableMethods, tMethodsCovered, tTime, tTotalTime))
    }
    return response
}

ClassMethod GetRunIDs() As pkg.isc.perf.ui.rest.models.CoverageRunIDs
{
    set response = ##class(pkg.isc.perf.ui.rest.models.CoverageRunIDs).%New()
    set sql = "SELECT DISTINCT ID From TestCoverage_Data.Run"
    set resultSet = ##class(%SQL.Statement).%ExecDirect(, sql)
    If (resultSet.%SQLCODE < 0) {
        Throw ##class(%Exception.SQL).CreateFromSQLCODE(resultSet.%SQLCODE, resultSet.%Message)
    }
    
    while resultSet.%Next(.tSC) {
        set tRunID = resultSet.%GetData(1)
        do response.RunIDs.Insert(tRunID)
    }
    return response
}

/// clears the TestCoverage data tables
ClassMethod ClearResults() As pkg.isc.perf.ui.rest.models.CoverageStatus
{
    do ##class(TestCoverage.Utils).Clear() 
    Quit ##class(pkg.isc.perf.ui.rest.models.CoverageStatus).%New()
}

ClassMethod CheckActive() As pkg.isc.perf.ui.rest.models.CoverageStatus
{
    Quit ##class(pkg.isc.perf.ui.rest.models.CoverageStatus).%New()
}

/// Checks the user's permission for a particular operation on a particular record. 
/// <var>pOperation</var> may be one of: 
/// CREATE 
/// READ 
/// UPDATE 
/// DELETE 
/// QUERY 
/// ACTION:<action name> 
/// <var>pUserContext</var> is supplied by <method>GetUserContext</method> 
ClassMethod CheckPermission(pID As %String, pOperation As %String, pUserContext As %RegisteredObject) As %Boolean
{
    if '$System.Security.Check("%Development","USE") { 
        quit 0 
    } 
    quit (pOperation [ "ACTION:") && $isobject(pUserContext) && (pUserContext.Username '= "UnknownUser")
}

}
