Class vx130Test.GlobalsToWatchTests Extends %UnitTest.TestCase
{

/// Delete the data from vx130.GlobalsToWatch
Method TestNoInstances()
{
    do ##class(vx130.GlobalsToWatch).%KillExtent()
    &sql(SELECT COUNT(*) INTO :tNumberOfGTW FROM vx130.GlobalsToWatch)
    do $$$AssertEquals(tNumberOfGTW,0, "No GlobalsToWatch records defined.")
}

/// Initialize vx130.GlobalsToWatch, Kills the old data and populates with 
/// known records.
Method TestInitGlobalsToWatch()
{
    do ##class(vx130.GlobalsToWatch).Init()
    &sql(SELECT COUNT(*) INTO :tNumberOfGTW FROM vx130.GlobalsToWatch)
    do $$$AssertEquals(tNumberOfGTW, 21, "Known GlobalsToWatch records added."_tNumberOfGTW)
}

/// Initialize vx130.GlobalsToWatch, Kills the old data and populates with 
/// known records. Test the GetGlobalList method for this instance.
Method TestGetGlobalList()
{
    do ##class(vx130.GlobalsToWatch).Init()
    do ##class(vx130.GlobalsToWatch).GetGlobalList(.tGlobalList)
    set tGbl=$ORDER(tGlobalList(""))
    while tGbl]""
    {
        set tNumGbl=$GET(tNumGbl)+1
        set tSub=$ORDER(tGlobalList(tGbl,""))
        while tSub]""
        {
            set tNumSub=$GET(tNumSub)+1
            set tFileNum=$ORDER(tGlobalList(tGbl,tSub,""))
            while tFileNum]""
            {
                set tNumFileNum=$GET(tNumFileNum)+1
                set tSubComp=$ORDER(tGlobalList(tGbl,tSub,tFileNum,""))
                while tSubComp]""
                {
                    set tNumSubComp=$GET(tNumSubComp)+1
                    set tClsName=$ORDER(tGlobalList(tGbl,tSub,tFileNum,tSubComp,""))
                    while tClsName]""
                    {
                        set tNumClsName=$GET(tNumClsName)+1
                        set tClsName=$ORDER(tGlobalList(tGbl,tSub,tFileNum,tSubComp,tClsName))
                    }
                    set tSubComp=$ORDER(tGlobalList(tGbl,tSub,tFileNum,tSubComp))
                }
                set tFileNum=$ORDER(tGlobalList(tGbl,tSub,tFileNum))
            }
            set tSub=$ORDER(tGlobalList(tGbl,tSub))
        }
        set tGbl=$ORDER(tGlobalList(tGbl))
    }
    do $$$AssertEquals(tNumGbl, 13, "Number Of Globals"_tNumGbl)
    do $$$AssertEquals(tNumSub, 16, "Number Of Subscripts"_tNumSub)
    do $$$AssertEquals(tNumFileNum, 18, "Number Of FileNumbers"_tNumFileNum)
    do $$$AssertEquals(tNumSubComp, 19, "Number Of SubscriptCompares"_tNumSubComp)
    do $$$AssertEquals(tNumClsName, 21, "Number Of ClassNames"_tNumClsName)
}

}
