Class vx130Test.JournalReaderHistoryTests Extends %UnitTest.TestCase
{

/// Delete all vx130.JournalFile and vx130,JournalFileStatus records.
/// Add a JournalreaderHistory record
/// Check that the JournalFileStatus was updated to CurrentlyReadingFile. 
Method TestAddJRHistory()
{
    do ##class(vx130.JournalFile).Init()
    do ##class(vx130.JournalReaderHistory).Init()
    do ##class(vx130.JournalReaderHistory).AddJRHistory(1,0)
    &sql(SELECT COUNT(*) INTO :tJRHistoryCount FROM vx130.JournalReaderHistory)
    &sql(SELECT COUNT(*) INTO :tJFStatusCount FROM vx130.JournalFileStatus WHERE CurrentlyReadingFile=1)
    do $$$AssertEquals(tJRHistoryCount,1, "JournalReaderHistory Record Added.")
    do $$$AssertEquals(tJFStatusCount,1, "JournalFileStatus shows CurrentlyReadingFile")
}

/// Delete all vx130.JournalFile and vx130,JournalFileStatus records.
/// Add a JournalreaderHistory record
/// Check that the JournalFileStatus was updated to CurrentlyReadingFile. 
Method TestRemoveRecord()
{
    do ##class(vx130.JournalFile).Init()
    do ##class(vx130.JournalReaderHistory).Init()
    do ##class(vx130.JournalReaderHistory).AddJRHistory(1,0)
    &sql(SELECT COUNT(*) INTO :tJRHistoryCount FROM vx130.JournalReaderHistory)
    &sql(SELECT COUNT(*) INTO :tJFStatusCount FROM vx130.JournalFileStatus WHERE CurrentlyReadingFile=1)
    do $$$AssertEquals(tJRHistoryCount,1, "JournalReaderHistory Record Added.")
    do $$$AssertEquals(tJFStatusCount,1, "JournalFileStatus shows CurrentlyReadingFile")
    do ##class(vx130.JournalReaderHistory).RemoveRecord(1)
    &sql(SELECT COUNT(*) INTO :tJRHistoryCount FROM vx130.JournalReaderHistory)
    &sql(SELECT COUNT(*) INTO :tJFStatusCount FROM vx130.JournalFileStatus WHERE CurrentlyReadingFile=1)
    do $$$AssertEquals(tJRHistoryCount,0, "JournalReaderHistory Record Removed.")
    do $$$AssertEquals(tJFStatusCount,0, "JournalFileStatus shows CurrentlyReadingFile Removed")
}

}
