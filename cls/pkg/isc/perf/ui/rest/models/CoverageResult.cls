Class pkg.isc.perf.ui.rest.models.CoverageResult Extends (%RegisteredObject, %JSON.Adaptor)
{

Property routine As %String(MAXLEN = 1024);

/// line number
Property line As %Integer;

/// actual code
Property code As %String(MAXLEN = 1024);

/// html syntax colored version of code
Property coloredLine As %String(MAXLEN = 1024);

Property Executable As %Boolean;

Property RtnLineCount As %Integer;

Property TIME As %String;

// it's a string so that we don't put 0 for when no time was tracked 

Property TotalTime As %String;

Method %OnNew(pRoutine, pLine, pCode, pColoredLine = "", pExecutable = 0, pRtnLineCount = 0, pTIME = "", pTotalTime = "") As %Status
{
    set ..routine = pRoutine
    set ..line = pLine 
    set ..code = pCode
    set ..coloredLine = pColoredLine
    set ..Executable = pExecutable
    set ..RtnLineCount = pRtnLineCount
    set ..TIME = pTIME
    set ..TotalTime = pTotalTime
    return $$$OK
}

}
