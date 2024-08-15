/// REST dispatch class for managing the line-by-line monitor
Class pkg.isc.perf.ui.rest.Handler Extends %pkg.isc.rest.handler
{

/// This parameter controls the CSP session support. By default the CSP session will be
/// ended after each request in accordance with the spirit of REST. However this CAN be
/// overridden by the user. To use a session, it's necessary to manage the CSPSESSION cookie.
/// Browsers do this automatically but command line tools such as CURL require the setting of
/// options.<p>
/// Note that if you choose to use a session then this will use a CSP license until the session
/// is ended or expires and the grace period has been satisfied. If you use the default of no
/// session then this will be the same behavior as SOAP requests of holding a license for ten
/// seconds.
Parameter UseSession As BOOLEAN = 1;

ClassMethod AuthenticationStrategy() As %Dictionary.CacheClassname
{
	return "%pkg.isc.rest.authentication.platformBased"
}

ClassMethod CheckResourcePermitted(resourceClass As %Dictionary.Classname) As %Boolean
{
	return $Piece(resourceClass,".",1,5) = "pkg.isc.perf.ui.rest"
}

ClassMethod GetUserResource(pFullUserInfo As %DynamicObject) As %pkg.isc.rest.authentication.platformUser
{
	return ##class(%pkg.isc.rest.authentication.platformUser).%New()
}

/// Called for a REST page in the event of a login being required
ClassMethod Login(skipheader As %Boolean = 1) As %Status [ ProcedureBlock = 0 ]
{
	set sc = ##super(.skipheader)
	// Suppress browser credentials prompt
	kill %response.Headers("WWW-AUTHENTICATE")
	quit sc
}

}
