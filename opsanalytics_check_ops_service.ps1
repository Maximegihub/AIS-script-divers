
# RIR 07/04/2017
<# Script de monitoring comptant le nombre d'indices suivant leur état:
    - GREEN : OK
    - YELLOW : warning
    - RED : error

    PRTG script Parameters (EXE Advanced):
    - '%host'
#>


$ip = $ARGS[0]

function get-channel-activeinactive($name, $value) {
    $channel = @"
<result>
<channel>$name</channel>
<value>$value</value>
<ValueLookup>prtg.standardlookups.activeinactive.stateactiveok</ValueLookup>
</result>
"@
    $channel

}

try {
    $URI = "${ip}:1337/nbu/diag"
    $request = Invoke-WebRequest -URI $URI -usebasicparsing
    $content = ($request.Content).Trim()
    $lines = $content -split '\n'
    $elastic_status = (&{If($lines -match "Elastic host OK") {1} Else {2}})
    $s3_status = (&{If($lines -match "S3 server OK") {1} Else {2}})

    $result = "<prtg>`n"
    $result += get-channel-activeinactive "Elastic Status" $elastic_status
    $result += get-channel-activeinactive "S3 server Status" $s3_status
    $result += "`n</prtg>"
    $result
}

catch {
    $global:fail = @"
<prtg>
<text>Connection or Parsing Failed</text>
<error>1</error>
</prtg>
"@
    $fail
}