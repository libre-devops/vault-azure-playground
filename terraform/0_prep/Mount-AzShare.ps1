param (
    [Parameter(Mandatory=$true)]
    [string]$storageAccountName,

    [Parameter(Mandatory=$true)]
    [string]$storageAccountKey,

    [Parameter(Mandatory=$true)]
    [string]$fileShareName
)

$connectTestResult = Test-NetConnection -ComputerName $storageAccountName.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"$storageAccountName.file.core.windows.net`" /user:`"Azure\$storageAccountName`" /pass:`"$storageAccountKey`""
    # Mount the drive
    New-SmbMapping -LocalPath Z: -RemotePath \\$storageAccountName.file.core.windows.net\$fileShareName -Persistent $true
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
