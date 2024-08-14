Class pkg.isc.perf.ui.rest.models.CoverageResults Extends (%RegisteredObject, %pkg.isc.json.adaptor)
{

/// coverage/metrics results for each line
Property results As list Of pkg.isc.perf.ui.rest.models.CoverageResult;

/// cyclomatic complexities
Property MethodResults As list Of pkg.isc.perf.ui.rest.models.CoverageMethodResult;

}
