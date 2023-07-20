# RIR (23/06/2016)

$hostname = $ARGS[0]
$username = $ARGS[1]
$password =  $ARGS[2]
$plink = "C:\Program Files (x86)\PRTG Network Monitor\Outils\plink-0.58.exe"


$login = $username+'@'+$hostname


$command = "showrcopy groups -nohdtot -csvtable"

$limitMaxWarning = 15
$limitMaxError = $limitMaxWarning 



function Treatment ($rawData) {

    $rawRCGs = ($rawData |Select-String -Pattern "^\S" |select Line,LineNumber)

    $channels = @()

    foreach ($rawRCG in $rawRCGs) {
        $rcgName= ($rawRCG.Line -split ",")[0]
        $rcgStatus= ($rawRCG.Line -split ",")[2]
        $status = 2

        if ($rcgStatus -match "Started") {

            $status = 1
        }

        $channels += get-channel-activeinactive "$rcgName Status" $status

        $lastSyncDateString = ($rawData[$rawRCG.LineNumber]).Split(",")[-1]

        if ($lastSyncDateString -match "NA") {

            $channels += get-channel "$rcgName LastSync Time" 999 "min" 1 $limitMaxWarning $limitMaxError "Last Sync Time threshold reached"

        }
        else {

            $lastSyncDateString = ($lastSyncDateString -replace "CEST|CET", "").Trim()
            $lastSyncDate = [datetime]::ParseExact($lastSyncDateString,"yyyy-MM-dd HH:mm:ss",$null)
            $lastSyncTimeSpan = [math]::Floor((NEW-TIMESPAN –Start $lastSyncDate –End (Get-Date) |Select-Object TotalMinutes).TotalMinutes)

            $channels += get-channel "$rcgName LastSync Time" $lastSyncTimeSpan "min" 1 $limitMaxWarning $limitMaxError "Last Sync Time threshold reached"
        }
    }


    $channels

}


function get-channel($name, $value, $customUnit = "", $limitMode = 0, $limitMaxWarning = 0, $limitMaxError = 0, $limitWarningMsg = "") {		

	$channel = 
		"<result>
			<channel>$name</channel>
			<value>$value</value>
			<CustomUnit>$customUnit</CustomUnit>
			<LimitMaxError>$limitMaxError</LimitMaxError>
			<LimitMaxWarning>$limitMaxWarning</LimitMaxWarning>
			<LimitWarningMsg>$limitWarningMsg</LimitWarningMsg>
			<LimitMode>$limitMode</LimitMode>
		</result>"
	$channel
	
}

function get-channel-activeinactive ($name,$status) {
		
	$channel = 
		"<result>
			<channel>$name</channel>
			<value>$status</value>
 			<ValueLookup>prtg.standardlookups.activeinactive.stateactiveok</ValueLookup>
		</result>"
	
    $channel
}

function PRTG_error{

    $global:fail = 
                "<prtg>

	    		    <text>Connection Failed</text>
                    <error>1</error>
                           		
    			</prtg>"		
    $fail

}

try {

    $output = 'y' |& $plink -ssh $login -pw $password $command
    $result = "<prtg>"
    $result += Treatment $output
    $result += "</prtg>"
    $result
}
catch {

   PRTG_error
}

