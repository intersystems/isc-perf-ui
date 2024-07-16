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
    Set ^UnitTestRoot = "C:\InterSystems\TestCoverage\internal\testing\unit_tests\UnitTest\"
    Kill tCoverageParams
    Set tCoverageParams("Timing") = pConfig.Timing
    Set tCoverageParams("CoverageClasses") = $LISTFROMSTRING(pConfig.CoverageClasses)
    Set tCoverageParams("CoverageRoutines") = $LISTFROMSTRING(pConfig.CoverageRoutines)
    Set tCoverageParams("ProcessIDs") = $LISTFROMSTRING(pConfig.Pidlist)
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
        Set ^IRIS.TEMPCG($i(^IRIS.TEMPCG)) = tLine
    }
    quit ##class(pkg.isc.perf.ui.rest.models.CoverageStatus).%New()
}
 
ClassMethod GetResults(routine As %String = "", testpath As %String = "") As pkg.isc.perf.ui.rest.models.CoverageResults
{  
    set tName = $Piece(routine, ".", 1, *-1)
    set tType = $Piece(routine, ".", *)
    if ((tType '= "PY") && (tType '= "CLS") && (tType '= "INT")) {
        // this should never come up: the routine is selected from a dropdown
         return $$$ERROR($$$GeneralError,"File type not supported")
    }
    


    quit ##class(pkg.isc.perf.ui.rest.models.CoverageResults).%New()
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
 