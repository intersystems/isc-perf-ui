Class pkg.isc.perf.ui.socket.SocketConnection Extends %Persistent
{

Property SocketID As %String [ Required ];

Index SocketID On SocketID [ IdKey ];

ClassMethod Init(pSocketID As %String)
{
	If ..SocketIDExists(pSocketID) {
		Set tInst = ..SocketIDOpen(pSocketID)
	} Else {
		Set tInst = ..%New()
		Set tInst.SocketID = pSocketID
	}
	$$$ThrowOnError(tInst.%Save(0))
}

ClassMethod End(pSocketID As %String)
{
	$$$ThrowOnError(..SocketIDDelete(pSocketID))
}

Storage Default
{
<Data name="SocketConnectionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^pkg.isc.pe2DAA.SocketConne9221D</DataLocation>
<DefaultData>SocketConnectionDefaultData</DefaultData>
<IdLocation>^pkg.isc.pe2DAA.SocketConne9221D</IdLocation>
<IndexLocation>^pkg.isc.pe2DAA.SocketConne9221I</IndexLocation>
<StreamLocation>^pkg.isc.pe2DAA.SocketConne9221S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
