# RIR (23/06/2016)

$hostname = $ARGS[0]
$username = $ARGS[1]
$password = $ARGS[2]
$selection = $ARGS[3]
$plink = "C:\Program Files (x86)\PRTG Network Monitor\Outils\plink-0.58.exe"


$login = $username+'@'+$hostname

$command = "statvlun -iter 1 -d 200 -csvtable"


function get-channel($name, $value, $customUnit = "", $limitMode = 0, $limitMaxWarning = 0, $limitMaxError = 0, $limitWarningMsg = "") {		
	$channel = 
		"<result>
			<channel>$name</channel>
			<value>$value</value>
 			<float>1</float>
			<CustomUnit>$customUnit</CustomUnit>
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

    $rawData = 'y' |& $plink -ssh $login -pw $password  $command

    # total IOPS, KBps, Svt
    $totalData = $rawData[$rawData.Length -2]


    $result = "<prtg>"

    if ($selection -eq "IOPS") {

        $IOPS = ($totalData -split (","))[5]
        $result+= get-channel "Total" $IOPS "IOPS"
    }

    if ($selection -eq "KBps") {

        $KBps = ($totalData -split (","))[8]
        $result+= get-channel "Total" $KBps "KBps"
    }

    if ($selection -eq "Svt") {

        $Svt = ($totalData -split (","))[11]
        $result+= get-channel "Total" $Svt "ms"
    }


    $rawData = $rawData[2 ..($rawData.Length -4)]

    foreach ($data in $rawData) {

        $name = "VVname: " + ($data -split (","))[1] + ", LUN: " + ($data -split (","))[0] + ", Port: " + ($data -split (","))[3]

        if ($selection -eq "IOPS") {

            $IOPS = ($data -split (","))[5]
            $result+= get-channel $name $IOPS "IOPS"
        }

        if ($selection -eq "KBps") {

            $KBps = ($data -split (","))[8]
            $result+= get-channel $name $KBps "KBps"
        }

        if ($selection -eq "Svt") {

            $Svt = ($data -split (","))[11]
            $result+= get-channel $name $Svt "ms"   
        }
    }

    $result += "</prtg>"

    $result

}
catch {

    PRTG_error
}