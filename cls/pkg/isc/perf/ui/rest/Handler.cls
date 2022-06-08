/// REST dispatch class for managing the line-by-line monitor
Class pkg.isc.perf.ui.rest.Handler Extends %pkg.isc.rest.handler
{

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
	do %response.RemoveHeader("WWW-Authenticate")
	quit sc
}

}
