Class pkg.isc.perf.ui.rest.StaticFilesHandler Extends pkg.isc.ipm.js.angular.pathLocationHandler
{

/// Called for a REST page in the event of a login being required
ClassMethod Login(skipheader As %Boolean = 1) As %Status [ ProcedureBlock = 0 ]
{
	Set %response.Redirect = %request.Application_"socket/pkg.isc.perf.ui.LandingPage.cls"
	Do %response.WriteHTTPHeader()
	Quit $$$OK
}

}
