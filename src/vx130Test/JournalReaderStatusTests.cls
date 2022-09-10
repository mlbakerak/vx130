Class vx130Test.JournalReaderStatusTests Extends %UnitTest.TestCase
{

/// Delete the vx130.IRISInstances make sure the tootip returns the problem.
Method TestNoInstance()
{
    do ##class(vx130.IRISInstance).%KillExtent()
    
    set tToolTip=##class(vx130.JournalReaderStatus).GetToolTip()
    do $$$AssertEquals(tToolTip,"Can't Find Instance.", "Test No IRIS Instance Defined.")
}

/// Delete the vx130.JournalReaderHistory make sure the tootip returns the problem.
Method TestNoHistory()
{
    do ##class(vx130.IRISInstance).Init()
    do ##class(vx130.JournalReaderHistory).Init()

    set tToolTip=##class(vx130.JournalReaderStatus).GetToolTip()
    do $$$AssertEquals(tToolTip,"No Historical Data.", "Test No History")
}

/// Delete the vx130.JournalReaderStatus make sure the tootip returns the problem.
Method TestJRStatusNotFound()
{
    do ##class(vx130.IRISInstance).Init()
    do ##class(vx130.JournalReaderStatus).%KillExtent()

    set tToolTip=##class(vx130.JournalReaderStatus).GetToolTip()
    do $$$AssertEquals(tToolTip,"JournalReaderStatus Record Not Found.", "Test No JournalReaderStatus.")
}

/// Stop the instance JournalReader make sure the tootip returns the problem.
Method TestJRStopped()
{
    do ##class(vx130.IRISInstance).Init()
    do ##class(vx130.JournalReaderStatus).Init()
    do ##class(vx130.JournalReaderStatus).StopAllJournalReaders()

    set tToolTip=##class(vx130.JournalReaderStatus).GetToolTip()
    do $$$AssertEquals(tToolTip,"JournalReader is stopped.", "Test JR Stopped.")
}

/// Delete all vx130.JournalReaderHistory records and then add a record that shows 
/// the last time the JournalReader ran was more than 10 minutes ago.
Method TestLastStart()
{
    do ##class(vx130.IRISInstance).Init()
    do ##class(vx130.JournalReaderStatus).Init()
    do ##class(vx130.JournalFile).Init()
    do ##class(vx130.JournalReaderHistory).Init()

    &sql(INSERT INTO vx130.JournalReaderHistory( JournalFile, StartDateTime) VALUES( 1, DATEADD(MINUTE,-11,GETUTCDATE()) ) )
    set tToolTip=##class(vx130.JournalReaderStatus).GetToolTip()
    do $$$AssertEquals(tToolTip,"JournalReader has not started in last 10 minutes.", "Test Last JR start >10 mins.")
}

/// Delete all vx130.JournalReaderHistory records and then add a record that shows 
/// the JournalReader started more than 10 minutes ago. Add a newer record that shows
/// the JournalReader also started less than 10 minutes ago. There should not be a journal
/// reader that runs over 10 minutes.
Method TestEarlierStart()
{
    do ##class(vx130.IRISInstance).Init()
    do ##class(vx130.JournalReaderStatus).Init()
    do ##class(vx130.JournalFile).Init()
    do ##class(vx130.JournalReaderHistory).Init()

    &sql(INSERT INTO vx130.JournalReaderHistory( JournalFile, StartDateTime) VALUES( 1, DATEADD(MINUTE,-11,GETUTCDATE()) ) )
    &sql(INSERT INTO vx130.JournalReaderHistory( JournalFile, StartDateTime) VALUES( 2, DATEADD(MINUTE,-6,GETUTCDATE()) ) )
    set tToolTip=##class(vx130.JournalReaderStatus).GetToolTip()
    do $$$AssertEquals(tToolTip,"JournalReader has been running longer than 10 mins.", "Test JR run >10 mins.")
}

}
