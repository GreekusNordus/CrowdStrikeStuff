$Param = @{
Action = New-ScheduledTaskAction -Execute C:\WindowsSensor.exe -Argument "/install /quiet /norestart CID=<#put your CID here#>"
Trigger = New-ScheduledTaskTrigger -Once -At 12:15pm
User = "NT AUTHORITY\SYSTEM"
}
Register-ScheduledTask -TaskName InstallCS @Param
