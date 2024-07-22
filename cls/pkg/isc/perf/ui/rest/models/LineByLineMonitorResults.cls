/// REST model representing results from the line-by-line monitor
Class pkg.isc.perf.ui.rest.models.LineByLineMonitorResults Extends (%RegisteredObject, %JSON.Adaptor)
{

Property results As list Of pkg.isc.perf.ui.rest.models.LineByLineMonitorResult;

Method %OnNew(routine As %String = "") As %Status [ Private, ServerOnly = 1 ]
{
	set status = ##class(pkg.isc.perf.ui.rest.models.LineByLineMonitorStatus).%New()
	if (status.status = "stopped") {
		quit $$$OK
	}
	for i=1:1:status.metrics.Count() {
		set metricMap($increment(metricMap)) = status.metrics.GetAt(i)
	}
	if (routine = "") {
		for i=1:1:status.routines.Count() {
			do ..RetrieveRoutineResults(status.routines.GetAt(i),.metricMap)
		}
	} else {
		do ..RetrieveRoutineResults(routine,.metricMap,1)
	}
	quit $$$OK
}

Method RetrieveRoutineResults(routine As %String, ByRef metricMap, color As %Boolean = 0)
{
	if (color) {
		set codeStream = ##class(%Stream.GlobalCharacter).%New()
	}

	$$$ThrowOnError(##class(%Monitor.System.LineByLine).ResultExecute(.qHandle, routine))
	for {
		$$$ThrowOnError(##class(%Monitor.System.LineByLine).ResultFetch(.qHandle,.Row,.AtEnd))
		quit:AtEnd
		set result = ##class(pkg.isc.perf.ui.rest.models.LineByLineMonitorResult).%New()
		set result.routine = routine
		set result.line = $piece(qHandle,"^",2)-1
		set result.code = $text(@("+"_(result.line)_"^"_routine))
		if (color) {
			do codeStream.WriteLine(result.code)
		}
		set metrics = $listget(Row)
		set pointer = 0
		set index = 0
		while $listnext(metrics,pointer,metric) {
			do result.metrics.SetAt(metric,metricMap($increment(index)))
		}
		do ..results.Insert(result)
	}
	$$$ThrowOnError(##class(%Monitor.System.LineByLine).ResultClose(.qHandle))

	if (color) {
		set coloredStream = ##class(%Stream.GlobalCharacter).%New()
		set colorer = ##class(%Library.SyntaxColor).%New()
		set language = "MAC"
		set flags = "PFES"
		set tGood = colorer.Color(codeStream,coloredStream,language,flags,,,,.coloringErrors,.errorEnv,.coloringWarnings)
		if tGood {
			for lineNumber=1:1 {
				set coloredLine = coloredStream.ReadLine(,.sc)
				$$$ThrowOnError(sc)
				if (coloredStream.AtEnd) {
					quit
				}
				
				// Sometimes there are random extra lines inserted. Detect these by looking for a colored line length shorter
				// than the non-colored line.
				set rawLine = ..results.GetAt(lineNumber).line
				if ($length(coloredLine) < $length(rawLine)) && $increment(lineNumber,-1) {
					continue
				}
				
				// Remove line breaks
				set coloredLine = $replace(coloredLine,"<BR>","")
				set ..results.GetAt(lineNumber).coloredLine = coloredLine
			}
		}
	}
}

}
