/// This class stores the status of each instance's JournalReader,
/// it also controls the instance journal reader.  Every JournalReader
/// checks the Status flag in this class before each journal record is
/// read.  If the JournalReader has been asked to stop then the JournalReader
/// will close and update the JournalReaderHistory with the current information.
/// 
/// This class also has a method, (UpdateInstanceMonitorStatus) that will check
/// for multiple problems and store an overall status for the JournalReader so
/// the monitor just has one thing to query to find out the overall status of any
/// JournalReader.
/// 
Class vx130.JournalReaderStatus Extends %Persistent
{

/// Should not take longer than x mins to read any journal file.
Parameter ElapsedTimeLimit As %Integer = 50;

/// After a JournalFile is closed, should not take more than x minutes to read it to the end.
Parameter FileCloseTimeLimit As %Integer = 70;

/// JournalReader should start every minute unless reading the last file.  If it is reading 
/// the last file should only need x minutes to reach the end.
Parameter JournalReaderStartLimit As %Integer = 40;

/// The numbered instance, should create a JournalFile at least once every x minutes.
Parameter MinutesSinceLastJournalFile As %Integer = 180;

/// The JournalReader Cache Instance.
Property IRISInstance As vx130.IRISInstance;

/// The current status flag for the JournalReader.  A JournalReader that
/// is running normally will have a value of 'R'.  Anythings else will
/// Stop the JournalReader.
Property Status As %String;

/// A numeric value for the JournalReader overall status.
/// 0 - Is Fatal Error , 1 - is Normal, 2 - Is Warning.
Property MonitorStatus As %Integer;

/// When the overall status is a Fatal Error or a warning, the
/// tool-tip will have additional information about what placed the
/// JOurnalReaderMonitorStatus into the error condition.
Property MonitorToolTip As %String(MAXLEN = 5000);

/// The time stamp that the UpdateInstanceMonitorStatus method was last called
/// and completed. 
Property LastMonitorUpdate As %TimeStamp;

Index MainIndex On IRISInstance [ IdKey, PrimaryKey, Unique ];

/// Kills all JournalReaderStatus records and then loops
/// through all of the active CacheInstances and adds a
/// JournalReaderStatus record setting the Status flag to 'R'unning.
/// 
ClassMethod Init() As %Status
{
    set tsc=$$$OK
	do ..%KillExtent()
	set tSQL="SELECT ID FROM vx130.IRISInstance WHERE ID<100"
	set tStatement=##class(%SQL.Statement).%New()
	set tsc=tStatement.%Prepare(tSQL)
    if tsc 
    {
        set rSet=tStatement.%Execute()
	    while rSet.%Next() 
        {
		    set tID=rSet.ID
		    &sql(INSERT INTO JournalReaderStatus(IRISInstance,Status) VALUES(:tID,'R'))
	    }
	    kill rSet,tStatement
    }
    return tsc
}

/// Return the Status flag value for the current instance JournalReader.
/// 
ClassMethod GetJRStatus() As %String
{
	set tInstanceID=##class(vx130.IRISInstance).GetInstanceID()
	&sql(SELECT %NOLOCK Status INTO :tStatus FROM VX130.JournalReaderStatus WHERE IRISInstance=:tInstanceID)
    set:$GET(tStatus)="" tStatus="Not Found."
	return tStatus
}

/// Set the  JournalReader status to 'S'top for the current IRIS Instance.
/// 
ClassMethod SetJournalReaderToStop() As %String
{
	set tInstanceID=##class(vx130.IRISInstance).GetInstanceID()
	&sql(UPDATE VX130.JournalReaderStatus Set Status='S' WHERE IRISInstance=:tInstanceID)
	set tStatus=..GetJRStatus()
	return tStatus
}

/// Set the  JournalReader status to 'R'unning for the current IRIS Instance.
/// 
ClassMethod SetJournalReaderToRun()
{
	set tInstanceId=##class(vx130.IRISInstance).GetInstanceID()
	&sql(UPDATE VX130.JournalReaderStatus Set Status='R' WHERE IRISInstance=:tInstanceId)
	set tStatus=..GetJRStatus()
	return tStatus
}

/// Set the JournalReader status to 'R'unning for the given IRIS Instance.
/// 
ClassMethod StartInstanceJR(pInstanceID As %String) As %String
{
	do ##class(vx130.JournalFileStatus).ClearCurrentlyReadingFileForInstance(pInstanceID)
	&sql(UPDATE VX130.JournalReaderStatus Set Status='R' WHERE IRISInstance=:pInstanceID)
	set tStatus=..GetJRStatus()
	return tStatus
}

/// Set the  JournalReader status to 'S'top for the given IRIS Instance.
/// 
ClassMethod StopInstanceJR(pInstanceID As %String) As %String
{
	&sql(UPDATE vx130.JournalReaderStatus Set Status='S' WHERE IRISInstance=:pInstanceID)
	set tStatus=..GetJRStatus()
	return tStatus
}

/// Set the status to 'S'top for all known JournalReaders.
/// 
ClassMethod StopAllJournalReaders() As %Status
{
    set tsc=$$$OK
	&sql(UPDATE vx130.JournalReaderStatus Set Status='S')
    return tsc
}

/// Set the status to 'R'unning for all known JournalReaders.
/// 
ClassMethod StartAllJournalReaders() As %Status
{
    set tsc=$$$OK
	&sql(UPDATE vx130.JournalReaderStatus Set Status='R')
    return tsc
}

/// Method used to get the status of the JournalReader for this instance.
/// 
ClassMethod GetToolTip() As %String
{
    set tsc = $$$OK

    // Is the instanceId found?
    set tInstanceID=##class(vx130.IRISInstance).GetInstanceID()
    if $GET(tInstanceID)'>0
    {
        set tMonitorToolTip="Can't Find Instance."
        return tMonitorToolTip
    }

    // Is Journal Reader set to run?
    set tJRStatus=..GetJRStatus()
    if $GET(tJRStatus)="Not Found."
    {   
        set tMonitorToolTip="JournalReaderStatus Record Not Found."
        return tMonitorToolTip
    }
    elseif $GET(tJRStatus)'="R"
    {   
        set tMonitorToolTip="JournalReader is stopped."
        return tMonitorToolTip
    }

    // Get most recent history record for this instance.
     &sql(SELECT TOP 1 StartDateTime INTO :tLastStartTime
        FROM vx130.JournalReaderHistory 
        WHERE JournalFile->IRISInstance=:tInstanceID 
        ORDER BY StartDateTime DESC)
    
    // Are there any history records?
    if $GET(tLastStartTime)=""
    {
        set tMonitorToolTip="No Historical Data."
        return tMonitorToolTip
    }

    // How long has it been since a JournalReader started up.
    &sql(SELECT DATEDIFF(MINUTE,:tLastStartTime,GETUTCDATE()) INTO :tLastStartedMins)

    // Has it been longer than 10 minutes since a JournalReader Started?
    if $GET(tLastStartedMins)>10
    {
        set tMonitorToolTip="JournalReader has not started in last 10 minutes."
        return tMonitorToolTip
    }
    
    // Get oldest history record that has not completed
    &sql(SELECT TOP 1 StartDateTime INTO :tLastStartTime 
        FROM vx130.JournalReaderHistory 
        WHERE JournalFile->IRISInstance=:tInstanceID 
        AND EndDateTime IS NULL 
        ORDER BY StartDateTime ASC)

    // How long has oldest JournalReader been running.
    &sql(SELECT DATEDIFF(MINUTE,:tLastStartTime,GETUTCDATE()) INTO :tLastStartedMins)

    if $GET(tLastStartedMins)>10
    {
        set tMonitorToolTip="JournalReader has been running longer than 10 mins."
        return tMonitorToolTip
    }

    set tMonitorToolTip="OK"

    return tMonitorToolTip
}

/// Description
ClassMethod UpdateStatus() As %Status
{
    set tsc = $$$OK

    set tInstanceID=##class(vx130.IRISInstance).GetInstanceID()
    set tOref=..%OpenId(tInstanceID)
    if $ISOBJECT(tOref)
    {
        set tToolTip=..GetToolTip()
        set tOref.MonitorToolTip=tToolTip
        if tToolTip["OK"
        {
            set tOref.MonitorStatus=1
        }
        elseif tToolTip["10"
        {
            set tOref.MonitorStatus=2
        }
        else
        {
            set tOref.MonitorStatus=0
        }
        set tsc=tOref.%Save()
    }
    return tsc
}

Storage Default
{
<Data name="JournalReaderStatusDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Status</Value>
</Value>
<Value name="3">
<Value>MonitorStatus</Value>
</Value>
<Value name="4">
<Value>MonitorToolTip</Value>
</Value>
<Value name="5">
<Value>LastMonitorUpdate</Value>
</Value>
</Data>
<DataLocation>^vx130.JournalReaderStatusD</DataLocation>
<DefaultData>JournalReaderStatusDefaultData</DefaultData>
<IdLocation>^vx130.JournalReaderStatusD</IdLocation>
<IndexLocation>^vx130.JournalReaderStatusI</IndexLocation>
<StreamLocation>^vx130.JournalReaderStatusS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
