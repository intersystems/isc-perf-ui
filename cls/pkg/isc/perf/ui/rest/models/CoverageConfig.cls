Class pkg.isc.perf.ui.rest.models.CoverageConfig Extends (%RegisteredObject, %JSON.Adaptor)
{
    
Property UnitTestRoot As %String;

Property Pidlist As %String;

Property Timing As %Integer; // determines the metrics

Property CoverageClasses As %String; // comma separated
 
Property CoverageRoutines As %String; 

Property CoverageLevel As %Integer; 

}