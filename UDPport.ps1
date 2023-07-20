clear
Remove-Variable * -ErrorAction SilentlyContinue

$hostname = $ARGS[0]
$username = $ARGS[1]
$password =  $ARGS[2]
$port =  $ARGS[3]

$login = $username+'@'+$hostname

$plink = "C:\Program Files (x86)\PRTG Network Monitor\Outils\plink.exe"


function get-channel ($name,$status) {
		
	$channel += 
		"<result>
			<channel>$name</channel>
			<value>$status</value>
            <ValueLookup>prtg.standardlookups.activeinactive.stateactiveok</ValueLookup>
		</result>"
	
    $channel
}



$sshCommand = "netstat -tulpn | grep " + $port

$sshOutput = 'y' |& $plink -ssh $login -pw $password $sshCommand


$result += "<prtg>"
$status = 2

if ($sshOutput -ne " ") {
    $status = 1
}

$name = "Port " + $port
$result+= get-channel $name $status
$result += "</prtg>"

$result