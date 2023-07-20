# RIR 27/02/2017
# Script de monitoring d'un service fonctionnant à l'interieur d'un container Docker

# Exemple : Paramètres PRTG pour vérifier dans le container nginx l'état du service nginx 
# '%host' '%linuxuser' '%linuxpassword' 'nginx'

function get-channel ($name,$value,$customUnit = "") {

    $channel += @"
<result>
<channel>$name</channel>
<value>$value</value>
<CustomUnit>$customUnit</CustomUnit>
<float>1</float>
</result>
"@
    $channel
}

function format-error ($message) {
    $global:fail = @"
<prtg>
<text>$message</text>
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

$sshCommand = "sudo docker inspect --format='{{.State.StartedAt}}' $docker_name"

try {
    $sshOutput = 'y' |& $plink -ssh $login -pw $password $sshCommand

    $uptime = (New-TimeSpan -End ([DateTime]::UtcNow) -Start $sshOutput).TotalDays
    $uptime = If($uptime -gt 0) {[math]::Round($uptime, 3)} else {0}
    $result = "<prtg>"
    $result+= get-channel "$docker_name uptime" $uptime "Days"
    $result+= "</prtg>"
    $result
}
catch {
    format-error "$docker_name container is down"
}
