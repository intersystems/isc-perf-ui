Class pkg.isc.perf.ui.rest.models.Coverage Extends (%RegisteredObject, %pkg.isc.rest.model.resource)
{
 
Parameter RESOURCENAME = "coverage";
 
XData ActionMap [ XMLNamespace = "http://www.intersystems.com/apps/rest/action" ]
{
<actions> 
<action name="start" target="class" call="StartTesting" method="GET"> 
    <argument target="pConfig" name="config" required="true" source="body" />
</action> 
</actions>
}
 
ClassMethod StartTesting(pConfig As pkg.isc.perf.ui.rest.models.CoverageConfig) As pkg.isc.perf.ui.rest.models.CoverageStatus
{
    Set ^UnitTestRoot = pConfig.UnitTestRoot
    Kill tCoverageParams
    Set tCoverageParams("Timing") = pConfig.Timing
    Set tCoverageParams("CoverageClasses") = $LISTFROMSTRING(pConfig.CoverageClasses)
    Set tCoverageParams("CoverageRoutines") = $LISTFROMSTRING(pConfig.CoverageRoutines)
    Set tCoverageParams("ProcessIDs") = $LISTFROMSTRING(pConfig.Pidlist)
    Set tCoverageParams("CoverageDetail") = pConfig.CoverageLevel

    kill ^IRIS.TEMPCG
    do ##class(TestCoverage.Utils).Clear() 
    set buffer = ##class(%pkg.isc.json.util.buffer).%New()
    do buffer.BeginCaptureOutput()
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
 