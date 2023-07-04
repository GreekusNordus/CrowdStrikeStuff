Start-Transcript -Path <#Throw your path in here#> -NoClobber

#import the module and get your token to use the API
Import-Module -Name PSFalcon
Request-FalconToken -ClientId 'API client ID - set this up in your CS tenant' -ClientSecret 'API Secret - set this up in your CS tenant'

#import csv and bring in hostid and hostname.  only hostid is required, but hostname is nice for the transcript and error messages
Import-Csv <#import csv path here if you have a list#> | ForEach-Object {
$hostID = $_.hostid
$hostname = $_.hostname

#bring in the PS script and convert it so the RTR command will use it
$InstallScript = [Convert]::ToBase64String(
        [System.Text.Encoding]::Unicode.GetBytes((Get-Content -Path <#your path here#>\PushScheduledInstallTask.ps1 -Raw)))

#uses RTR's 'put' command do dump the sensor installer onto the target machine.
#had to set the timeout to 600. some machines had a crap connection so setting this too short would cause the 'put' to timeout in some cases.
$ParamPutExe = @{
        Command = 'put'
        Arguments = 'WindowsSensor.exe'
        HostId = $hostID
        Timeout = 600
    }

#Stores the converted PS script in the param to be called with the RTR function
$ParamInstall = @{
        Command = 'runscript'
        Arguments = '-Raw=```powershell.exe -Enc ' + $InstallScript + '```'
        HostId = $hostID
    }


#first puts the sensor installer file onto the machine to be migrated
Write-Host "Attempting to migrate $hostname"
Write-Host "Copying Sensor file..."
Invoke-FalconRtr @ParamPutExe

#sets the schedule task to kick off the new installer after the current sensor has been uninstalled
Write-Host "Setting Scheduled Task to install sensor..."
Invoke-FalconRtr @ParamInstall

#uninstalls the current sensor - this has to be done prior to the scheduled task being able to kick off or the install will fail.
Write-Host "Uninstalling legacy sensor for $hostname."
Uninstall-FalconSensor -Id "$hostID"

}
Stop-Transcript
