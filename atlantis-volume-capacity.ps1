
# RIR 13/10/2016

# Script PRTG : Récupère les valeurs Capacity Total, Free et Used d'un volume depuis un USX

# Paramètres PRTG : '%host' 'USX_8ed3be7c-2d96-30fb-9b54-0423684b2e48'

# Prérequis : Powershell v3


clear
Remove-Variable * -ErrorAction SilentlyContinue

$hostname = $ARGS[0]
$uuid = $ARGS[1]

$unit ="GB"

function get-data($hostname,$uuid,$datatype) {

    $url = "http://$hostname/usxmanager/metrics?target=servers.$uuid.VolumeCapacityCollector.$datatype&from=-3mins&until=now&format=json&noCache=false"
    $request = (New-Object System.Net.WebClient).DownloadString("$url")
    $datapoints = ($request | ConvertFrom-Json).datapoints
    $data = ($datapoints[0])[1]/1024/1024/1024
    $data
}


function get-channel($name, $value, $customUnit = "", $limitMode = 0, $limitMinWarning = 0, $limitMinError = 0) {		
	$channel = "
		<result>
			<channel>$name</channel>
			<value>$value</value>
            <float>1</float>
			<CustomUnit>$customUnit</CustomUnit>
			<LimitMinError>$limitMinError</LimitMinError>
			<LimitMinWarning>$limitMinWarning</LimitMinWarning>
			<LimitMode>$limitMode</LimitMode>
		</result>"
	
	$channel
}

$capacityTotal = [math]::Round((get-data $hostname $uuid "Capacity_Total"),3)
$capacityFree = [math]::Round((get-data $hostname $uuid "Capacity_Free"),3)
$capacityUsed = [math]::Round(($capacityTotal - $capacityFree),3)

$channel = "<prtg>"
$channel += get-channel "Capacity_Used" $capacityUsed $unit
$channel += get-channel "Capacity_Total" $capacityTotal $unit
$channel += get-channel "Capacity_Free" $capacityFree $unit 1 "100" "50"
$channel += "`n</prtg>"
$channel