/// Task definition is divided into two sections
/// 		- The task schedule; when it will run
/// 		- The task class; what it will do when it is running
/// 
/// Generally tasks should be scheduled using the system management portal.
/// If you need to schedule tasks programatically you can find examples at the bottom of this class.
/// 
/// A series of task classes are defined to demonstrate potential usage
/// For these examples we rely on the MailServer being set 
/// 	System Management Portal [Home]> [Configuration] > [Task Manager Settings] > [E-Mail Settings] 
/// 		The SMTP server must be defined, also any authorization which is required for the mail server
/// Edit this class and change the who@somecompany.com to your email address 
/// 
Class vx130Task.DeleteJRHistoryTask Extends %SYS.Task.Definition
{

Method OnTask() As %Status
{
	set tsc=##class(vx130.JournalReaderHistory).DeleteOlderThan35Days()
	quit $$$OK
}

ClassMethod ScheduleEveryMinute() As %Status
{
	#dim task as %SYS.Task
	set task=##Class(%SYS.Task).%New()
	set task.Name="vx130-Purge JournalReaderHistory"
	set task.Description="Purge JournalReaderHistory that is older than 35 days"
	set task.TaskClass=..%ClassName(1)  // The name of the Task Class (where OnTask is)
	set task.NameSpace=$zu(5)  // Where namespace the task will run in
	set task.DailyFrequency=0 // run once a day
	set task.DailyStartTime=0
	set task.Expires=0
	set task.StartDate=+$H
	set task.RunAsUser="_SYSTEM"
	do task.EmailOnError.Insert("michael.baker@va.gov")
	quit task.%Save()
}

}
