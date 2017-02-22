
$SqlServerName = "xxxx.database.windows.net"
$DbName = "TntUsers"
$DbUser = "xxxxx"
$DbPassword = "xxx"

$DatabaseConnection = New-Object System.Data.SqlClient.SqlConnection
$DatabaseCommand = New-Object System.Data.SqlClient.SqlCommand
$DatabaseConnection.ConnectionString = "Server = $SqlServerName; Database = $DbName; User ID = $DbUser; Password = $DbPassword;"
$DatabaseConnection.Open();
# Create command for a specific database $DBName
$DatabaseCommand.Connection = $DatabaseConnection
$DatabaseCommand.CommandTimeout=0

$DatabaseCommand.CommandText = "[dbo].[LockAndListOldUsers]"
$ds=New-Object system.Data.DataSet
$da=New-Object system.Data.SqlClient.SqlDataAdapter($DatabaseCommand)
[void]$da.fill($ds)
$DatabaseConnection.Close()

$ds.Tables[0] | Export-Csv -Path "c:\temp\mail\LockAndListOldUsers.csv" -Delimiter "|"