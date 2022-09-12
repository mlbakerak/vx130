/// Description
Class vx130.JournalFileStatus Extends %Persistent
{

/// The journal file object for this status.
Property JournalFile As vx130.JournalFile;

/// Is the Cache Instance done writing to this journal file.
Property FileClosed As %Boolean;

/// Has the JournalReader read the entire file.
Property EntireFileRead As %Boolean;

/// Is there a JournalReader reading this file right now.
Property CurrentlyReadingFile As %Boolean;

/// The UTC Timestamp when the Cache instance closed this journal file
/// and opened a new one.
Property FileClosedDateTime As %TimeStamp;

/// The UTC Timestamp when the JournalReader read the last record in 
/// a journal file that has been closed for write by the Cache Instance.
Property EntireFileReadDateTime As %TimeStamp;

Index MainIndex On JournalFile [ IdKey, PrimaryKey, Unique ];

/// Kill all of the vx130.JournalFileStatus entries.
/// Called from vx130.JournalFile.Init()
ClassMethod Init() As %Status
{
	set tsc = $$$OK
	do ..%KillExtent()
	return tsc
}

/// For every instance journal file that was added to the VX130.JournalFile
/// the CreateStatus is called to create a corresponding record in the
/// VX130.JournalFileStatus.
/// 
ClassMethod CreateStatus(pJournalFile As vx130.JournalFile) As %Status
{
	set tsc=$$$OK
	set oRef=..%New()
	set oRef.JournalFile=pJournalFile
	set tsc=oRef.%Save()
	return tsc
}

/// When a cache instance creates a new journal file the status record
/// for the previous file will be updated using the given JournalFileID.
/// 
ClassMethod SetFileClosed(pJournalFileID As %Integer) As %Status
{
	set tsc=$$$OK
	set oRef=..%OpenId(pJournalFileID,4,.tsc)
	if $ISOBJECT(oRef)
	{
		if '(oRef.FileClosed) 
		{
			set oRef.FileClosed=1
			set oRef.FileClosedDateTime=$ZDateTime($ZTIMESTAMP,3)
			set tsc=oRef.%Save()
		}
	}
	return tsc
}

/// When the JournalReader reaches the last record of a journal file that has
/// been closed, the SetEntireFileRead method will be called to set the 
/// EntireFileRead flag to true.
/// 
ClassMethod SetEntireFileRead(pJournalFileID As %Integer) As %Status
{
	set tsc=$$$OK
	set oRef=..%OpenId(pJournalFileID,4,.tsc)
	if $ISOBJECT(oRef)
	{
		set oRef.EntireFileRead=1
		set oRef.EntireFileReadDateTime=$ZDateTime($ZTIMESTAMP,3)
		set tsc=oRef.%Save()
	}
	return tsc
}

/// When a JournalReader starts running on a journal file, the SetCurrentlyReadingFile
/// ClassMethod will be called to set the CurrentlyReading flag for the journal file.
/// 
ClassMethod SetCurrentlyReadingFile(pJournalFileID As %Integer) As %Status
{
	set tsc=$$$OK
	set oRef=..%OpenId(pJournalFileID,4,.tsc)
	if $ISOBJECT(oRef)
	{	
		set oRef.CurrentlyReadingFile=1
		set tsc=oRef.%Save()
	}
	return tsc
}

/// When a JournalReader has reached the end of a journal file or has been asked
/// to stop, the ClearCurrentlyReadingFile ClassMethod will be called to clear
/// the CurrentlyReadingFile flag for the journal file.
/// 
ClassMethod ClearCurrentlyReadingFile(pJournalFileID As %Integer) As %Status
{
	set tsc=$$$OK
	Set oRef=..%OpenId(pJournalFileID,4,.tsc)
	if $ISOBJECT(oRef)
	{
		set oRef.CurrentlyReadingFile=""
		set tsc=oRef.%Save()
	}

	return tsc
}

/// Check to see if this journal file has been closed by the instance
/// and if so have all records been read?  If so then set EntireFileRead
/// flag.
ClassMethod CheckEntireFileRead(pJournalFileID As %Integer, pOffset As %Integer) As %Status
{
	set tsc=$$$OK
	// Is JournalFile still active?
	set tJFileStatus=..%OpenId(pJournalFileID)
	set tFileClosed=tJFileStatus.FileClosed
	if 'tFileClosed
	{
		kill tJFileStatus,tFileClosed
		return tsc
	}
	set tJFileName=##class(vx130.JournalFile).GetJournalFileName(pJournalFileID)
	set tJFile=##class(%SYS.Journal.File).%OpenId(tJFileName)
	set tLastOffset=tJFile.LastRecord
	if (pOffset=tLastOffset) 
	{ 
		set tJFileStatus.EntireFileRead=1 
		set tsc=tJFileStatus.%Save()
	}
	kill tJFileStatus,tFileClosed,tJFileName,tJFile,tLastOffset
	return tsc
}

Storage Default
{
<Data name="JournalFileStatusDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>FileClosed</Value>
</Value>
<Value name="3">
<Value>EntireFileRead</Value>
</Value>
<Value name="4">
<Value>CurrentlyReadingFile</Value>
</Value>
<Value name="5">
<Value>FileClosedDateTime</Value>
</Value>
<Value name="6">
<Value>EntireFileReadDateTime</Value>
</Value>
</Data>
<DataLocation>^vx130.JournalFileStatusD</DataLocation>
<DefaultData>JournalFileStatusDefaultData</DefaultData>
<IdLocation>^vx130.JournalFileStatusD</IdLocation>
<IndexLocation>^vx130.JournalFileStatusI</IndexLocation>
<StreamLocation>^vx130.JournalFileStatusS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
