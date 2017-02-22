$filePath = "H:\Backup\FULL_20170107_182012_4.bak"

$sha1 = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider

$stream = [System.IO.File]::Open($filePath,[System.IO.Filemode]::Open, [System.IO.FileAccess]::Read) 
$hash = [System.BitConverter]::ToString($sha1.ComputeHash($stream)) 
$stream.Close()

# $hash = Get-FileHash $filePath -Algorithm SHA1


## MD5
$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::Open("fredrik.txt",[System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)))

PS C:\Users\fredrik> $hash
81-80-C1-8E-35-D2-39-53-9A-EB-0B-A3-E0-DF-97-6B