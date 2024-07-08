/// REST model representing the current status of the line-by-line monitor
Class pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus Extends (%RegisteredObject, %JSON.Adaptor)
{

Property status As %String(VALUELIST = ",stopped,paused,running") [ Required ];

Property metrics As list Of %String [ Required ];

Property routines As list Of %String [ Required ];

Method %OnNew() As %Status [ Private, ServerOnly = 1 ]
{
	set ..status = $select($zutil(84,8)&&$zutil(84,1):"running",$zutil(84,8):"paused",1:"stopped")
	if (..status '= "stopped") {
		set metrics = $listfromstring(##class(%Monitor.System.LineByLine).GetMetrics(1))
		set pointer = 0
		while $listnext(metrics,pointer,metric) {
			do ..metrics.Insert(metric)
		}
		set count = ##class(%Monitor.System.LineByLine).GetRoutineCount()
		for i=1:1:count {
			do ..routines.Insert(##class(%Monitor.System.LineByLine).GetRoutineName(i))
		}
	}
	quit $$$OK
}

}

