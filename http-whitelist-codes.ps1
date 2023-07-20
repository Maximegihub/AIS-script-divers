# RIR 17/07/2017
<#
    Curl avec whitelist de codes HTTP

    Paramètres PRTG (EXE/Script Advanced):
    - lien Web
    - liste de codes HTTP (SANS guillemets)
    Exemple:
    "http://10.10.41.38" 200,401,300

#>

$url = $ARGS[0]
$whitelist = $ARGS[1]

try {
    $exectime = [System.Diagnostics.Stopwatch]::StartNew()
    $a = Invoke-WebRequest -Uri $url -UseBasicParsing
    $exectime.Stop()
    $statusCode = $a.statuscode
    $statusDescription = $a.StatusDescription

}catch{
    $statusCode = $_.Exception.Response.StatusCode.Value__
    $statusDescription = $_.Exception.Message

}


if ($statusCode -notin $whitelist) {
    Write-Output "<prtg>"
    Write-Output "<error>1</error>"
    Write-Output "<text>$($url): $($statusDescription)</text>"
    Write-Output "</prtg>"
    Exit
}


write-host "<prtg>"

Write-Host "<result>"
Write-Host "<channel>ExecTime</channel>"
Write-Host "<value>$($exectime.ElapsedMilliseconds)</value>"
Write-Host "<CustomUnit>msecs</CustomUnit>"
Write-Host "</result>"

write-host "<text>Code $($statusCode) $($url)</text>"

write-host "</prtg>"
