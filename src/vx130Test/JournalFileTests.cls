Class vx130Test.JournalFileTests Extends %UnitTest.TestCase
{

/// Delete all vx130.JournalFile and vx130,JournalFileStatus records.
Method TestNoJournalFiles()
{
    do ##class(vx130.JournalFile).%KillExtent()
    do ##class(vx130.JournalFileStatus).%KillExtent()
    &sql(SELECT COUNT(*) INTO :tNumberOfJournalFiles FROM vx130.JournalFile)
    &sql(SELECT COUNT(*) INTO :tNumberOfJournalFileStatus FROM vx130.JournalFileStatus)
    do $$$AssertEquals(tNumberOfJournalFiles,0, "No JournalFiles defined.")
    do $$$AssertEquals(tNumberOfJournalFileStatus,0, "No JournalFileStatus defined.")
}

/// Delete all vx130.JournalFile and vx130,JournalFileStatus records.
/// Then add instance journal files into both files.
Method TestAddNewFiles()
{
    do ##class(vx130.IRISInstance).Init()
    do ##class(vx130.JournalFile).Init()
    &sql(SELECT COUNT(*) INTO :tNumberOfJournalFiles FROM vx130.JournalFile)
    &sql(SELECT COUNT(*) INTO :tNumberOfJournalFileStatus FROM vx130.JournalFileStatus)
    do $$$AssertEquals(tNumberOfJournalFileStatus,tNumberOfJournalFileStatus, "NumberOfJournalFiles equals NumberOfJournalFileStatus. =>"_tNumberOfJournalFiles)
}

/// Delete all vx130.JournalFile and vx130,JournalFileStatus records.
/// Then add instance journal files into both files.
/// Check to make sure that there is an open file.
Method TestAddNewStatus()
{
    do ##class(vx130.IRISInstance).Init()
    do ##class(vx130.JournalFile).Init()
    &sql(SELECT COUNT(*) INTO :tNumberOfJournalFiles FROM vx130.JournalFile)
    &sql(SELECT COUNT(*) INTO :NumberOfJournFilesClosed FROM vx130.JournalFileStatus WHERE FileClosed=1 )
    do $$$AssertNotEquals(tNumberOfJournalFiles,NumberOfJournFilesClosed, "NumberOfJournalFiles should not equal the NumberOfJournFilesClosed.")
    do $$$AssertEquals(tNumberOfJournalFiles,(NumberOfJournFilesClosed+1), "NumberOfJournFilesClosed + 1 open should equal the NumberOfJournalFiles.")
}

/// Delete all vx130.JournalFile and vx130,JournalFileStatus records.
/// Then add instance journal files into both files.
/// Check to make sure that there is an open file.
Method TestGetJournalFileName()
{
    do ##class(vx130.IRISInstance).Init()
    do ##class(vx130.JournalFile).Init()
    set tCurrentJournalFile=##class(%SYS.Journal.System).GetCurrentFileName()
    &sql(SELECT MAX(ID) INTO :tJournalFileID FROM vx130.JournalFile)
    set tJournalFileName=##class(vx130.JournalFile).GetJournalFileName($GET(tJournalFileID))
    do $$$AssertEquals(tCurrentJournalFile,tJournalFileName, "Current Journal File Name equals Last JournalFileName.")
}

}
