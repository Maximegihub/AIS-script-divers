$hostname = $ARGS[0]
$username = $ARGS[1]
$password =  $ARGS[2]

$login = $username+'@'+$hostname

$plink = "C:\Program Files (x86)\PRTG Network Monitor\Outils\plink.exe"


$sshCommand = '. /root/scripts/logcount.sh'
$sshOutput = 'y' |& $plink -ssh $login -pw $password $sshCommand

[int]$intNum = [convert]::ToInt32($sshOutput, 10)


$channel = "<prtg>
            <result>
			<channel>Log 5min</channel>
            <unit>lines</unit>
			<value>$intNum</value>
            </result>
            </prtg>"
	
$channel