/// Description
Class vx130.IRISInstance Extends %Persistent
{

/// The Id of the IRIS Instance, For numbered instances like the VISTA shadows,
/// This is usually the VISN number and will be less than 100. For VX130 instances
/// this number will be greater than 99.
/// 
Property InstanceID As %Integer [ Required ];

/// The name given to this IRIS Instance at install.
Property InstanceName As %String [ Required ];

/// The name of the docker container or the computer name .
Property HostName As %String [ Required ];

/// The SuperServer Port of the IRIS Instance.
Property SuperServerPort As %Integer;

/// The WebServer Port of the IRIS Instance.
Property WebServerPort As %Integer;

/// The IPAddress of the IRIS Instance.
Property IPAddress As %String;

Index MainIndex On InstanceID [ IdKey, PrimaryKey, Unique ];

Index InstanceNameIndex On InstanceName;

Index HostNameIndex On HostName;

/// Description
ClassMethod Init() As %Status
{
    set tsc = $$$OK
    do ..%KillExtent()
    &sql(INSERT INTO vx130.IRISInstance(InstanceID,InstanceName,HostName,SuperServerPort,WebServerPort,IPAddress) VALUES(20,'IRIS','shdw-v20',1972,52773,'shdw-v20'))
    &sql(INSERT INTO vx130.IRISInstance(InstanceID,InstanceName,HostName,SuperServerPort,WebServerPort,IPAddress) VALUES(100,'IRIS','vx130',1972,52773,'vx130'))
    &sql(INSERT INTO vx130.IRISInstance(InstanceID,InstanceName,HostName,SuperServerPort,WebServerPort,IPAddress) VALUES(101,'IRIS','irisfdw',1972,52773,'irisfdw'))
    &sql(INSERT INTO vx130.IRISInstance(InstanceID,InstanceName,HostName,SuperServerPort,WebServerPort,IPAddress) VALUES(102,'IRIS','fdwmirror',1972,52773,'fdwmirror'))
    return tsc
}

/// Return the Instance ID fo the IRIS instance.  Uses HostName when using docker containers,
/// otherwise change to use the instance name.
ClassMethod GetInstanceID() As %Integer
{
    set tInstanceID=0
    set tHostName=$PIECE($SYSTEM,":",1)
    &sql(SELECT InstanceID INTO :tInstanceID FROM vx130.IRISInstance WHERE HostName=:tHostName)
    Return tInstanceID
}

Storage Default
{
<Data name="IRISInstanceDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>InstanceName</Value>
</Value>
<Value name="3">
<Value>HostName</Value>
</Value>
<Value name="4">
<Value>SuperServerPort</Value>
</Value>
<Value name="5">
<Value>WebServerPort</Value>
</Value>
<Value name="6">
<Value>IPAddress</Value>
</Value>
</Data>
<DataLocation>^vx130.IRISInstanceD</DataLocation>
<DefaultData>IRISInstanceDefaultData</DefaultData>
<IdLocation>^vx130.IRISInstanceD</IdLocation>
<IndexLocation>^vx130.IRISInstanceI</IndexLocation>
<StreamLocation>^vx130.IRISInstanceS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
