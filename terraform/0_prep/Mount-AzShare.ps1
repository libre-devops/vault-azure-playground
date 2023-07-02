param (
    [Parameter(Mandatory=$true)]
    [string]$storageAccountName,

    [Parameter(Mandatory=$true)]
    [string]$storageAccountKey,

    [Parameter(Mandatory=$true)]
    [string]$fileShareName
)

$logFile = "C:\output.txt"

"Running script with the following parameters:" | Out-File $logFile -Append
"Storage Account Name: $storageAccountName" | Out-File $logFile -Append
"File Share Name: $fileShareName" | Out-File $logFile -Append

"Testing network connection to $storageAccountName.file.core.windows.net on port 445..." | Out-File $logFile -Append
$connectTestResult = Test-NetConnection -ComputerName $storageAccountName.file.core.windows.net -Port 445

if ($connectTestResult.TcpTestSucceeded) {
    "Network connection successful. Adding storage account to cmdkey..." | Out-File $logFile -Append
    cmd.exe /C "cmdkey /add:`"$storageAccountName.file.core.windows.net`" /user:`"Azure\$storageAccountName`" /pass:`"$storageAccountKey`""

    "Mounting file share..." | Out-File $logFile -Append
    New-SmbMapping -LocalPath Z: -RemotePath \\$storageAccountName.file.core.windows.net\$fileShareName -Persistent $true
    "File share mounted successfully." | Out-File $logFile -Append
} else {
    "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port." | Out-File $logFile -Append
}
