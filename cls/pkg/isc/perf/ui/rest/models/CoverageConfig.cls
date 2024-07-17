Class pkg.isc.perf.ui.rest.models.CoverageConfig Extends (%RegisteredObject, %JSON.Adaptor)
{

Property UnitTestRoot As %String(MAXLEN = 1024);

Property PidList As %String(MAXLEN = 1024);

Property Timing As %Integer;

// determines the metrics

Property CoverageClasses As %String(MAXLEN = 1024);

// comma separated

Property CoverageRoutines As %String(MAXLEN = 1024);

Property CoverageLevel As %Integer;

}
