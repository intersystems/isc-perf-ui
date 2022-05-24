Class pkg.isc.perf.ui.rest.Handler Extends %pkg.isc.rest.handler
{

ClassMethod AuthenticationStrategy() As %Dictionary.CacheClassname
{
	return "%pkg.isc.rest.authentication.platformBased"
}

ClassMethod CheckResourcePermitted(resourceClass As %Dictionary.Classname) As %Boolean
{
	Quit $Piece(resourceClass,".",1,5) = "pkg.isc.perf.ui.rest"
}

ClassMethod GetUserResource(pFullUserInfo As %DynamicObject) As %pkg.isc.rest.authentication.platformUser
{
	return ##class(%pkg.isc.rest.authentication.platformUser).%New()
}

}

