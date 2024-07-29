Class pkg.isc.perf.ui.rest.models.CoverageRoutinePath Extends (%RegisteredObject, %JSON.Adaptor)
{

Property routine As %String [ Required ];

Property testpath As %String [ Required ];

Method %OnNew(pRoutine, pTestPath) As %Status
{
    set ..routine = pRoutine
    set ..testpath = pTestPath 
    return $$$OK
}

}
