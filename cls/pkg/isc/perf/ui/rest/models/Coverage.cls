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
</actions>
}

ClassMethod StartTesting(pConfig As pkg.isc.perf.ui.rest.models.CoverageConfig) As pkg.isc.perf.ui.rest.models.CoverageStatus
{
    // Validate UnitTestRoot
    If pConfig.UnitTestRoot '= "" {
        Set pathRegex = "^(?:[a-zA-Z]:(?:\\|\/)|\/)?(?:[\w\s.-]+(?:\\|\/))*([\w\s.-]+(?:\\|\/))?$"
        If '$match(pConfig.UnitTestRoot, pathRegex) {
            Set tMsg = "Invalid file path for UnitTestRoot."
            $$$ThrowStatus($$$ERROR($$$GeneralError, tMsg))
        }
    }

    // Validate CoverageClasses
    If pConfig.CoverageClasses '= "" {
        Set classesRegex = "^(\s*[\w.]+(?<!\.cls)\s*,)*\s*[\w.]+(?<!\.cls)\s*$"
        If '$match(pConfig.CoverageClasses, classesRegex) {
            Set tMsg = "Invalid CoverageClasses format. Must be a comma-separated list not ending in .cls."
            $$$ThrowStatus($$$ERROR($$$GeneralError, tMsg))
        }
    }

    // Validate CoverageRoutines
    If pConfig.CoverageRoutines '= "" {
        Set routinesRegex = "^(\s*[\w.]+(?<!\.mac)\s*,)*\s*[\w.]+(?<!\.mac)\s*$"
        If '$match(pConfig.CoverageRoutines, routinesRegex) {
            Set tMsg = "Invalid CoverageRoutines format. Must be a comma-separated list not ending in .mac."
            $$$ThrowStatus($$$ERROR($$$GeneralError, tMsg))
        }
    }

    // Validate PidList
    If pConfig.PidList '= "" {
        Set pidRegex = "^(Interop|[0-9]+)(\s*,\s*[0-9]+)*$"
        If '$match(pConfig.PidList, pidRegex) {
            Set tMsg = "Invalid PidList format. Must start with Interop or be a comma-separated list of numbers."
            $$$ThrowStatus($$$ERROR($$$GeneralError, tMsg))
        }
    }

    #; Set tMsg = "Example Error"
	#; $$$ThrowStatus($$$ERROR($$$GeneralError,tMsg))
    Set tUnitTestRoot = pConfig.UnitTestRoot
    Kill tCoverageParams
    set tTiming = pConfig.Timing
    set tCoverageClasses = $LISTFROMSTRING(pConfig.CoverageClasses)
    set tCoverageRoutines = $LISTFROMSTRING(pConfig.CoverageRoutines)
    set tProcessIDs = $LISTFROMSTRING(pConfig.PidList)
    set tCoverageDetail = pConfig.CoverageLevel
    Job ..CoverageCall(tUnitTestRoot, tTiming, tCoverageClasses, tCoverageRoutines, tProcessIDs, tCoverageDetail)
    quit ##class(pkg.isc.perf.ui.rest.models.CoverageStatus).%New()
}

ClassMethod CoverageCall(pUnitTestRoot As %String, pTiming As %String, pCoverageClasses As %List, pCoverageRoutines As %List, pProcessIDs As %List, pCoverageDetail As %String) As %Status
{
    kill tCoverageParams
    set tCoverageParams("Timing") = pTiming
    set tCoverageParams("CoverageClasses") = pCoverageClasses
    set tCoverageParams("CoverageRoutines") = pCoverageRoutines
    set tCoverageParams("ProcessIDs") = pProcessIDs
    set tCoverageParams("CoverageDetail") = pCoverageDetail
    set ^UnitTestRoot = pUnitTestRoot
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

    set msg = {"message": "Finished RunTest"}
    do msg.%Set("RunID", tRunID)
    do ##class(pkg.isc.perf.ui.socket.WebSocket).BroadCast(msg)
    Quit $$$OK
}

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

