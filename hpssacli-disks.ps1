# ﻿RIR (20/07/2016)
# check logical and physical disks using hpssacli

# PRTG parameters : '%host' '%linuxuser' '%linuxpassword'

$hostname = $ARGS[0]
$username = $ARGS[1]
$password = $ARGS[2]
$plink = "C:\Program Files (x86)\PRTG Network Monitor\Outils\plink-0.58.exe"

$login = $username+'@'+$hostname

$command = "hpssacli ctrl all show config"


function get-channel-status ($name,$status) {
    #<Lookups>
    #  <SingleInt state="None" value="1">
    #    Other
    #  <SingleInt state="Ok" value="2">
    #    OK
    #  <SingleInt state="Warning" value="3">
    #    Degraded
    #  <SingleInt state="Error" value="4">
    #    Failed

	$channel = "
		<result>
			<channel>$name</channel>
			<value>$status</value>
 			<ValueLookup>prtg.standardlookups.hp.status</ValueLookup>
		</result>"
	
	$channel
}

$rawData = 'y' |& $plink -ssh $login -pw $password $command
$drives = ($rawData -match 'physicaldrive|logicaldrive').Trim()

$result = "<prtg>"

foreach ($drive in $drives) {

	$name = (($drive.split('('))[0]).Trim()

	$state = (($drive.split(','))[-1] -replace '.$').Trim()

	if ($state -eq "OK") {
		$result += get-channel-status $name 2
	}

	elseif ($state -eq "Failed") {
		$result += get-channel-status $name 4
	}

	else {
		# Rebuilding, Ready for Rebuild, Recovering xx% complete, ...
		$result += get-channel-status $name 3
	}
}


$result += "`n</prtg>"
$result