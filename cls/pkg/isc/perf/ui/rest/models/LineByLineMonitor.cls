Class pkg.isc.perf.ui.rest.models.LineByLineMonitor Extends (%pkg.isc.rest.model.resource, %Monitor.System.LineByLine)
{

Parameter RESOURCENAME = "monitor";

XData ActionMap [ XMLNamespace = "http://www.intersystems.com/apps/rest/action" ]
{
<actions>
<action name="status" target="class" call="GetCurrentStatus" method="GET" />
<action name="start" target="class" call="StartWrapper" method="POST">
    <argument target="pConfig" name="config" required="true" source="body" />
</action>
<action name="stop" target="class" call="StopWrapper" method="POST" />
<action name="pause" target="class" call="PauseWrapper" method="POST" />
<action name="resume" target="class" call="ResumeWrapper" method="POST" />
<action name="clear-counters" target="class" call="ClearCounters" method="POST" />
<action name="list-metrics" target="class" call="ListMetrics" method="GET" />
<action name="results" target="class" call="GetResults" method="GET">
    <argument target="routine" name="routine" source="query" />
</action>
</actions>
}

ClassMethod GetCurrentStatus() As pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus
{
	quit ##class(pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus).%New()
}

ClassMethod StartWrapper(pConfig As pkg.isc.perf.ui.rest.models.LineByLineMonitorConfig) As pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus
{
	set routineList = ..ListToListBuild(pConfig.routines)
	set metricList = ..ListToListBuild(pConfig.metrics)
	set processList = ..ListToListBuild(pConfig.processes)
	$$$ThrowOnError(..Start(routineList, metricList, processList))
	quit ##class(pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus).%New()
}

ClassMethod StopWrapper() As pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus
{
	$$$ThrowOnError(..Stop())
	quit ##class(pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus).%New()
}

ClassMethod PauseWrapper() As pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus
{
	$$$ThrowOnError(..Pause())
	quit ##class(pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus).%New()
}

ClassMethod ResumeWrapper() As pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus
{
	$$$ThrowOnError(..Resume())
	quit ##class(pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus).%New()
}

ClassMethod ClearCounters() As pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus
{
	set tSC = $$$OK
	set tLocked = 0
	try {
		// See if PERFMON is running (vs. line-by-line)
		if ($zutil(84,8) = 1) && ($zutil(84,16) = -1) {
			$$$ThrowStatus($$$ERROR($$$MonitorInUse))
		}
		lock +^%SYS("MON-HOLD"):3
		if '$test {
			$$$ThrowStatus($$$ERROR($$$MonitorInUse))
		}
		set tLocked = 1
		if ($zutil(84,8) = 0) {
			// Monitor is off.
			$$$ThrowStatus($$$ERROR($$$MonitorNotRunning))
		}
		// Finally: actually clear the counters.
		do $zutil(84,2)
	} catch e {
		set tSC = e.AsStatus()
	}
	if tLocked {
		lock -^%SYS("MON-HOLD")
	}
	$$$ThrowOnError(tSC)
	quit ##class(pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus).%New()
}

ClassMethod ListMetrics() As pkg.isc.perf.ui.rest.models.LineByLineMonitorMetrics
{
	quit ##class(pkg.isc.perf.ui.rest.models.LineByLineMonitorMetrics).%New()
}

ClassMethod GetResults(routine As %String = "") As pkg.isc.perf.ui.rest.models.LineByLineMonitorResults
{
	quit ##class(pkg.isc.perf.ui.rest.models.LineByLineMonitorResults).%New(routine)
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

