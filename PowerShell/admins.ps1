$Computer = $env:COMPUTERNAME
$ADSIComputer = [ADSI]("WinNT://$Computer,computer")
$group = $ADSIComputer.psbase.children.find('Администраторы', 'Group')
$group.psbase.invoke("members") | ForEach{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}