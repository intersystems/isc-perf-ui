Class pkg.isc.perf.ui.rest.models.CoverageTabularDataRow Extends (%RegisteredObject, %JSON.Adaptor)
{

Property Routine As %String(MAXLEN = 1024) [ Required ];

Property PercentCoverage As %String [ Required ];

Property ExecutableLines As %Integer [ Required ];

Property LinesCovered As %Integer [ Required ];

Property MethodCoverage As %String [ Required ];

Property ExecutableMethods As %Integer [ Required ];

Property MethodsCovered As %Integer [ Required ];

Property Time As %String [ Required ];

Property TotalTime As %String [ Required ];

Method %OnNew(pRoutine As %String, pPercentCoverage As %String, pExecutableLines As %Integer, pLinesCovered As %Integer, pMethodCoverage As %String, pExecutableMethods As %Integer, pMethodsCovered As %Integer, pTime As %String, pTotalTime As %String) As %Status
{
    set ..Routine = pRoutine
    set ..PercentCoverage = pPercentCoverage 
    set ..ExecutableLines = pExecutableLines
    set ..LinesCovered = pLinesCovered
    set ..MethodCoverage = pMethodCoverage
    set ..ExecutableMethods = pExecutableMethods
    set ..MethodsCovered = pMethodsCovered
    set ..Time = pTime 
    set ..TotalTime = pTotalTime
    Quit $$$OK
}

}
