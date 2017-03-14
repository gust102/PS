# Function to check Input folder not holds files older than Input hour(s).

Function CheckFileAge
{
    Param([String] $Targetfolder, [Int] $Hours)

$Now = Get-Date


# Notice the minus sign before $days
$LastWrite = $Now.AddHours(-$hours)

$Files = Get-ChildItem $Targetfolder -recurse |Where-Object {$_.LastWriteTime -le "$LastWrite"} | Where-Object { ! $_.PSIsContainer }

Foreach($File in $Files)
  {
   #Remove-Item $File.FullName -force -Verbose 2>&1 4>&1 | Out-File $Logfile -append
   $File.FullName
  }
}