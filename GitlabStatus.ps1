# Script de monitoring des services Gitlab
# RIR 12/02/2016

$hostname = $ARGS[0]
$username = $ARGS[1]
$password =  $ARGS[2]
$login = $username+'@'+$hostname

$plink = "C:\Program Files (x86)\PRTG Network Monitor\Outils\plink-0.58.exe"

$sshCommand = "gitlab-ctl status"

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

if (!($sshOutput -match "gitlab")) {
    $result = 
		"<prtg>
    		<text>Connection failed</text>
			<error>1</error>
    	</prtg>"

    $result

}
else {

    $result = "<prtg>"

    foreach ($output in $sshOutput) {
        $status = 2
        $name = $output.split(":")[1]
        $statusName = $output.split(":")[0]
        if ($statusName -like "run") {
            $status = 1
        }

        $result+= get-channel $name $status
    }

    $result+= "</prtg>"
    $result

}












