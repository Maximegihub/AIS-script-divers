
# RIR 07/04/2017
<# Script de monitoring comptant le nombre de shards suivant leur état:
    - STARTED
    - UNASSIGNED p (primary)
    - UNASSIGNED r (replica)
    Les unassigned_primary remontent des errors, les unassigned_replica des warnings

    PRTG script Parameters (EXE Advanced):
    - '%host'
#>


$ip = $ARGS[0]

function get-channel($name, $value, $customUnit = "", $limitMode = 0, $limitMaxWarning = 0, $limitMaxError = 0, $limitWarningMsg = "", $limitErrorMsg = "") {		
    $channel = @"
<result>
<channel>$name</channel>
<value>$value</value>
<float>1</float>
<CustomUnit>$customUnit</CustomUnit>
<LimitMaxWarning>$limitMaxWarning</LimitMaxWarning>
<LimitWarningMsg>$limitWarningMsg</LimitWarningMsg>
<LimitMaxError>$limitMaxError</LimitMaxError>
<LimitErrorMsg>$limitErrorMsg</LimitErrorMsg>
<LimitMode>$limitMode</LimitMode>
</result>
"@
    $channel

}

try{
    $URI = "${ip}:9200/_cat/shards?v"
    $request = Invoke-WebRequest -URI $URI -usebasicparsing
    $content = ($request.Content).Trim()
    $lines = $content -split '\n'
    $table = $lines -replace '\s{1,}', "|" | ConvertFrom-Csv -Delimiter "|"
    $started = ($table | Where-Object {$_.state -eq 'STARTED'}| Measure-Object).Count
    $unassigned = $table | Where-Object {$_.state -eq 'UNASSIGNED'}
    $unassigned_primary = ($unassigned | Where-Object {$_.prirep -eq 'p'} | Measure-Object).Count
    $unassigned_replica = ($unassigned | Where-Object {$_.prirep -eq 'r'} | Measure-Object).Count

    $result = "<prtg>`n"
    $result+= get-channel "STARTED" $started 'shards'
    $result+= get-channel "UNASSIGNED PRIMARY" $unassigned_primary 'shards' 1 0 0 '' 'CRITICAL: Some primary shards are unassigned'
    $result+= get-channel "UNASSIGNED REPLICA" $unassigned_replica 'shards' 1 0 100000 'Some replicas are unassigned'
    $result+= "`n</prtg>"
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