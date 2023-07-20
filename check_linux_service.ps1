# RIR 27/02/2017
# Script de monitoring d'un service fonctionnant sur un système linux

# Exemple : Paramètres PRTG pour vérifier l'état du service nginx 
# '%host' '%linuxuser' '%linuxpassword' 'nginx'

$hostname = $ARGS[0]
$username = $ARGS[1]
$password = $ARGS[2]
$service = $ARGS[3]
$login = $username+'@'+$hostname



$plink = "C:\Program Files (x86)\PRTG Network Monitor\Outils\plink-0.68.exe"


$sshCommand = "sudo systemctl status $service | grep 'Active:'"

function get-channel ($name,$status) {
		
	$channel += 
		"<result>
			<channel>$name</channel>
			<value>$status</value>
            <ValueLookup>prtg.standardlookups.activeinactive.stateactiveok</ValueLookup>
		</result>"
	
    $channel
}


$sshOutput = 'y' |& $plink -ssh $login -pw $password $sshCommand


$result = "<prtg>"
$status = 2
if ($sshOutput -match "running") {
    $status = 1
}

$result+= get-channel $service $status

$result+= "</prtg>"
$result
