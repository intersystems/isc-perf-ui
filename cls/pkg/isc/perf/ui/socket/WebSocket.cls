Class pkg.isc.perf.ui.socket.WebSocket Extends %CSP.WebSocket
{

Method OnPreServer() As %Status
{
    #dim %request As %CSP.Request
	//set ^mtempcg($i(^mtempcg)) = "preserver" 
    Set ..SharedConnection = 1
	Do ##class(pkg.isc.perf.ui.socket.SocketConnection).Init(..WebSocketID)    
	Quit $$$OK
}

Method Server() As %Status
{
	For i = 1:1 {
		Set tData = ..Read(, .tSC, 1)
		If ($$$ISERR(tSC)){
			If ($$$GETERRORCODE(tSC) = $$$CSPWebSocketTimeout) {
				
			} 
			ElseIf ($$$GETERRORCODE(tSC) = $$$CSPWebSocketClosed){
				// Client closed WebSocket.
				Set tSC = $$$OK
				Try {
					Do ##class(pkg.isc.perf.ui.socket.SocketConnection).End(..WebSocketID)
				} Catch e { 
					Set tSC = e.AsStatus()
				} 
				Do ..EndServer()
				Quit
			} Else {
				$$$ThrowOnError(tSC)
			}
		} Else {
			//set ^mtempcg($i(^mtempcg)) = "not erroring"
		}
	}
	Quit $$$OK
}

ClassMethod BroadCast(pMessage As %DynamicObject) As %Status
{
	Set tSC = $$$OK 
	Try {
		//set ^mtempcg($i(^mtempcg)) = pMessage.message
		Set tQuery = "select SocketID from pkg_isc_perf_ui_socket.SocketConnection"
		Set tListeners = ##class(%SQL.Statement).%ExecDirect(,tQuery)
		If (tListeners.%SQLCODE < 0) {
			Throw ##class(%Exception.SQL).CreateFromSQLCODE(tListeners.%SQLCODE,tListeners.%Message)
		}
		While tListeners.%Next(.tSC) {
			$$$ThrowOnError(tSC)
			Set tWS = ..%New()
			If tWS.OpenServer(tListeners.%Get("SocketID")) {
				Do tWS.Write(pMessage.%ToJSON())
			}
		}
		$$$ThrowOnError(tSC)
	} Catch e {
		Set tSC = e.AsStatus() 
	}
	Quit tSC
}

ClassMethod HandleException(pException As %Exception.AbstractException)
{
	Try {
		If pException.%IsA("%Exception.StatusException") {
			Set tErrResponse = {
				"type":"error",
				"message":"An internal error occurred and has been logged."
			}
			Set tSC = pException.AsStatus()
			If ($SYSTEM.Status.GetErrorCodes(tSC) = "5001") {
				// Respond to the sender with an error message containing the message text from the status.
				Set tErrResponse.message = $PIECE($SYSTEM.Status.GetErrorText(tSC),"#5001: ",2)
			} Else {
				// Respond to the sender with a generic error message containing (and log the exception).
				Do $SYSTEM.Status.DecomposeStatus(tSC,.tErrorList)
				If (tErrorList(1,"code") = $$$PropertyRequired) {
					Set tPropName = $PIECE($PIECE(tErrorList(1,"param",1),"::",2),"(")
					Set tErrResponse.message = tPropName_" required."
				} Else {
					Set tLog = 1
				}
			}
			do ..BroadCast(tErrResponse)
			
		} Else {
			Set tLog = 1
		}
		If tLog {
			Do pException.Log()
		}
	} Catch e2 {
		Set pException.InnerException = e2
		Do pException.Log()
	}
}

Method OnPostServer() As %Status
{
	Set tSC = $$$OK
	#; Try {
	#; 	Do ##class(pkg.isc.perf.ui.socket.SocketConnection).End(..WebSocketID)
	#; } Catch e { 
	#; 	Set tSC = e.AsStatus()
	#; } 
	Quit tSC
}

}
