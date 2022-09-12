/// Description
Class vx130Test.TestController Extends %RegisteredObject
{

/// For each of the test classes check to see if the class has had changes.  If it
/// has changes it will be compiled and so we need to export.  Otherwise we will 
/// just use the currently exported class for the tests.
ClassMethod ExportClasses() As %Status
{
    set tsc = $$$OK
    set tObj=##class(%Dictionary.CompiledClass).%OpenId("vx130Test.JournalReaderStatusTests")
    do:$ISOBJECT(tObj) $SYSTEM.OBJ.Export("vx130Test.JournalReaderStatusTests.cls","/irisdb/tests/vx130Test/JournalReaderStatusTest.xml" )
    set tObj=##class(%Dictionary.CompiledClass).%OpenId("vx130Test.IRISInstanceTests")
    do:$ISOBJECT(tObj) $SYSTEM.OBJ.Export("vx130Test.IRISInstanceTests.cls","/irisdb/tests/vx130Test/IRISInstanceTest.xml" )
    set tObj=##class(%Dictionary.CompiledClass).%OpenId("vx130Test.JournalFileTests")
    do:$ISOBJECT(tObj) $SYSTEM.OBJ.Export("vx130Test.JournalFileTests.cls","/irisdb/tests/vx130Test/JournalFileTests.xml" )
    set tObj=##class(%Dictionary.CompiledClass).%OpenId("vx130Test.GlobalsToWatchTests")
    do:$ISOBJECT(tObj) $SYSTEM.OBJ.Export("vx130Test.GlobalsToWatchTests.cls","/irisdb/tests/vx130Test/GlobalsToWatchTests.xml" )
    set tObj=##class(%Dictionary.CompiledClass).%OpenId("vx130Test.JournalReaderHistoryTests")
    do:$ISOBJECT(tObj) $SYSTEM.OBJ.Export("vx130Test.JournalReaderHistoryTests.cls","/irisdb/tests/vx130Test/JournalReaderHistoryTests.xml" )
    set tObj=##class(%Dictionary.CompiledClass).%OpenId("vx130Test.JournalFileStatusTests")
    do:$ISOBJECT(tObj) $SYSTEM.OBJ.Export("vx130Test.JournalFileStatusTests.cls","/irisdb/tests/vx130Test/JournalFileStatusTests.xml" )
    
    kill tObj
    return tsc
}

/// Set the Directory for the tests.
ClassMethod SetDirectory() As %Status
{
    set sc = $$$OK
    set ^UnitTestRoot="/irisdb/tests"
    set ^|"%SYS"|SYS("Security","CSP","AllowPrefix","/csp/vx130/","%UnitTest.")=1
    return sc
}

/// Run all of the tests that have been exported to the test directory.
ClassMethod RunAllTests() As %Status
{
    Set sc = $$$OK
    do ..ExportClasses()
    do ##class(%UnitTest.Manager).RunTest("vx130Test")
    do ##class(vx130.IRISInstance).Init()
    do ##class(vx130.VistaSite).Init()
    do ##class(vx130.JournalFile).Init()
    do ##class(vx130.JournalReaderHistory).Init()
    do ##class(vx130.JournalReaderStatus).Init()
    do ##class(vx130.GlobalsToWatch).Init()
    Return sc
}

}
