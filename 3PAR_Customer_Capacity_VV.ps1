<# ====================================
 AUTEUR: Guillaume BOUTAIN
 DATE: 01/07/2013
 VERSION: 0.1
 TITRE: "3PAR_Customer_Capacity_VV_v0.1"
 ====================================

## VERSION ##

-V0.1 01/07/2013 = Création du script





## DESCRIPTION
Le script a pour but de faire deux channel par client 
Script advanced/exe
Chaques channels comportent :
-Espace Vsize en GB
-Espace Usr_Rsvd en GB



## PREREQUIS ##
-Windows PowerShell
-Plink


## ACTIONS ##

$ARGS[0] = IP du serveur | 	'%host'
$ARGS[1] = User			|	'%linuxuser'
$ARGS[2] = Password		|	'%linuxpassword'




#>

$Inserv = $ARGS[0]
$Username = $ARGS[1]
$Password = $ARGS[2]


$plink = "C:\Program Files (x86)\PRTG Network Monitor\Outils\plink-0.58.exe"

$login = $Username+"@"+$Inserv

		echo y | & $plink -ssh $login -pw $password "exit"
	  $VV = & $plink -ssh $login -pw $password "showvv -showcols Name,VSize_MB,Usr_Rsvd_MB,Type -csvtable" 
	$vv= $vv[0..($VV.Count - 3)]
	$VV = convertfrom-Csv $vv
	$VV = $VV | ? {$_.type -eq "base"} | ?{$_.name -match "_"}

$client = @()

foreach ($c in $vv){

#$c.Name.Substring(0,($c.name.indexof("_")))

$Details = New-object PSObject
$Details | Add-member -Name "Client" -membertype noteproperty -value ($c.Name.Substring(0,($c.name.indexof("_"))))
$client += $Details
}

$client = $client |select client | Get-Unique -AsString
$mycollection = @()

foreach ($a in $client){

	foreach($v in ($vv| ?{$_.name -match $a.Client})){
	
	 $Details = New-object PSObject
	 $Details | Add-member -Name "Name" -membertype noteproperty -value $a.Client
	 $Details | Add-member -Name "VSize_GB" -membertype noteproperty -value ([math]::Round($v.VSize_MB / 1024))
	 $Details | Add-member -Name "Usr_Rsvd_GB" -membertype noteproperty -value ([math]::Round($v.Usr_Rsvd_MB / 1024))
	 $MyCollection += $Details
	}
}


$mycollectionT = @()

foreach ($b in $client){
$Details = New-object PSObject
$Details | Add-member -Name "Client" -membertype noteproperty -value $b.client
$Details | Add-member -Name "VSize_GB" -membertype noteproperty -value ($mycollection | where {$b.client -contains $_.name} | Measure-Object -Sum -Property VSize_GB).sum
$Details | Add-member -Name "Usr_Rsvd_GB" -membertype noteproperty -value ($mycollection | where {$b.client -contains $_.name} | Measure-Object -Sum -Property Usr_Rsvd_GB).sum
$MyCollectionT += $Details
}

$result =  "<prtg>"

foreach ($t in $mycollectionT){

$client_name = $t.client
$Client_Vsize_GB = $t.Vsize_GB
$client_Usr_Rsvd_GB = $t.Usr_Rsvd_GB

$result += "<result>
		<channel>$client_name 1-Vsize_GB</channel>
		<value>$Client_Vsize_GB</value>
		<CustomUnit>GB</CustomUnit>
	</result>

	<result>
		<channel>$client_name 2-Usr_Rsvd_GB</channel>
		<value>$client_Usr_Rsvd_GB</value>
		<CustomUnit>GB</CustomUnit>
	</result>"


}

$result += "</prtg>"


$result