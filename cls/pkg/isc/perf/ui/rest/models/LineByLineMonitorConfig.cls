/// REST model for options used when starting the line-by-line monitor
Class pkg.isc.perf.ui.rest.models.LineByLineMonitorConfig Extends (%RegisteredObject, %pkg.isc.json.adaptor)
{

Property metrics As list Of %String;

Property routines As list Of %String;

Property processes As list Of %String;

}
