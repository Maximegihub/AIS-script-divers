
# RIR 07/04/2017
<# Script de monitoring comptant le nombre d'indices suivant leur état:
    - GREEN : OK
    - YELLOW : warning
    - RED : error

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

    $URI = "${ip}:9200/_cat/indices?v"
    $request = Invoke-WebRequest -URI $URI -usebasicparsing
    $content = ($request.Content).Trim()
    $lines = $content -split '\n'
    $table = $lines -replace '\s{1,}', "|" | ConvertFrom-Csv -Delimiter "|"
    $green = ($table | Where-Object {$_.health -eq 'green'}| Measure-Object).Count
    $yellow = ($table | Where-Object {$_.health -eq 'yellow'} | Measure-Object).Count
    $red = ($table | Where-Object {$_.health -eq 'red'} | Measure-Object).Count

    $result = "<prtg>`n"
    $result += get-channel "green" $green 'indices'
    $result += get-channel "red" $red 'indices' 1 0 0 '' 'CRITICAL: Some indices are in bad health'
    $result += get-channel "yellow" $yellow 'indices' 1 0 100000 'There are warnings on some indices'
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