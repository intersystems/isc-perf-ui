Class pkg.isc.perf.ui.socket.Listener Extends TestCoverage.Listeners.ListenerInterface
{

Method Broadcast(pMessage As %DynamicObject) As %Status
{
	do pMessage.%Set("type", "TestCoverageOutput")
	quit ##class(pkg.isc.perf.ui.socket.WebSocket).BroadCast(pMessage)
}

}
