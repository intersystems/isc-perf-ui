/// Methods that run on installation/uninstallation of isc.perf.ui
Class pkg.isc.perf.ui.Installer
{

ClassMethod SetCSSToUTF8()
{
    Write !,"Setting ^%SYS(""CSP"",""MimeFileClassify"",""CSS"")=$lb(""text/css"",0,""utf-8"")"
    Set ^%SYS("CSP","MimeFileClassify","CSS")=$lb("text/css",0,"utf-8")
}

ClassMethod AddCodeDBReadForStaticFiles(webApplication As %String)
{
    Set oldNS = $Namespace
    New $Namespace
    Set $Namespace = "%SYS"
    
    // Find the namespace-default routine DB
    $$$ThrowOnError(##class(Config.Namespaces).Get(oldNS,.nsProps))
    Set defaultDB = nsProps("Routines")
    $$$ThrowOnError(##class(Config.Databases).Get(defaultDB,.dbProps))
    Set db=##Class(SYS.Database).%OpenId(dbProps("Directory"),,.sc)
    $$$ThrowOnError(sc)
    Set dbResource = db.ResourceName

    // Is there public READ permission on the namespace-default routine DB?
    $$$ThrowOnError(##class(Security.Resources).Get(dbResource,.resourceProps))
    If (resourceProps("PublicPermission")#2) {
        // No need to do anything else if there's public R permission
        Quit
    }

    // Create role granting R permission on namespace-default routine DB resource
    // This is the least-access means to be able to use the REST handler class
    // in unauthenticated mode
    Set roleName = "pkg.isc.perf.ui"
    Set roleProps("Description") = "Role granting only R permission on "_dbResource
    Set roleProps("Resources") = dbResource_":R"
    Set roleProps("GrantedRoles") = ""
    If ##class(Security.Roles).Exists(roleName) {
        Write !,"Updating role: ",roleName
        $$$ThrowOnError(##class(Security.Roles).Modify(roleName,.roleProps))
    } Else {
        Write !,"Creating role: ",roleName
        $$$ThrowOnError(##class(Security.Roles).Create(roleName,roleProps("Description"),roleProps("Resources"),roleProps("GrantedRoles")))
    }
    $$$ThrowOnError(##class(Security.Applications).Get(webApplication,.props))
    Set props("MatchRoles")=":"_roleName
    $$$ThrowOnError(##class(Security.Applications).Modify(webApplication,.props))
}

ClassMethod RemoveSecurityChanges()
{
    Set oldNS = $Namespace
    New $Namespace
    Set $Namespace = "%SYS"
    
    Try {
        Set roleName = "pkg.isc.perf.ui"
        If ##class(Security.Roles).Exists(roleName) {
            Write !,"Removing role: ",roleName
            $$$ThrowOnError(##class(Security.Roles).Delete(roleName))
        }
    } Catch e {
        Write !,"Error occurred cleaning up security objects: "
        Write $System.Status.GetErrorText(e.AsStatus())
    }
}

}
