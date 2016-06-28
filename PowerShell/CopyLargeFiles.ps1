Import-Module BitsTransfer

# adjust source and destination to your needs:
$Source = "C:\Images\*.ISO"
$Destination = "C:\BackupFolder\"

if ( (Test-Path $Destination) -eq $false) 
{
    $null = New-Item -Path $Destination -ItemType Directory 
}

Start-BitsTransfer -Source $Source -Destination $Destination -Description "Backup" -DisplayName "Backup"