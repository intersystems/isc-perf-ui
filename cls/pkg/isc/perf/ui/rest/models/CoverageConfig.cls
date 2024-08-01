Class pkg.isc.perf.ui.rest.models.CoverageConfig Extends (%RegisteredObject, %JSON.Adaptor)
{

Property UnitTestRoot As %String(MAXLEN = 1024);

Property PidList As %String(MAXLEN = 1024);

/// timing metric
Property Timing As %Integer;

Property CoverageClasses As %String(MAXLEN = 1024);

Property CoverageRoutines As %String(MAXLEN = 1024);

Property CoverageLevel As %Integer;

}
