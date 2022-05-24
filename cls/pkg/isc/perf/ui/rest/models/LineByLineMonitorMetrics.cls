Class pkg.isc.perf.ui.rest.models.LineByLineMonitorMetrics Extends (%RegisteredObject, %JSON.Adaptor)
{

Property metrics As list Of %String [ Required ];

/// This callback method is invoked by the <METHOD>%New</METHOD> method to 
/// provide notification that a new instance of an object is being created.
/// 
/// <P>If this method returns an error then the object will not be created.
/// <p>It is passed the arguments provided in the %New call.
/// When customizing this method, override the arguments with whatever variables and types you expect to receive from %New().
/// For example, if you're going to call %New, passing 2 arguments, %OnNew's signature could be:
/// <p>Method %OnNew(dob as %Date = "", name as %Name = "") as %Status
/// If instead of returning a %Status code this returns an oref and this oref is a subclass of the current
/// class then this oref will be the one returned to the caller of %New method.
Method %OnNew() As %Status [ Private, ServerOnly = 1 ]
{
	set metrics = $listfromstring(##class(%Monitor.System.LineByLine).GetMetrics(2))
	set pointer = 0
	while $listnext(metrics,pointer,metric) {
		do ..metrics.Insert(metric)
	}
	quit $$$OK
}

}

