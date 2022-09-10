Class vx130Test.IRISInstanceTests Extends %UnitTest.TestCase
{

/// Delete the data from vx130.IRISInstances
Method TestNoInstances()
{
    do ##class(vx130.IRISInstance).%KillExtent()
    &sql(SELECT COUNT(*) INTO :tNumberOfInstances FROM vx130.IRISInstance)
    do $$$AssertEquals(tNumberOfInstances,0, "No IRIS Instances defined.")
}

/// Initialize vx130.IRISInstances, Kills the old data and populates with 
/// known instances.
Method TestInitInstances()
{
    do ##class(vx130.IRISInstance).Init()
    &sql(SELECT COUNT(*) INTO :tNumberOfInstances FROM vx130.IRISInstance)
    do $$$AssertEquals(tNumberOfInstances, 4, "Known IRIS Instances Added."_tNumberOfInstances)
}

/// Initialize vx130.IRISInstances, Kills the old data and populates with 
/// known instances. Test the GetInstanceID method for this instance.
Method TestGetInstanceID()
{
    do ##class(vx130.IRISInstance).Init()
    set tHostName=$PIECE($SYSTEM,":",1)
    set tExpectedID=$CASE(tHostName,"shdw-v20":20,"vx130":100,"irisfdw":101,"fdwmirror":102,:0)
    set tInstanceID=##class(vx130.IRISInstance).GetInstanceID()
    do $$$AssertEquals(tInstanceID, tExpectedID, "GetInstanceID.")
}

}
