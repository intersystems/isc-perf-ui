Class pkg.isc.perf.ui.rest.StaticFilesHandler Extends pkg.isc.ipm.js.angular.pathLocationHandler
{

/// shows the standard iris login page when we try to access any page on the site
ClassMethod Login(skipheader As %Boolean = 1) As %Status [ ProcedureBlock = 0 ]
{
	// redirects to a blank csp page to give us the login screen
	Set %response.Redirect = %request.Application_"socket/pkg.isc.perf.ui.LandingPage.cls"
	Do %response.WriteHTTPHeader()
	Quit $$$OK
}

}
