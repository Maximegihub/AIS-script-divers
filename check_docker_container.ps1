# RIR 27/02/2017
# Script de monitoring d'un service fonctionnant à l'interieur d'un container Docker

# Exemple : Paramètres PRTG pour vérifier dans le container nginx l'état du service nginx 
# '%host' '%linuxuser' '%linuxpassword' 'nginx'

function get-channel ($name,$status) {

    $channel += @"
<result>
<channel>$name</channel>
<value>$status</value>
<ValueLookup>prtg.standardlookups.activeinactive.stateactiveok</ValueLookup>
</result>
"@
    $channel
}

function format-error {
    $global:fail = @"
<prtg>
<text>Connection or Parsing Failed</text>
<error>1</error>
</prtg>
"@
    $fail
}

$hostname = $ARGS[0]
$username = $ARGS[1]
$password = $ARGS[2]
$docker_name = $ARGS[3]

$login = $username+'@'+$hostname
$plink = "C:\Program Files (x86)\PRTG Network Monitor\Outils\plink-0.68.exe"
$sshCommand = "sudo docker ps -a"

$sshOutput = 'y' |& $plink -ssh $login -pw $password $sshCommand

$catch_container = $sshOutput |Where-Object { $_ -match $docker_name }

if ($catch_container) {

    $result = "<prtg>"
    $status = 2
    if($catch_container -cmatch " Up ") {
        $status = 1
    }
    $result+= get-channel $docker_name $status
    $result+= "</prtg>"
    $result
}
else {
    format-error "$docker_name container is unavailable"
}
