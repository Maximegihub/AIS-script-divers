
# RIR (18/08/2016)
# Script de Monitoring de partitions Windows, avec prise en compte de celles sans lettre

## Paramètres PRTG
# '%host' '%windowsdomain' '%windowsuser' '%windowspassword'
<#
	Allowing Remote Powershell session.

	On the remote server :
	- Run Windows PowerShell as Administrator
	- Enable-PSRemoting -Force

	If the computers are not on a domain, run on both computers :
	- Set-Item wsman:\localhost\client\trustedhosts *
	- Restart-Service WinRM

	Test from the local server
	- Test-WsMan <remote server>
#>


$IP = $ARGS[0]
$domain = $ARGS[1]
$login = $ARGS[2]
$password =  $ARGS[3]

$username = $domain + "\" + $login



function main-function {
	$securePass = convertto-securestring -AsPlainText -Force -String $password
	$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$securePass
	
	# Connection to remote session
	$session = new-pssession -computername $IP -credential $cred

	# command to remote session
	$rawData = Invoke-Command -session $session -scriptblock { Get-WmiObject -Class Win32_Volume }

	# End session
	Remove-PSSession -Session $session

	# Format Data
	$volumes = $rawData | where {$_.Capacity -gt 0 -and $_.Label -ne "System Reserved"} | select Label,DriveLetter,FreeSpace,Capacity 
	$volumes | foreach { $_ | Add-Member -MemberType NoteProperty -Name "FreePerc" -Value ([math]::Round(($_.Freespace/$_.Capacity)*100,3))}



	# prtg
	$result = "<prtg>"

	$volumes | foreach {
		$result += get-channel-Min-limits ($_.Label + $_.DriveLetter + " Free") $_.FreePerc "%" 1 15 10
		$result += get-channel ($_.Label + $_.DriveLetter + " Free Bytes") ([math]::Round($_.Freespace/1GB,3)) "GB"
		$result += get-channel ($_.Label + $_.DriveLetter + " Capacity") ([math]::Round($_.Capacity/1GB,3)) "GB"
	}

	$result += "`n</prtg>"
	$result
}

function get-channel($name, $value, $customUnit = "") {

	$channel = "
	<result>
		<channel>$name</channel>
		<value>$value</value>
		<CustomUnit>$customUnit</CustomUnit>
		<float>1</float>
	</result>"

	$channel
	
}

function get-channel-Min-limits($name, $value, $customUnit = "", $limitMode = 0, $limitMinWarning = 0, $limitMinError = 0) {
	$channel = "
	<result>
		<channel>$name</channel>
		<value>$value</value>
		<CustomUnit>$customUnit</CustomUnit>
		<LimitMinError>$limitMinError</LimitMinError>
		<LimitMinWarning>$limitMinWarning</LimitMinWarning>
		<LimitMode>$limitMode</LimitMode>
		<float>1</float>
	</result>"
	
	$channel
}

main-function