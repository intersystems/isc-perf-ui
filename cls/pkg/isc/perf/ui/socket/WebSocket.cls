Class pkg.isc.perf.ui.socket.WebSocket Extends %CSP.WebSocket
{

Method OnPreServer() As %Status
{
    #dim %request As %CSP.Request
    Set ..SharedConnection = 1 // async websocket connection
	// store the websocket id in the persistent table
	Do ##class(pkg.isc.perf.ui.socket.SocketConnection).Init(..WebSocketID)    
	Quit $$$OK
}

Method Server() As %Status
{
	For i = 1:1 {
		// read in from the websocket 
		Set tData = ..Read(, .tSC, 1)
		If ($$$ISERR(tSC)){
			If ($$$GETERRORCODE(tSC) = $$$CSPWebSocketTimeout) {
				// just happens if there's no messages for a second
			} 
			ElseIf ($$$GETERRORCODE(tSC) = $$$CSPWebSocketClosed){
				// Client closed WebSocket.
				Set tSC = $$$OK
				Try {
					// delete the websocket id from the table
					Do ##class(pkg.isc.perf.ui.socket.SocketConnection).End(..WebSocketID)
				} Catch e { 
					Set tSC = e.AsStatus()
				} 
				// end the websocket connection on the server side
				Do ..EndServer()
				Quit
			} Else {
				$$$ThrowOnError(tSC)
			}
		}
		Else {
			// we got an actual message: this is probably just a ping message then
			if (tData [ "Testing connection") 
			{
				set msg = {"message": "Connection active", "type": "ConnectionTest"}
       			do ..BroadCast(msg)
			}
		} 
	}
	Quit $$$OK
}

/// send a json message to all listening websockets
ClassMethod BroadCast(pMessage As %DynamicObject) As %Status
{
	Set tSC = $$$OK 
	Try {
		// get the active socketIDs
		Set tQuery = "select SocketID from pkg_isc_perf_ui_socket.SocketConnection"
		Set tListeners = ##class(%SQL.Statement).%ExecDirect(,tQuery)
		If (tListeners.%SQLCODE < 0) {
			Throw ##class(%Exception.SQL).CreateFromSQLCODE(tListeners.%SQLCODE,tListeners.%Message)
		}

		// write to all the websockets
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

/// code to log error messages and send them to the UI
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
			// send the message to the UI
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
	Quit $$$OK
}

}
