param (
		[string]$ComputerName
		)

$smartmontools = "\\" + $ComputerName + "\C$\smartmontools"
$agentFolder = "\\" + $ComputerName + "\C$\zabbix-agent"
$zabbixServer = "10.0.14.253"
$LogFile = "c:\zabbix-agent\zabbix_agent.log"
$zabbixConf = $agentFolder + "\zabbix_agentd.conf"
$HostName = "Hostname=" + $ComputerName

New-Item -ItemType directory -Path $smartmontools -Force
New-Item -ItemType directory -Path $agentFolder -Force
Copy-Item -Path U:\~SOFTWARE\smartmontools\bin\smartctl.exe $smartmontools -Force
Copy-Item -Path U:\~SOFTWARE\zabbix-agent\conf\zabbix_agentd.conf $agentFolder -Force
Copy-Item -Path U:\~SOFTWARE\zabbix-agent\bin\win32\zabbix_agentd.exe $agentFolder -Force

(Get-Content $zabbixConf) -replace 'Hostname=Windows host', $Hostname | Set-Content $zabbixConf
(Get-Content $zabbixConf) | Foreach-Object {$_ -replace '127.0.0.1', $zabbixServer} | Set-Content $zabbixConf
(Get-Content $zabbixConf) -replace 'c:\\zabbix_agentd.log', $LogFile | Set-Content $zabbixConf