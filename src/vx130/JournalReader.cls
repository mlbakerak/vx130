/// History:
/// 
Class vx130.JournalReader Extends %RegisteredObject
{

/// Called from VX130.JournalReaderHistory with the id of the
/// JournalReaderHistory, pJRHId, that called this method.
/// This method calls ReadFile and that method returns:
/// 
/// 	1.  StartDateTime
/// 	2.  EndDateTime
/// 	3.  StartOffset
/// 	4.  EndOffset
/// 	5.  InstanceID
/// 	6.  JournalFileID
/// 	7.  NumRecsRead
/// 	8.  NumberOfPK
/// 	9.  AddedToKillQueue
/// 	10. AddedToSetQueue
/// 	11. AlreadyInKillQueue
/// 	12. AlreadyInSetQueue
/// 	13. NotAddedToQueue
/// 	14. NumberOfNonNumeric
ClassMethod StartJRInBackground(pJRHistoryID As %Integer, pDisplayOutput As %Boolean = 0) As %Status
{
    #dim tJFile As %SYS.Journal.File
    #dim tJRec As %SYS.Journal.SetKillRecord
    set tsc=$$$OK
    set tInstanceID=##class(vx130.IRISInstance).GetInstanceID()
    
    //  JournalReader Stopped?
    set tSignaledToStop=$Case($ListGet(^VX130.JournalReaderStatusD(tInstanceID),2),"R":0,:1)
    if tSignaledToStop
    {
        set tsc=##class(vx130.JournalReaderHistory).RemoveRecord(pJRHistoryID)
        return tsc
    }

    // Open the JournalFile.
    set tJRHistory=##class(vx130.JournalReaderHistory).%OpenId(pJRHistoryID)
    set tJFileName=##class(vx130.JournalFile).GetJournalFileName(tJRHistory.JournalFile.%Id())
    set tJFile=##class(%SYS.Journal.File).%OpenId(tJFileName)
    if '$ISOBJECT(tJFile)
    {
        set tsc=##class(vx130.JournalReaderHistory).RemoveRecord(pJRHistoryID)
        return tsc
    }

    // Find the JournalRecord to start with.
    set tOffset=tJRHistory.StartOffset
    if 'tOffset
    {
        set tJRec=tJFile.FirstRecordGet()
    }
    else
    {
        set tJRec=tJFile.GetRecordAt(tOffset)
    }

    if '$ISOBJECT(tJRec)
    {
        set tsc=##class(vx130.JournalReaderHistory).RemoveRecord(pJRHistoryID)
        return tsc
    }

    // Loop through JournalFile Records to the end.
    while $ISOBJECT(tJRec)
    {
        set tOffset=tJRec.AddressGet()
        set tJRec=tJRec.NextGet()
    }

    do ##class(JournalReaderHistory).CloseRecord(pJRHistoryID,tOffset)

    return tsc
}

}
