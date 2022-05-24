Class pkg.isc.perf.ui.Installer
{

ClassMethod SetCSSToUTF8()
{
    Write !,"Setting ^%SYS(""CSP"",""MimeFileClassify"",""CSS"")=$lb(""text/css"",0,""utf-8"")"
    Set ^%SYS("CSP","MimeFileClassify","CSS")=$lb("text/css",0,"utf-8")
}

}