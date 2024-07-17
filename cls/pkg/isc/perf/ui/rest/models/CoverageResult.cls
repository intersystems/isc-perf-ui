Class pkg.isc.perf.ui.rest.models.CoverageResult Extends (%RegisteredObject, %JSON.Adaptor)
{

Property routine As %String;

Property line As %String;

Property code As %String(MAXLEN = 1024);

Property RtnLineCount As %Integer;

Property TIME As %String;

// it's a string so that we don't put 0 for when no time was tracked 

Property TotalTime As %String;

Method %OnNew(pRoutine, pLine, pCode, pRtnLineCount = 0, pTIME = "", pTotalTime = "") As %Status
{
    set ..routine = pRoutine
    set ..line = pLine 
    set ..code = pCode
    set ..RtnLineCount = pRtnLineCount
    set ..TIME = pTIME
    set ..TotalTime = pTotalTime
    return $$$OK
}

}
