Class pkg.isc.perf.ui.socket.WebSocket Extends %CSP.WebSocket
{

Method OnPreServer() As %Status
{
    #dim %request As %CSP.Request
    Set ..SharedConnection = 1
    // populate the persistent class
    Quit $$$OK
}

Method Server() As %Status
{
    For {
        set tWS = ..%New()
		do tWS.OpenServer(..WebSocketID)
		do tWS.Write("Hello World")
    }
}

ClassMethod HandleException(pException As %Exception.AbstractException, pSocketID As %String = "")
{
	Try {
		Set tLog = (pSocketID '= "")
		If pException.%IsA("%Exception.StatusException") {
			Set tErrResponse = {
				"type":"error",
				"message":"An internal error occurred and has been logged."
			}
			Set tSC = pException.AsStatus()
			If ($System.Status.GetErrorCodes(tSC) = "5001") {
				// Respond to the sender with an error message containing the message text from the status.
				Set tErrResponse.message = $Piece($System.Status.GetErrorText(tSC),"#5001: ",2)
			} Else {
				// Respond to the sender with a generic error message containing (and log the exception).
				Do $System.Status.DecomposeStatus(tSC,.tErrorList)
				If (tErrorList(1,"code") = $$$PropertyRequired) {
					Set tPropName = $Piece($Piece(tErrorList(1,"param",1),"::",2),"(")
					Set tErrResponse.message = tPropName_" required."
				} Else {
					Set tLog = 1
				}
			}
			
			// Respond to sender with error message.
			Set tWS = ..%New()
			$$$ThrowOnError(tWS.OpenServer(pSocketID))
			$$$ThrowOnError(tWS.Write(tErrResponse.%ToJSON()))
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

}
