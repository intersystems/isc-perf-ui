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
    <argument target="routine" name="routine" source="query" />
    <argument target="testpath" name="testpath" source="query" />
</action>
<action name="routinepaths" target="class" call="GetRoutinePaths" method="GET">
</action> 
</actions>
}

ClassMethod StartTesting(pConfig As pkg.isc.perf.ui.rest.models.CoverageConfig) As pkg.isc.perf.ui.rest.models.CoverageStatus
{
    kill ^IRIS.TEMPCG
    set ^IRIS.TEMPCG($i(^IRIS.TEMPCG)) = "we're here!"
    Set ^UnitTestRoot = pConfig.UnitTestRoot
    Set ^IRIS.TEMPCG($i(^IRIS.TEMPCG)) = pConfig.UnitTestRoot
    Set ^UnitTestRoot = "C:\InterSystems\TestCoverage\internal\testing\unit_tests\UnitTest\"
    Kill tCoverageParams
    Set tCoverageParams("Timing") = pConfig.Timing
    Set tCoverageParams("CoverageClasses") = $LISTFROMSTRING(pConfig.CoverageClasses)
    Set tCoverageParams("CoverageRoutines") = $LISTFROMSTRING(pConfig.CoverageRoutines)
    Set tCoverageParams("ProcessIDs") = $LISTFROMSTRING(pConfig.PidList)
    Set tCoverageParams("CoverageDetail") = pConfig.CoverageLevel

    do ##class(TestCoverage.Utils).Clear() 
    set buffer = ##class(%pkg.isc.json.util.buffer).%New()
    do buffer.BeginCaptureOutput()
    Merge ^IRIS.TEMPCG($i(^IRIS.TEMPCG)) = tCoverageParams
    $$$ThrowOnError(##class(TestCoverage.Manager).RunTest(,,.tCoverageParams)) 
    set stream = ##class(%Stream.TmpCharacter).%New()
    do buffer.EndCaptureOutput(.stream)
    set output = []
    while 'stream.AtEnd {
        Set tLine = stream.ReadLine()
        do output.%Push(tLine)
        //Set ^IRIS.TEMPCG($i(^IRIS.TEMPCG)) = tLine
    }
    Set ^IRIS.TEMPCG($i(^IRIS.TEMPCG)) = "finished the call successfully"
    quit ##class(pkg.isc.perf.ui.rest.models.CoverageStatus).%New()
}

ClassMethod GetResults(routine As %String = "", testpath As %String = "") As pkg.isc.perf.ui.rest.models.CoverageResults
{
  
    set tName = $Piece(routine, ".", 1, *-1)
    set tType = $Piece(routine, ".", *)
    set tType = $ZCONVERT(tType, "U") 
    if ((tType '= "PY") && (tType '= "CLS") && (tType '= "INT")) {
        // this should never come up: the routine is selected from a dropdown
         return $$$ERROR($$$GeneralError,"File type not supported")
    }
    set response = ##class(pkg.isc.perf.ui.rest.models.CoverageResults).%New()
    // first, figure out which coverage id this corresponds to 
    &sql(SELECT ID INTO :tCoverageID FROM TestCoverage_Data.Coverage 
    WHERE Hash->Name = :tName 
    AND Hash->Type = :tType 
    AND TestPath = :testpath)
    If (SQLCODE < 0) {
		Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,%msg)
    }
    ElseIf (SQLCODE = 100) {
        return response 
    }
    // get the lines of code first and then create all the CoverageResult objects 
    // not sure how to iterate through the result though, might want to try it out in local iris first
    
    set sql = "SELECT Hash->CodeUnit_Lines->Lines FROM TestCoverage_Data.Coverage WHERE ID = ? "
    set resultSet = ##class(%SQL.Statement).%ExecDirect(, sql, tCoverageID)
    If (resultSet.%SQLCODE < 0) {
        Throw ##class(%Exception.SQL).CreateFromSQLCODE(resultSet.%SQLCODE, resultSet.%Message)
    }
    set tLineNumber = 1
    while resultSet.%Next(.tSC) {
        $$$ThrowOnError(tSC)
        set tLine = resultSet.%GetData(1)
        do response.results.Insert(##class(pkg.isc.perf.ui.rest.models.CoverageResult).%New(routine, tLineNumber, tLine))
        set tLineNumber = tLineNumber + 1
    }
    
    // get the Rtnline data for this routine / testpath combination
    set sql = "SELECT RtnLine, element_key FROM TestCoverage_Data.Coverage_RtnLine WHERE Coverage = ?"
    set resultSet = ##class(%SQL.Statement).%ExecDirect(, sql, tCoverageID)
    If (resultSet.%SQLCODE < 0) {
        Throw ##class(%Exception.SQL).CreateFromSQLCODE(resultSet.%SQLCODE, resultSet.%Message)
    }
    while resultSet.%Next(.tSC) {
        $$$ThrowOnError(tSC)
        set tRtnLine = resultSet.%GetData(1)
        set tLineNumber = resultSet.%GetData(2)
        set tLineResult = response.results.GetAt(tLineNumber)
        set tLineResult.RtnLineCount = tLineResult.RtnLineCount + tRtnLine
    }

    // now do the same for _TIME and _TOTALTIME (if they don't exist, this will just skip over the loops) 
    set sql = "SELECT _TIME, element_key FROM TestCoverage_Data.Coverage__TIME WHERE Coverage = ?"
    set resultSet = ##class(%SQL.Statement).%ExecDirect(, sql, tCoverageID)
    If (resultSet.%SQLCODE < 0) {
        Throw ##class(%Exception.SQL).CreateFromSQLCODE(resultSet.%SQLCODE, resultSet.%Message)
    }
    while resultSet.%Next(.tSC) {
        $$$ThrowOnError(tSC)
        set tRtnLine = resultSet.%GetData(1)
        set tLineNumber = resultSet.%GetData(2)
        set tLineResult = response.results.GetAt(tLineNumber)
        set tLineResult.TIME = tLineResult.TIME + tRtnLine
    }

    set sql = "SELECT TotalTime, element_key FROM TestCoverage_Data.Coverage_TotalTime WHERE Coverage = ?"
    set resultSet = ##class(%SQL.Statement).%ExecDirect(, sql, tCoverageID)
    If (resultSet.%SQLCODE < 0) {
        Throw ##class(%Exception.SQL).CreateFromSQLCODE(resultSet.%SQLCODE, resultSet.%Message)
    }
    while resultSet.%Next(.tSC) {
        $$$ThrowOnError(tSC)
        set tRtnLine = resultSet.%GetData(1)
        set tLineNumber = resultSet.%GetData(2)
        set tLineResult = response.results.GetAt(tLineNumber)
        set tLineResult.TotalTime = tLineResult.TotalTime + tRtnLine
    }
    
    quit response
}

ClassMethod GetRoutinePaths() As pkg.isc.perf.ui.rest.models.CoverageRoutinePaths
{
    set sql = "SELECT Hash->Name, Hash->Type, TestPath FROM TestCoverage_Data.Coverage"
    set resultSet = ##class(%SQL.Statement).%ExecDirect(, sql)
    If (resultSet.%SQLCODE < 0) {
        Throw ##class(%Exception.SQL).CreateFromSQLCODE(resultSet.%SQLCODE, resultSet.%Message)
    }
    set response = ##class(pkg.isc.perf.ui.rest.models.CoverageRoutinePaths).%New()
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
