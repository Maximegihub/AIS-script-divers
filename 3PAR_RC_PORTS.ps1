# RIR (23/06/2016)

$hostname = $ARGS[0]
$username = $ARGS[1]
$password = $ARGS[2]
$plink = "C:\Program Files (x86)\PRTG Network Monitor\Outils\plink-0.58.exe"


$login = $username+'@'+$hostname


$command = "showrcopy links -nohdtot -csvtable"





function get-channel ($name,$status) {
		
	$channel = 
		"<result>
			<channel>$name</channel>
			<value>$status</value>
			<ValueLookup>prtg.standardlookups.activeinactive.stateactiveok</ValueLookup>
		</result>"
	
    $channel
}

function PRTG_error{

    $global:fail = "<prtg>

	    		<text>Connection Failed</text>
                <error>1</error>
                           		
    			</prtg>"		
    $fail

}

try {

    $rawData = 'y' |& $plink -ssh $login -pw $password  $command

    $result = "<prtg>"

    foreach ($data in $rawData) {

        $name = "Target: " + ($data -split (","))[0] + ", Node: " + ($data -split (","))[1]
        $state = ($data -split (","))[3]
        $status = 2

        if ($state -match "Up") {
            $status = 1
        }

        $result+= get-channel $name $status

    }

    $result += "</prtg>"
    
    $result
}
catch {
    PRTG_error
}




