
# RIR 07/04/2017
<# Script de monitoring comptant le nombre d'indices suivant leur état:
    - GREEN : OK
    - YELLOW : warning
    - RED : error

    PRTG script Parameters (EXE Advanced):
    - '%host'
#>


$ip = $ARGS[0]

function get-channel($name, $value, $customUnit = "") {
    $channel = @"
<result>
<channel>$name</channel>
<value>$value</value>
<float>1</float>
<CustomUnit>$customUnit</CustomUnit>
</result>
"@
    $channel

}

try{
    #retrieve total
    $URI = "${ip}:9200/nbu*/_search?size=1&pretty&sort=meta.localtime:asc&_source_include=meta.localtime"
    $request = Invoke-WebRequest -URI $URI -usebasicparsing
    $content = ($request.Content).Trim()
    $json_total = $content | ConvertFrom-Json
    $es_files_count = $json_total.hits.total

    # retrieve latest indexed file date
    $URI = "${ip}:9200/nbu*/_search?size=1&pretty&sort=meta.localtime:desc&filter_path=**.localtime"
    $request = Invoke-WebRequest -URI $URI -usebasicparsing
    $content = ($request.Content).Trim()
    $json_latest = $content | ConvertFrom-Json
    $latest_indexed = $json_latest.hits.hits._source.meta.localtime
    $latest_indexed = [datetime]$latest_indexed
    $since_indexed = (New-TimeSpan -Start $latest_indexed -End (Get-Date)).TotalMinutes
    $since_indexed = [math]::floor($since_indexed)

    $result = "<prtg>`n"
    $result += get-channel "Time since last indexed file" $since_indexed "minutes"
    $result += get-channel "Elasticsearch files" $es_files_count "files"
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