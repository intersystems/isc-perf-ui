Class pkg.isc.perf.ui.rest.models.CoverageMethodResult Extends (%RegisteredObject, %pkg.isc.json.adaptor)
{

Property Name As %String(MAXLEN = 1024);

/// the cyclomatic complexity
Property Complexity As %Integer;

Method %OnNew(pName As %String, pComplexity As %String) As %Status
{
    set ..Name = pName
    set ..Complexity = pComplexity
    return $$$OK
}

}
