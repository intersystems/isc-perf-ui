/// REST model representing a line-level result from the line-by-line monitor
Class pkg.isc.perf.ui.rest.models.LineByLineMonitorResult Extends (%RegisteredObject, %JSON.Adaptor)
{

Property routine As %String;

Property line As %String;

Property coloredLine As %String;

Property code As %String;

Property metrics As array Of %Numeric;

}
