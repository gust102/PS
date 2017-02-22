: Delete old backupfiles that not got deleted by RMAN
: call %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -File "C:\Job\delete_backupfiles.ps1"

# Deleting Files and Folders older than three days
$Now = Get-Date
$days = 1
# Notice the minus sign before $days
$LastWrite = $Now.AddDays(-$days)

$LogDate   = get-date -format yyyy-MM-dd
$LogFile   = "C:\Job\Log\DeleteOldBackups_$LogDate.log"

("Script start " + (get-date -format g)) | Out-File $Logfile -append

$Targetfolder = "F:\Backup\flash_recovery_area\TNETDB\BACKUPSET"
$Files = Get-ChildItem $Targetfolder -recurse |Where {$_.LastWriteTime -le "$LastWrite"} | where { ! $_.PSIsContainer }

Foreach($File in $Files)
  {
   Remove-Item $File.FullName -force -Verbose 2>&1 4>&1 | Out-File $Logfile -append
   #Remove-Item $File.FullName -force -Verbose 2>&1 | Out-File $Logfile -append
  }