/// Highlight a line of Python code and return the HTML with inline styles.
ClassMethod GetResults(routine As %String = "", testpath As %String = "", RunID As %Integer) As pkg.isc.perf.ui.rest.models.CoverageResults
{
    #; Set tMsg = "Example Error"
	#; $$$ThrowStatus($$$ERROR($$$GeneralError,tMsg))
    set tName = $Piece(routine, ".", 1, *-1)
    set tType = $Piece(routine, ".", *)
    set tType = $ZCONVERT(tType, "U")
    if ((tType '= "PY") && (tType '= "CLS") && (tType '= "INT") && (tType '= "MAC")) {
        // this should never come up: the routine is selected from a dropdown
        Set tMsg = "File type not supported"
	    $$$ThrowStatus($$$ERROR($$$GeneralError,tMsg))
    }

    
    do ##class(TestCoverage.Data.CodeUnit).GetCurrentByName(routine, , .tCodeUnit, )
    set tHash = tCodeUnit.Hash 

    set response = ##class(pkg.isc.perf.ui.rest.models.CoverageResults).%New() // the response that we'll return from this call
    
    
    // first, figure out which coverage id this corresponds to 
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
        set tLine = tCodeUnit.Lines.GetAt(tLineNumber)
        set tExecutable = $Bit(tCodeUnit.ExecutableLines, tLineNumber) 
        set tRtnLine = tCoverage.RtnLine.GetAt(tLineNumber)
        set tTime = tCoverage.Time.GetAt(tLineNumber)
        set tTotalTime = tCoverage.TotalTime.GetAt(tLineNumber)
        set tColoredLine = tLine
        If ($ZSTRIP(tLine, "<>W") = "") {
            set tColoredLine = "<span></span>" // otherwise, the coloredLine attribute doesn't get passed at all
        }
        ElseIf (tCodeUnit.LineIsPython.GetAt(tLineNumber)) {
            set tColoredLine = ..GetPythonColoredLine(tLine)
        } ElseIf ($$$isWINDOWS) {//  ##class(%Library.SyntaxColor).%New()  only works if it's a windows machine; otherwise we'll include the non colored line
            do codeStream.WriteLine(tLine)
            set tObjsLines = tObjsLines _ $ListBuild(tLineNumber)
        }
        do response.results.Insert(##class(pkg.isc.perf.ui.rest.models.CoverageResult).%New(routine, tLineNumber, tLine, tColoredLine ,tExecutable, tRtnLine, tTime, tTotalTime))
    }

    if ($$$isWINDOWS) {
        // get the colored versions of each objectscript line 
        // can't really make it a shared function because it needs to access its own results instance 
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

ClassMethod GetRoutinePaths(RunID As %Integer) As pkg.isc.perf.ui.rest.models.CoverageRoutinePaths
{
    set response = ##class(pkg.isc.perf.ui.rest.models.CoverageRoutinePaths).%New()

    // next, get the aggregate coverage statistic and store that 
    &sql(SELECT CoveredLines, ExecutableLines INTO :tCoveredLines, :tExecutableLines FROM TestCoverage_Data_Aggregate.ByRun WHERE Run = :RunID)
    If (SQLCODE < 0) {
		Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,%msg)
    }
    set response.CoveragePercent = $Number((tCoveredLines / tExecutableLines) * 100, 2)


    set sql = "SELECT Hash->Name, Hash->Type, TestPath FROM TestCoverage_Data.Coverage WHERE Run = ? "
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
    return response
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

ClassMethod ListToListBuild(pList As %Library.AbstractList) As %List
{
    set listbuild = "" 
    for i=1:1:pList.Count() { 
        set listbuild = listbuild_$listbuild(pList.GetAt(i)) 
    } 
    quit listbuild
}

}
