$hostname = $ARGS[0]
$username = $ARGS[1]
$password =  $ARGS[2]



$login = $username+'@'+$hostname

$plink = "C:\Program Files (x86)\PRTG Network Monitor\Outils\plink.exe"
#$plink = "C:\plink.exe"

function get-channel ($name,$status) {
		
	$channel += 
		"<result>
			<channel>$name</channel>
			<value>$status</value>
            <ValueLookup>prtg.standardlookups.activeinactive.stateactiveok</ValueLookup>
		</result>"
	
    $channel
}


$names = @("pacemaker","corosync","sbd","libvirtd","multipathd","ipmi")
$sshOutput = @()

foreach ($name in $names) {
    $sshCommand = 'systemctl status ' + $name + ' | grep Active:'

    $sshOutput += 'y' |& $plink -ssh $login -pw $password $sshCommand

}



$result = "<prtg>"
$i = 0

foreach ($name in $names) {
    $status = 2

    if ($sshOutput[$i] -match "Active: active") {
        $status = 1
    }

    $result+= get-channel $name $status
    $i+=1
}

$result += "</prtg>"

$result