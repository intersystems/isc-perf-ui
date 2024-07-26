/// REST dispatch class for managing the line-by-line monitor
Class pkg.isc.perf.ui.rest.Handler Extends %pkg.isc.rest.handler
{

ClassMethod AuthenticationStrategy() As %Dictionary.CacheClassname
{
	return "%pkg.isc.rest.authentication.platformBased"
}

ClassMethod CheckResourcePermitted(resourceClass As %Dictionary.Classname) As %Boolean
{
	return ($Piece(resourceClass,".",1,5) = "pkg.isc.perf.ui.rest") || ($Piece(resourceClass,".",1,6) = "cls.pkg.isc.perf.ui.rest")
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

ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String, ByRef pContinue As %Boolean) As %Status
{
	#dim %request As %CSP.Request
	#dim %response As %CSP.Response
	#dim %session As %CSP.Session
	if (pUrl = "/socket") {
		set pContinue = 0
		set %response.ServerSideRedirect = "../../socket/pkg.isc.perf.ui.socket.WebSocket.cls?session="_%session.SessionId
		quit $$$OK
	}
	quit ##super(pUrl,pMethod,.pContinue)
}

}
