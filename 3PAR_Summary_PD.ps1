<# ====================================
 AUTEUR: Guillaume BOUTAIN
 DATE: 26/12/2012
 VERSION: 3.0
 TITRE: "3PAR_Summary_PD"
 ====================================

## VERSION ##

-V1.0 26/12/12 = Création du script
-V2.0 28/01/13 = Refonte pour PRTG
-V3.0 26/06/13 = Ajout SSD



## DESCRIPTION
Le script a pour but de relever les informations presentes dans summary des disques physiques.


## PREREQUIS ##
-Windows PowerShell
-Accès 3PAR (compte RO)
-Plink.exe



## ACTIONS ##

$ARG[0] = IP du serveur 		| 	'%host'
$ARG[1] = Linux username		|	'%linuxuser'
$ARG[2] = Linux Password		|	'%linuxpassword'
$ARG[3] = Chemin complet PLINK	|	'D:\sources\plink.exe'


#>

#############################################################


#=====================
#	 VARIABLES
#=====================
# Emplacement de PLINK
$plink = $args[3]


# Login des baies (preferer une authentification avec échange de clés)
$Username = $args[1]
$Password = $args[2]



$Inserv = $args[0]
$login = $Username+"@"+$Inserv



$ArrayFC = @()
$ArrayNL = @()
$ArraySSD = @()

# ===============================
# 			OVERVIEW   
# ===============================

	# Récupération des données
	$OverviewFC = & $plink -ssh $login -pw $password "showpd -showcols Volume_MB,Spare_MB,Free_MB,Failed_MB -p -devtype FC -csvtable"
	$OverviewNL = & $plink -ssh $login -pw $password "showpd -showcols Volume_MB,Spare_MB,Free_MB,Failed_MB -p -devtype NL -csvtable"
    $OverviewSSD = & $plink -ssh $login -pw $password "showpd -showcols Volume_MB,Spare_MB,Free_MB,Failed_MB -p -devtype SSD -csvtable"


	# Transformation des données en CSV
	$CsvOverviewFC = convertfrom-csv $OverviewFC[0..(($OverviewFC.Count)-3)]
	$CsvOverviewNL = convertfrom-csv $OverviewNL[0..(($OverviewNL.Count)-3)]
	$CsvOverviewSSD = convertfrom-csv $OverviewSSD[0..(($OverviewSSD.Count)-3)]

	# Totaux FC
	[INT]$FcVolume = [math]::Round(($CsvOverviewFC | Measure-Object -Property volume_mb -Sum).sum / 1024,0)
	[INT]$FcSpare = [math]::Round(($CsvOverviewFC | Measure-Object -Property spare_mb -Sum).sum / 1024,0)
	[INT]$FcFree = [math]::Round(($CsvOverviewFC | Measure-Object -Property free_mb -Sum).sum / 1024,0)
	[INT]$FcFailed = [math]::Round(($CsvOverviewFC | Measure-Object -Property Failed_mb -Sum).sum / 1024,0)
	[INT]$FcTotal = [math]::Round(($FcVolume+$FcSpare+$FcFree+$FcFailed),0)

	# Totaux NL
	[INT]$NlVolume = [math]::Round(($CsvOverviewNL | Measure-Object -Property volume_mb -Sum).sum / 1024,0)
	[INT]$NlSpare = [math]::Round(($CsvOverviewNL | Measure-Object -Property spare_mb -Sum).sum / 1024,0)
	[INT]$NlFree = [math]::Round(($CsvOverviewNL | Measure-Object -Property free_mb -Sum).sum / 1024,0)
	[INT]$NlFailed = [math]::Round(($CsvOverviewNL | Measure-Object -Property Failed_mb -Sum).sum / 1024,0)
	[INT]$NlTotal = [math]::Round(($NlVolume+$NlSpare+$NlFree+$NlFailed),0)

	# Totaux SSD
	[INT]$SSDVolume = [math]::Round(($CsvOverviewSSD | Measure-Object -Property volume_mb -Sum).sum / 1024,0)
	[INT]$SSDSpare = [math]::Round(($CsvOverviewSSD | Measure-Object -Property spare_mb -Sum).sum / 1024,0)
	[INT]$SSDFree = [math]::Round(($CsvOverviewSSD | Measure-Object -Property free_mb -Sum).sum / 1024,0)
	[INT]$SSDFailed = [math]::Round(($CsvOverviewSSD | Measure-Object -Property Failed_mb -Sum).sum / 1024,0)
	[INT]$SSDTotal = [math]::Round(($SSDVolume+$SSDSpare+$SSDFree+$SSDFailed),0)


$result = "<prtg>

<result>
		<channel>SSD 1-Total GB</channel>
		<value>$SSDTotal</value>
		<CustomUnit>GB</CustomUnit>
	</result>

	<result>
		<channel>SSD 2-Volumes GB</channel>
		<value>$SSDVolume</value>
		<CustomUnit>GB</CustomUnit>
	</result>

	<result>
		<channel>SSD 3-System Spare GB</channel>
		<value>$SSDSpare</value>
		<CustomUnit>GB</CustomUnit>
	</result>

	<result>
		<channel>SSD 4-Free GB</channel>
		<value>$SSDFree</value>
		<CustomUnit>GB</CustomUnit>
	</result>

	<result>
		<channel>SSD 5-Failed GB</channel>
		<value>$SSDFailed</value>
		<CustomUnit>GB</CustomUnit>
	</result>	
	

	<result>
		<channel>FC 1-Total GB</channel>
		<value>$FcTotal</value>
		<CustomUnit>GB</CustomUnit>
	</result>

	<result>
		<channel>FC 2-Volumes GB</channel>
		<value>$FcVolume</value>
		<CustomUnit>GB</CustomUnit>
	</result>

	<result>
		<channel>FC 3-System Spare GB</channel>
		<value>$FcSpare</value>
		<CustomUnit>GB</CustomUnit>
	</result>

	<result>
		<channel>FC 4-Free GB</channel>
		<value>$FcFree</value>
		<CustomUnit>GB</CustomUnit>
	</result>

	<result>
		<channel>FC 5-Failed GB</channel>
		<value>$FcFailed</value>
		<CustomUnit>GB</CustomUnit>
	</result>	
	
	<result>
		<channel>NL 1-Total GB</channel>
		<value>$NLTotal</value>
		<CustomUnit>GB</CustomUnit>
	</result>

	<result>
		<channel>NL 2-Volumes GB</channel>
		<value>$NLVolume</value>
		<CustomUnit>GB</CustomUnit>
	</result>

	<result>
		<channel>NL 3-System Spare GB</channel>
		<value>$NLSpare</value>
		<CustomUnit>GB</CustomUnit>
	</result>

	<result>
		<channel>NL 4-Free GB</channel>
		<value>$NLFree</value>
		<CustomUnit>GB</CustomUnit>
	</result>

	<result>
		<channel>NL 5-Failed GB</channel>
		<value>$NLFailed</value>
		<CustomUnit>GB</CustomUnit>
	</result>	
	
</prtg>"

$result





