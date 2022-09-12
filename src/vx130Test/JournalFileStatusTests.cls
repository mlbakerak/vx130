Class vx130Test.JournalFileStatusTests Extends %UnitTest.TestCase
{

/// Delete all vx130.JournalFile and vx130,JournalFileStatus records.
/// Then add instance journal files into both files.
/// Use the first file to check if entire file is read.
Method TestCheckEntireFileRead()
{
    do ##class(vx130.IRISInstance).Init()
    do ##class(vx130.JournalFile).Init()
    set tJFileName=##class(vx130.JournalFile).GetJournalFileName(1)
    set tJFile=##class(%SYS.Journal.File).%OpenId(tJFileName)
    set tLastOffset=tJFile.LastRecord
    set tNotLastRecord=tLastOffset-10
    do ##class(vx130.JournalFileStatus).CheckEntireFileRead(1,tNotLastRecord)
    &sql(SELECT EntireFileRead INTO :tEntireFileRead FROM vx130.JournalFileStatus WHERE JournalFile=1)
    do $$$AssertEquals(+$GET(tEntireFileRead),0, "Last offset read is not the end of the file.")
    do ##class(vx130.JournalFileStatus).CheckEntireFileRead(1,tLastOffset)
    &sql(SELECT EntireFileRead INTO :tEntireFileRead FROM vx130.JournalFileStatus WHERE JournalFile=1)
    do $$$AssertEquals(+$GET(tEntireFileRead),1, "Last offset read is the end of the file.")
    &sql(SELECT MAX(JournalFile) INTO :tLastJournalID FROM vx130.JournalFileStatus)
    set tJFileName=##class(vx130.JournalFile).GetJournalFileName(tLastJournalID)
    set tJFile=##class(%SYS.Journal.File).%OpenId(tJFileName)
    set tLastOffset=tJFile.LastRecord
    do ##class(vx130.JournalFileStatus).CheckEntireFileRead(tLastJournalID,tLastOffset)
    &sql(SELECT EntireFileRead INTO :tEntireFileRead FROM vx130.JournalFileStatus WHERE JournalFile=:tLastJournalID)
    do $$$AssertEquals(+$GET(tEntireFileRead),0, "Last offset at end of current file should not set EntireFileRead.")
}

}
