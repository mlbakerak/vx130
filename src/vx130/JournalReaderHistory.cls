/// A place to store information about JournalReader episodes.
/// When an instance of IRIS starts a JournalReader, a record of
/// that episode is stored here.  This record will have
/// numerious statstics about the episode like When it started
/// and when it finished as well as what was found in the journal
/// file during that episode.
/// 
Class vx130.JournalReaderHistory Extends %Persistent
{

/// The Journal File that is being read.
Property JournalFile As vx130.JournalFile;

/// The offset in the journal file where the JournalReader
/// will start reading.
Property StartOffset As %Integer;

/// The last offset in the journal file that was read.
Property EndOffset As %Integer;

/// The date and time the JournalReader was started.
Property StartDateTime As %TimeStamp;

/// The date and time the JournalReader finished.
Property EndDateTime As %TimeStamp;

/// The number of records the JournalReader found that matched
/// all the criteria as a monitored global node between
/// the start and ending offsets.
Property RecordsFound As %BigInt;

/// The number of records the JournalReader found between
/// the start and ending offsets.
Property JournalRecordsRead As %BigInt;

/// Of the Records that had a global to be monitored how many 
/// were SETs and were not already in the DataFilerQueue.
Property RecordsAddedToSetQueue As %BigInt;

/// Of the Records that had a global to be monitored how many 
/// were KILLS and were not already in the DataFilerQueue.
Property RecordsAddedToKillQueue As %BigInt;

/// Of the Records that had a global to be monitored how many 
/// were SETs and were already in the DataFilerQueue.
Property RecordsFoundInSetQueue As %Integer;

/// Of the Records that had a global to be monitored how many 
/// were KILLS and were already in the DataFilerQueue.
Property RecordsFoundInKillQueue As %Integer;

/// Of the Records that had a global to be monitored how many 
/// were disgarded because one of the IENS was not numeric.
Property IENNotNumeric As %Integer;

/// Of the Records that had a global to be monitored how many 
/// were added to the VX130.DataFilerQueueError.
Property FailedToAddToQueue As %Integer;

Property TimeInDFQ As %Numeric;

Index JournalFileIndex On JournalFile;

Index EndDateTimeIndex On EndDateTime;

/// Kill all of the existing JournalReaderHistory data.
/// 
ClassMethod Init()
{
	Do ..%KillExtent()
}

/// The StartJournalReader method is called every minute from the IRIS Task
/// Manager.  It will find all of the journal files for this instance that are not
/// currently being read and do not have the EntireFileRead flag set.  It uses this
/// information to get the last offset read for this file and then calls the
/// VX130.JournalReader.StartJRInBackground method.
/// 
ClassMethod StartJournalReader() As %Status
{
	set tsc=$$$OK
	// Check If JournalReader has been asked to stop.
	set tJRStatus=##class(vx130.JournalReaderStatus).GetJRStatus()
	if tJRStatus'="R"
	{
		kill tJRStatus
		return tsc
	}

	set tInstanceID=##class(vx130.IRISInstance).GetInstanceID()
	// Find records for this instance that have not been read completely.
	set tSQL=3
	set tSQL(1)="SELECT JournalFile,FileClosed FROM vx130.JournalFileStatus "
	set tSQL(2)="WHERE JournalFile->IRISInstance = ? AND CurrentlyReadingFile IS NULL " 
	set tSQL(3)="AND EntireFileRead IS NULL ORDER BY FileClosed DESC, JournalFile"
	set tResult=##class(%SQL.Statement).%ExecDirect(,.tSQL,tInstanceID)

	while tResult.%Next() {
		
		set tJFileId=tResult.%Get("JournalFile")

		// Get the LastOffset from JournalReaderHistory for this JournalFile.
		&sql(SELECT TOP 1 EndOffSet INTO :tStartOffset FROM vx130.JournalReaderHistory WHERE JournalFile=:tJFileId ORDER BY EndDateTime DESC)

		// Add a Record to JournalFileHistory and Start JournalReader
		set tsc=..AddJRHistory(tJFileId,+$GET(tStartOffset))
	}
	Kill tResult,tInstanceID,tSQL,tJFileId,tJRHistoryId,tJRStatus
    return tsc
}

/// Should be a task to keep the number of JournalReaderHistory records 
/// a smaller number. 
ClassMethod DeleteOlderThan35Days() As %Status
{
    set tsc=$$$OK
	&sql(DELETE %NOLOCK FROM vx130.JournalReaderHistory WHERE EndDateTime>DATEADD(DAY,-35,GETUTCDATE()))
    return tsc
}

/// Add a Record to JournalFileHistory and Start JournalReader.
/// Set the status of the JournalFile to CurrentlyReading, add  a
/// record to the JournalReaderHistory for the given JournalFileID
/// and JournalOffset and start JournalReader.
ClassMethod AddJRHistory(pJournalFileID As %Integer, pStartOffset As %Integer) As %Status
{
	set tsc = $$$OK
	set tsc=##class(vx130.JournalFileStatus).SetCurrentlyReadingFile(pJournalFileID)
	set oJFH=..%New()
	set oJFH.JournalFile=##class(vx130.JournalFile).%OpenId(pJournalFileID)
	set oJFH.StartOffset=pStartOffset
	set oJFH.StartDateTime=$ZDateTime($ZTIMESTAMP,3)
	set tsc=oJFH.%Save()
	set tid=oJFH.%Id()
	job ##class(vx130.JournalReader).StartJRInBackground(tid)
	//do ##class(vx130.JournalReader).StartJRInBackground(tid,1)
	return tsc
}

/// Description
ClassMethod RemoveRecord(pJRHistoryID As %Integer) As %Status
{
	set tsc = $$$OK
	set tJRHistory=..%OpenId(pJRHistoryID)
	set tJFileID=tJRHistory.JournalFile.%Id()
	set tsc=##class(vx130.JournalFileStatus).ClearCurrentlyReadingFile(tJFileID)
	if tsc
	{
		set tsc=..%DeleteId(pJRHistoryID)
	}
	return tsc
}

/// Description
ClassMethod CloseRecord(pJRHistoryID As %Integer, pEndOffset As %Integer) As %Status
{
	set tsc = $$$OK
	set tJRHistory=..%OpenId(pJRHistoryID)
	set tJFileID=tJRHistory.JournalFile.%Id()
	set tsc=##class(vx130.JournalFileStatus).ClearCurrentlyReadingFile(tJFileID)
	if tsc
	{
		set tJRHistory.EndOffset=pEndOffset
		set tJRHistory.EndDateTime=$ZDATETIME($ZTIMESTAMP,3)

		set tsc=tJRHistory.%Save()
	}
	return tsc
}

Storage Default
{
<Data name="JournalReaderHistoryDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>JournalFile</Value>
</Value>
<Value name="3">
<Value>StartOffset</Value>
</Value>
<Value name="4">
<Value>EndOffset</Value>
</Value>
<Value name="5">
<Value>StartDateTime</Value>
</Value>
<Value name="6">
<Value>EndDateTime</Value>
</Value>
<Value name="7">
<Value>RecordsFound</Value>
</Value>
<Value name="8">
<Value>JournalRecordsRead</Value>
</Value>
<Value name="9">
<Value>RecordsAddedToSetQueue</Value>
</Value>
<Value name="10">
<Value>RecordsAddedToKillQueue</Value>
</Value>
<Value name="11">
<Value>RecordsFoundInSetQueue</Value>
</Value>
<Value name="12">
<Value>RecordsFoundInKillQueue</Value>
</Value>
<Value name="13">
<Value>IENNotNumeric</Value>
</Value>
<Value name="14">
<Value>FailedToAddToQueue</Value>
</Value>
<Value name="15">
<Value>TimeInDFQ</Value>
</Value>
</Data>
<DataLocation>^vx130.JournalReaderHistoryD</DataLocation>
<DefaultData>JournalReaderHistoryDefaultData</DefaultData>
<IdLocation>^vx130.JournalReaderHistoryD</IdLocation>
<IndexLocation>^vx130.JournalReaderHistoryI</IndexLocation>
<StreamLocation>^vx130.JournalReaderHistoryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
