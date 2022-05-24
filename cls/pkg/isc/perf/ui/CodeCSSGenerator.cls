Class pkg.isc.perf.ui.CodeCSSGenerator
{

ClassMethod Generate(file As %String)
{
	if ##class(%Library.File).Exists(file) {
		set file = ##class(%Stream.FileCharacter).%OpenId(file,,.sc)
		$$$ThrowOnError(sc)
	} else {
		set file = ##class(%Stream.FileCharacter).%OpenId(file)
	}

	set colorHelper = ##class(%Library.SyntaxColor).%New()
	do colorHelper.Languages(.list)
	set pointer = 0
	while $listnext(list,pointer,language) {
		set stream = ##class(%Stream.GlobalCharacter).%New()
		if ##class(%Library.SyntaxColor).%New().GetCSS(.stream,language) {
			do stream.Rewind()
			do file.CopyFrom(stream)
		}
	}

	$$$ThrowOnError(file.%Save())
}

}

