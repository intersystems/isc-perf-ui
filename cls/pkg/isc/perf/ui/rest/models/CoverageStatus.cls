Class pkg.isc.perf.ui.rest.models.CoverageStatus  Extends (%RegisteredObject, %JSON.Adaptor)
{
    Property status As %String(VALUELIST = ",stopped, running") [ InitialExpression = "running" ];

}