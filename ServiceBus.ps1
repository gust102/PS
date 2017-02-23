Function CreateServiceBusQueue
{
    Param(
        [String]$Path,
        [String]$AzureUserId,
        [String]$AzurePassword,
        [String]$SBNameSpace,
        [String]$SubscriptionName,
        [String]$SendRuleName,
        [String]$ListenRuleName
        )

#Non-Default values
$LockDuration = 30
$MaxSizeInMegabytes = 1024
$DefaultMessageTimeToLive = 14
$LockDuration = 30
$EnableBatchedOperations = $True
$EnablePartitioning = $True
$MaxDeliveryCount = 10

$SendKey = [Microsoft.ServiceBus.Messaging.SharedAccessAuthorizationRule]::GenerateRandomKey()
[Microsoft.ServiceBus.Messaging.AccessRights[]] $SendAccessRights  = [Microsoft.ServiceBus.Messaging.AccessRights]::Send
$AuthorizationRuleSend = [Microsoft.ServiceBus.Messaging.SharedAccessAuthorizationRule]::new($SendRuleName,$SendKey, $SendAccessRights)

$ListenKey = [Microsoft.ServiceBus.Messaging.SharedAccessAuthorizationRule]::GenerateRandomKey()
[Microsoft.ServiceBus.Messaging.AccessRights[]] $ListenAccessRights  = [Microsoft.ServiceBus.Messaging.AccessRights]::Listen
$AuthorizationRuleListen = [Microsoft.ServiceBus.Messaging.SharedAccessAuthorizationRule]::new($ListenRuleName,$ListenKey, $ListenAccessRights)




$azurePasswordSecure = ConvertTo-SecureString $AzurePassword -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($AzureUserId, $azurePasswordSecure)

# Login to Azure
#Login-AzureRmAccount -Credential $psCred | Out-Null
Add-AzureAccount -Credential $psCred

# Set the subscription
#Get-AzureRmSubscription -SubscriptionName $SubscriptionName |Select-AzureRmSubscription | Out-Null
Get-AzureSubscription -SubscriptionName $SubscriptionName |Select-AzureSubscription

Start-Transcript -path ServiceBusResult.txt -append
$sb = Get-AzureSBNamespace
$sb1 = $sb | where {$_.name.contains("$SBNameSpace")}
$sbcs = $sb1.ConnectionString

$NamespaceManager = [Microsoft.ServiceBus.NamespaceManager]::CreateFromConnectionString($sbcs)
#$AllQueues = $NamespaceManager.GetQueues() | Sort-Object MessageCount #-Descending


# Check if the queue already exists
if ($NamespaceManager.QueueExists($Path))
 {
    Write-Output "The [$Path] queue already exists in the [$SBNameSpace] namespace."
 }
 else
 {
    Write-Output "Creating the [$Path] queue in the [$SBNameSpace] namespace..."
    $QueueDescription = New-Object -TypeName Microsoft.ServiceBus.Messaging.QueueDescription -ArgumentList $Path
    if ($AutoDeleteOnIdle -ge 5)
    {
        $QueueDescription.AutoDeleteOnIdle = [System.TimeSpan]::FromMinutes($AutoDeleteOnIdle)
    }
    if ($DefaultMessageTimeToLive -gt 0)
    {
        $QueueDescription.DefaultMessageTimeToLive = [System.TimeSpan]::FromDays($DefaultMessageTimeToLive)
    }
    if ($DuplicateDetectionHistoryTimeWindow -gt 0)
    {
        $QueueDescription.DuplicateDetectionHistoryTimeWindow = [System.TimeSpan]::FromMinutes($DuplicateDetectionHistoryTimeWindow)
    }
    $QueueDescription.EnableBatchedOperations = $EnableBatchedOperations
    $QueueDescription.EnableDeadLetteringOnMessageExpiration = $EnableDeadLetteringOnMessageExpiration
    $QueueDescription.EnableExpress = $EnableExpress
    $QueueDescription.EnablePartitioning = $EnablePartitioning
    $QueueDescription.ForwardDeadLetteredMessagesTo = $ForwardDeadLetteredMessagesTo
    $QueueDescription.ForwardTo = $ForwardTo
    $QueueDescription.IsAnonymousAccessible = $IsAnonymousAccessible
    if ($LockDuration -gt 0)
    {
        $QueueDescription.LockDuration = [System.TimeSpan]::FromSeconds($LockDuration)
    }
    $QueueDescription.MaxDeliveryCount = $MaxDeliveryCount
    $QueueDescription.MaxSizeInMegabytes = $MaxSizeInMegabytes
    $QueueDescription.RequiresDuplicateDetection = $RequiresDuplicateDetection
    $QueueDescription.RequiresSession = $RequiresSession
    if ($EnablePartitioning)
    {
        $QueueDescription.SupportOrdering = $False
    }
    else
    {
        $QueueDescription.SupportOrdering = $SupportOrdering
    }
    $QueueDescription.UserMetadata = $UserMetadata
    $QueueDescription.Authorization.Add($AuthorizationRuleSend)
    $QueueDescription.Authorization.Add($AuthorizationRuleListen)
    $NamespaceManager.CreateQueue($QueueDescription);
    Write-Host "The [$Path] queue in the [$SBNameSpace] namespace has been successfully created."
    Write-Host "Key for [$SendRuleName]:  [$SendKey]"
    Write-Host "Key for [$ListenRuleName]:  [$ListenKey]"
    Write-Host " "
    Stop-Transcript
 }
}
