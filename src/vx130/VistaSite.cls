/// Description
Class vx130.VistaSite Extends %Persistent
{

/// The three digit Site number that uniquely identifies a site. It is
/// also the primary key.
Property Sta3n As %Integer;

/// The three character identifier for a VISTA system.  This is unique
/// to one VISTA site.  It is also the fourth piece in the journal file
/// database entry.  It can be used to find the Sta3n for a journal file record.
Property Sta3a As %String;

/// The name of the VAMC where this system was located before the move of the
/// VISTA systems to the data centers. 
Property SiteName As %String;

/// The VISTA Site is assigned to the VISN.
Property VISN As %Integer;

/// The number of hours to be added to the UTC date and time to obtain the VISTA Site
/// local date and time.
Property TimeOffset As %Integer;

/// Whether the Vista Site is located in a state that observes Daylight Saving Time.
Property ObservesDST As %Boolean;

/// Description
Index MainIndex On Sta3n [ IdKey, PrimaryKey, Unique ];

/// Description
Index Sta3aIndex On Sta3a [ Unique ];

Index VISNIndex On VISN [ Data = Sta3a ];

/// Description
ClassMethod Init() As %Status
{
    set tsc = $$$OK
    do ..%KillExtent()
    &sql(INSERT INTO vx130.vx130.VistaSite(Sta3n,Sta3a,SiteName,VISN,TimeOffset,ObservesDST) VALUES(463,'anc','Anchorage OPC',20,-8,1))
    &sql(INSERT INTO vx130.vx130.VistaSite(Sta3n,Sta3a,SiteName,VISN,TimeOffset,ObservesDST) VALUES(531,'boi','Boise VAMC',20,-6,1))
    &sql(INSERT INTO vx130.vx130.VistaSite(Sta3n,Sta3a,SiteName,VISN,TimeOffset,ObservesDST) VALUES(653,'ros','Roseburg VAMC',20,-7,1))
    &sql(INSERT INTO vx130.vx130.VistaSite(Sta3n,Sta3a,SiteName,VISN,TimeOffset,ObservesDST) VALUES(663,'pug','Puget Sound VAMC',20,-7,1))
    &sql(INSERT INTO vx130.vx130.VistaSite(Sta3n,Sta3a,SiteName,VISN,TimeOffset,ObservesDST) VALUES(648,'por','Portland VAMC',20,-7,1))
    &sql(INSERT INTO vx130.vx130.VistaSite(Sta3n,Sta3a,SiteName,VISN,TimeOffset,ObservesDST) VALUES(668,'spo','Spokane VAMC',20,-7,1))
    &sql(INSERT INTO vx130.vx130.VistaSite(Sta3n,Sta3a,SiteName,VISN,TimeOffset,ObservesDST) VALUES(687,'www','Walla Walla VAMC',20,-7,1))
    &sql(INSERT INTO vx130.vx130.VistaSite(Sta3n,Sta3a,SiteName,VISN,TimeOffset,ObservesDST) VALUES(692,'wco','White City VAMC',20,-7,1))
    return tsc
}

/// Description
ClassMethod GetVISNSites(ByRef tSites) As %Status
{
    set tsc = $$$OK
    set tInstanceID=##class(vx130.IRISInstance).GetInstanceID()
    if +tInstanceID
    {
        set tSta3n=$ORDER(^vx130.VistaSiteI("VISNIndex",tInstanceID,0))
        while +tSta3n
        {
            set tSta3a=$LISTGET(^vx130.VistaSiteI("VISNIndex",tInstanceID,tSta3n),2)
            set tSites(tSta3a)=tSta3n
            set tSta3n=$ORDER(^vx130.VistaSiteI("VISNIndex",tInstanceID,tSta3n))
        }
    }
    Return tsc
}

Storage Default
{
<Data name="VistaSiteDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Sta3a</Value>
</Value>
<Value name="3">
<Value>SiteName</Value>
</Value>
<Value name="4">
<Value>VISN</Value>
</Value>
<Value name="5">
<Value>TimeOffset</Value>
</Value>
<Value name="6">
<Value>ObservesDST</Value>
</Value>
</Data>
<DataLocation>^vx130.VistaSiteD</DataLocation>
<DefaultData>VistaSiteDefaultData</DefaultData>
<IdLocation>^vx130.VistaSiteD</IdLocation>
<IndexLocation>^vx130.VistaSiteI</IndexLocation>
<StreamLocation>^vx130.VistaSiteS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
