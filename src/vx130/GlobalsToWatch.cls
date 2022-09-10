/// A class that holds a list of globals and characteristics that the VX130
/// JournalReader uses to determine which JournalFile Records are of interest
/// in the JournalFile.  When a record is found, then use this class to decide
/// which classes, VISTA Site, and PrimaryKeys should be added to the DataFilerQueue. 
Class vx130.GlobalsToWatch Extends %Persistent
{

/// The name of the global to watch in Journal Files.
Property GlobalName As %String(COLLATION = "EXACT");

/// The name of the class that gets its data from this global. 
Property ClassName As %String(COLLATION = "EXACT", MAXLEN = 100);

/// The number of subscripts in this global that would indicate
/// this class would be affected by this JournalRecord.
Property NumberOfSubscripts As %Integer;

/// Which of the subscripts in this Global are the FileMan internal
/// entry numbers.
Property PrimaryKeys As %String;

Property SubscriptCompare As %String;

Property FirstSubscript As %String;

Index GlobalNameIndex On GlobalName;

/// DON'T USE - This will truncate all the entries from the GlobalsToWatch and
/// only add a couple of entries back in. Used for testing, not on a prodcuction system.
/// 
ClassMethod Init()
{
	Do ..%KillExtent()
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^PSRX','RxOut.RxOutpat52v005',2,'1',NULL,NULL))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^PSRX','RxOut.RxOutpatOriginalFill52v053',2,'1',NULL,NULL))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^PSRX','RxOut.RxOutpatPartialFill522v037',4,'1,3','2:"P"',NULL))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^PSRX','RxOut.RxOutpatReFill521v037',4,'1,3','2:"1"',NULL))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^DIC','Dim.VistaFilev004',2,'1','2:"0"',NULL))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^DD','Dim.VistaFieldv017',3,'1,2,','3:"0"',NULL))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^GMR','Allergy.Allergy1208v002',3,'2',NULL,'120.8'))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^DPT','SPatient.SPatient2v123',2,'1',NULL,NULL))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^DGSL','SPatient.SPatient2v123',3,'2',NULL,'38.1'))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^VA','SStaff.SStaff200v003',3,'2',NULL,'200'))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^LR','Chem.LabChem6304v002',4,'1,3,4','2:"CH"',NULL))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^PS','Dim.DrugClass50605v046',3,'2',NULL,'50.605'))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^PS','Dim.DrugIngredient50416v011',3,'2',NULL,'50.416'))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^PSNDF','Dim.DrugNameWithoutDose506v035',3,'2',NULL,50.6))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^PSDRUG','Dim.LocalDrug50v009',2,'1',NULL,NULL))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^LAB','Dim.LOINC953v001',3,'2',NULL,'95.3'))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^LAB','Dim.LabChemTest60v001',3,'2',NULL,'60'))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^SC','Dim.Location44v151',2,'1',NULL,NULL))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^LR','Chem.LabSubject63v001',2,'1',NULL,NULL))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^LR','Chem.OrderedLabPanel6304v015',6,'1,3,5','2:"CH",4:"ORUT"',NULL))
	&sql(INSERT INTO vx130.GlobalsToWatch(GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript) VALUES('^LR','Chem.OrderedLabPanel6304v015',4,'1,3','2:"CH"',NULL))  //For Deletions
}

/// Return an array of All of the records in the vx130.GlobalsToWatch.
/// 
ClassMethod GetGlobalList(ByRef pGlobalList)
{
	Set tStatement=##class(%SQL.Statement).%New()
	Set tSQL="SELECT GlobalName,ClassName,NumberOfSubscripts,PrimaryKeys,SubscriptCompare,FirstSubscript FROM vx130.GlobalsToWatch"
	Set tsc=tStatement.%Prepare(tSQL)
	Set tRSet=tStatement.%Execute()
	While (tRSet.%Next())
	{
		Set tfileNumber=$Select(tRSet.FirstSubscript]"":tRSet.FirstSubscript,1:0)
		Set tsubCompare=$Select(tRSet.SubscriptCompare]"":tRSet.SubscriptCompare,1:0)
		Set pGlobalList(tRSet.GlobalName,tRSet.NumberOfSubscripts,tfileNumber,tsubCompare,tRSet.ClassName)=tRSet.PrimaryKeys
	}
}

/// Return a set of distinct ClassNames from  vx130.GlobalsToWatch
/// 
Query MonitoredClasses() As %SQLQuery [ SqlProc ]
{
	SELECT DISTINCT ClassName As ClsName FROM vx130.GlobalsToWatch ORDER BY ClassName
}

Storage Default
{
<Data name="GlobalsToWatchDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>GlobalName</Value>
</Value>
<Value name="3">
<Value>ClassName</Value>
</Value>
<Value name="4">
<Value>NumberOfSubscripts</Value>
</Value>
<Value name="5">
<Value>PrimaryKeys</Value>
</Value>
<Value name="6">
<Value>SubscriptCompare</Value>
</Value>
<Value name="7">
<Value>FirstSubscript</Value>
</Value>
</Data>
<DataLocation>^vx130.GlobalsToWatchD</DataLocation>
<DefaultData>GlobalsToWatchDefaultData</DefaultData>
<IdLocation>^vx130.GlobalsToWatchD</IdLocation>
<IndexLocation>^vx130.GlobalsToWatchI</IndexLocation>
<StreamLocation>^vx130.GlobalsToWatchS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
