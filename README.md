# CrowdStrikeStuff
rough scripts that I've stitched (badly) together when Crowdstrike wouldn't offer any help.

This script will very roughly move an endpoint from one tenant to a new tenant.
Crowdstrike apparently doesn't offer a way to migrate endpoints directly, and also would not provide any guidance or help with a script.
They literally didn't even let me know that the PSFalcon module existed, so they were basically no help and told me I'd have to do it all manually.

Scripts included:
Main Script: SanitizedMigrationScript.ps1
  1. this will import your csv and your secondary script and will actually push out the RTR commands
Secondary Imported Script: SanitizedScheduleTaskScript.ps1
  1. this will set your schedule task which installs the new sensor.
  2. make sure you add your CID into the command


Prerequisite steps to get this working:
1. Upload the Falcon sensor installer into your "put" files so that Real Time Response can grab it from there.
2. there are two scripts that will run as part of this and I'm sure there's probably a way to condense it into one,
   but Crowdstrike's module is pretty picky, so I got this working and called it good enough.
3. Make sure your account and API key have permissions to use RTR and run the scripts.  The schedule task piece will run as NT AUTHORITY\SYSTEM.
4. make sure you have the sensor uninstall protection turned off or the uninstall step will not work.
5. I used a CSV to bring in the endpoints.  you only technically need the Host ID for each endpoint, but I brought in the hostname too for visibility purposes.
6. The new sensor will not install if the old sensor is still there, so when you set your scheduled task, leave yourself a bit of time just in case.

Rough steps for the script:
1. starts a transcript
2. imports the PSFalcon module and grabs an token using your API creds
3. import CSV and store hostid and hostname in variables
4. import, encode, and store the second script that will create a scheduled task on the machine
5. store the RTR commands inside of params
   1. one to 'put' the installer file on the machine
   2. one to run the converted second PS script that generates the scheduled task
6. 'puts' the installer file on the machine
7. runs the script that generates teh scheduled task
8. uninstalls the old sensor
9. ends transcript

I added some rough Write-host output so that you can see progress.
The script is pretty fast - longest part by far is the 'put' to dump the installer file.
if you have a good network location that all of your endpoints can get to, this will probably speed things up considerably, but I didn't have that option.

once the old sensor is uninstalled, the scheduled task can run which will run the sensor file and will connect it to your tenant as long as you filled in the CID.

Script is pretty badly lacking in error handling.
You'll get pretty decent error messages if a machine is offline or unreachable, but I didn't really add much in for actually handling the errors.
I didn't have a super huge list of machines so it didn't matter to me if I had to do a few manually at the end.
Script took care of the vast majority without issues so it was good enough for me to hit my deadlines.
