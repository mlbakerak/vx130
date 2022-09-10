/// Description
Class vx130.JournalFile Extends %Persistent
{

/// Description
Property IRISInstance As vx130.IRISInstance;

/// Description
Property JournalFileName As %String;

/// The directory location of the journal file for the instance
/// that wrote the journal file.
Property DirectoryName As %String(COLLATION = "EXACT", MAXLEN = 200);

/// The UTC timestamp when the Journal file was first observed.
Property CreateDateTime As %TimeStamp;

Index MainIndex On (IRISInstance, JournalFileName);

/// Kill the vx130.JournalFileStatus records, then kill
/// all the vx130.JournalFile records, then add the instance
/// journal files to both tables.
ClassMethod Init() As %Status
{
	set tsc = $$$OK
	do ##class(vx130.JournalFileStatus).Init()
	do ..%KillExtent()
	do ..AddNewFiles()
	return tsc
}

/// A method run by the Cache Task manager on each shadow system to find
/// any journal files that have been added since the last time the method was run.
/// If a new journal file is discovered, then add a corresponding record to the
/// VX130.JournalFileStatus.
/// 
ClassMethod AddNewFiles() As %Status
{
	set tsc=$$$OK
	kill tJFile,tJDir,tNumFiles,tInstanceID
	set tInstanceID=##class(vx130.IRISInstance).GetInstanceID()
	quit:tInstanceID']""
	set rSet=##class(%ResultSet).%New("%SYS.Journal.File:ByTimeReverseOrder")
	set tsc=rSet.Execute()
	set tNumFiles=0
	// Loop through all files seperating file name from directory
	while rSet.Next() {
		set tNumFiles=tNumFiles+1
		set tJFile=rSet.Data("Name")
		set tJFile(tNumFiles)=##class(%File).GetFilename(tJFile)
		Set tJDir(tNumFiles)=##class(%File).GetDirectory(tJFile,1)	
	}
	// For each file starting with oldest to newest...
	for tFileCntr=tNumFiles:-1:1
	{
		Set tFile=tJFile(tFileCntr)
		//w !,tFile
		Set tID=""
		// find out if it is already stored in JournalFiles
		&sql(SELECT f.ID INTO :tID FROM vx130.JournalFile f WHERE IRISInstance=:tInstanceID AND JournalFileName=:tFile )
		// If it is the first time we have seen this file.
		//w !,tID
		if tID="" 
		{
			set oJFile=..%New()
			set oJFile.JournalFileName=tJFile(tFileCntr)
			set oJFile.DirectoryName=tJDir(tFileCntr)
			set oJFile.IRISInstance=##class(vx130.IRISInstance).%OpenId(tInstanceID)
			set oJFile.CreateDateTime=$ZDateTime($ZTIMESTAMP,3)
			set tsc=oJFile.%Save()
			set tJournalFileID=oJFile.%Id()
			do ##class(vx130.JournalFileStatus).CreateStatus(oJFile)
			if (tFileCntr>1) Do ##class(vx130.JournalFileStatus).SetFileClosed(tJournalFileID)
			Kill oJFile
		} Else {  // If it is NOT the first time we have seen this file.
			If (tFileCntr>1) { //File is not the newest file
				Do ##class(vx130.JournalFileStatus).SetFileClosed(tID)
			}  //If File is not the newest file
		} // If it is the first time we have seen this file.
	} // For each file starting with oldest to newest...
    return tsc
}

/// Description
ClassMethod GetJournalFileName(pJournalFileID As %Integer, ByRef tsc As %Status) As %String
{
	set tsc = $$$OK
	set tJournalFile=..%OpenId(pJournalFileID)
	set tJournalFileName=tJournalFile.DirectoryName_tJournalFile.JournalFileName
	kill tJournalFile
	return tJournalFileName
}

Storage Default
{
<Data name="JournalFileDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>IRISInstance</Value>
</Value>
<Value name="3">
<Value>JournalFileName</Value>
</Value>
<Value name="4">
<Value>DirectoryName</Value>
</Value>
<Value name="5">
<Value>CreateDateTime</Value>
</Value>
</Data>
<DataLocation>^vx130.JournalFileD</DataLocation>
<DefaultData>JournalFileDefaultData</DefaultData>
<IdLocation>^vx130.JournalFileD</IdLocation>
<IndexLocation>^vx130.JournalFileI</IndexLocation>
<StreamLocation>^vx130.JournalFileS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
