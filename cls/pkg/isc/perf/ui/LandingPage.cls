Class pkg.isc.perf.ui.LandingPage Extends %CSP.Page
{

/// after login, this gets called and redirects us to the home page (based on the urls in module.xml)
ClassMethod OnPreHTTP() As %Boolean [ ServerOnly = 1 ]
{
	Set %response.Redirect = "../"
	Quit 1
}

}
