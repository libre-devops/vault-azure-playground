param (
    [Parameter(Mandatory=$true)]
    [string]$storageAccountName,

    [Parameter(Mandatory=$true)]
    [string]$storageAccountKey,

    [Parameter(Mandatory=$true)]
    [string]$fileShareName
)

Write-Host "Running script with the following parameters:"
Write-Host "Storage Account Name: $storageAccountName"
Write-Host "File Share Name: $fileShareName"

Write-Host "Testing network connection to $storageAccountName.file.core.windows.net on port 445..."
$connectTestResult = Test-NetConnection -ComputerName $storageAccountName.file.core.windows.net -Port 445

if ($connectTestResult.TcpTestSucceeded) {
    Write-Host "Network connection successful. Adding storage account to cmdkey..."
    cmd.exe /C "cmdkey /add:`"$storageAccountName.file.core.windows.net`" /user:`"Azure\$storageAccountName`" /pass:`"$storageAccountKey`""

    Write-Host "Mounting file share..."
    New-SmbMapping -LocalPath Z: -RemotePath \\$storageAccountName.file.core.windows.net\$fileShareName -Persistent $true
    Write-Host "File share mounted successfully."
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
