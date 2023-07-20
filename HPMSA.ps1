# Script de monitoring HP MSA
# RIR 17/02/2016

$hostname = $ARGS[0]
$username = $ARGS[1]
$password = $ARGS[2]
$check = $ARGS[3]
$login = $username+'@'+$hostname

$plink = "C:\Program Files (x86)\PRTG Network Monitor\Outils\plink.exe"

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

function get-match($state, $match){
	$count = 0
	if ($state -match $match) {
		$count = 1
	}
	$count
}

$statusOK = 0
$statusDegraded = 0
$statusFailed = 0
$customUnit = ""

if ($check -eq 'check_controller') {
    $command = "show controller | grep ^Status" # Status = Operational, Down, Not Installed, Unknown, Not Present
	$customUnit = "Controllers"
	$output = 'y' |& $plink -ssh $login -pw $password $command
	foreach($i in $output) {
		$statusOK+= get-match $i "Operational"
		$statusFailed+= get-match $i "Down"
	}

}

elseif ($check -eq 'check_disks') {
	$command = "show disks" # Status = Up, Spun Down, Warning, Error, Unknown, Not Present . Health = OK, Degraded, Fault, N/A, Unknown
	$customUnit = "Disks"
	$output = 'y' |& $plink -ssh $login -pw $password $command
	foreach($i in $output) {
		$statusOK+= get-match $i "OK"
		$statusDegraded+= get-match $i "Degraded"
		$statusFailed+= get-match $i "Fault"
	}
}

elseif ($check -eq 'check_vdisks') {
	$command = "show vdisks"
	$customUnit = "vDisks"
	foreach($i in $output) {
		$statusOK+= get-match $i "OK"
		$statusDegraded+= get-match $i "Degraded"
		$statusFailed+= get-match $i "Fault"
	}
}

elseif ($check -eq 'check_fans') {
	$command = "show fans" # Status = Up, Warning, Error, Not Present, Unknown
	$customUnit = "Fans"
	foreach($i in $output) {
		$statusOK+= get-match $i "Up"
		$statusDegraded+= get-match $i "Warning"
		$statusFailed+= get-match $i "Error"
	}
}
elseif ($check -eq 'check_powersupplies') {
	$command = "show power-supplies" # Health = OK, Degraded, Fault, Unknown
	$customUnit = "Power Supplies"
	foreach($i in $output) {
		$statusOK+= get-match $i "OK"
		$statusDegraded+= get-match $i "Degraded"
		$statusFailed+= get-match $i "Fault"
	}
}

elseif ($check -eq 'check_enclosure') {
	$command = "show enclosures" # (enclosure-status = Deprecated) Health = OK, Degraded, Fault, Unknown
	$customUnit = "Enclosures"
	foreach($i in $output) {
		$statusOK+= get-match $i "OK"
		$statusDegraded+= get-match $i "Degraded"
		$statusFailed+= get-match $i "Fault"
	}
}

elseif ($check -eq 'check_ports') {
	$command = "show ports" # Health = OK, Degraded, Fault, Unknown
	$customUnit = "Ports"
	foreach($i in $output) {
		$statusOK+= get-match $i "OK"
		$statusDegraded+= get-match $i "Degraded"
		$statusFailed+= get-match $i "Fault"
	}
}


$result = "<prtg>"
$statusOKChannel = get-channel "OK" $statusOK $customUnit $limitMode = 0
$statusDegradedChannel = get-channel "Degraded" $statusDegraded $customUnit $limitMode = 1 $limitMaxWarning = 0 $limitMaxError = 1
$statusFailedChannel = get-channel "Failed" $statusFailed $customUnit $limitMode = 1 $limitMaxWarning = 0 $limitMaxError = 0
$result+= "</prtg>"
$result