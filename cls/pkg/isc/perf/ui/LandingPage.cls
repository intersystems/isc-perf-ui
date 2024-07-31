Class pkg.isc.perf.ui.LandingPage Extends %CSP.Page
{

ClassMethod OnPreHTTP() As %Boolean [ ServerOnly = 1 ]
{
	Set %response.Redirect = "../"
	Quit 1
}

}
