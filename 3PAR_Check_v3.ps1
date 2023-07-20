<# ====================================
 AUTEUR: Geoffrey LEPERS
 DATE: 19/03/2014
 VERSION: 1.0
 TITRE: "3PAR_Check_V3"
 ====================================

## VERSION ##

-V1.0 19/03/14 = Création du script

## DESCRIPTION
Le script a pour but de recuperer le status des disques
Script advanced/exe

Channel :
-OK
-DEGRADED
-EXPIRED
-FAILED


## PREREQUIS ##
-Windows PowerShell
-Plink
-Compte RO sur la baie


## ACTIONS ##

$ARG[0] = IP du device			| 	'%host'
$ARG[1] = User				|	'%linuxuser'
$ARG[2] = Password			|	'%linuxpassword'


#>
$Username = $ARG[1]
$Password = $ARG[2]
$Inserv = $ARG[0]
$plink ="C:\Program Files (x86)\PRTG Network Monitor\Outils\plink-0.58.exe"

$login = $Username+"@"+$Inserv

# =============================================================
#						CHECK_PD
# =============================================================

if ($ARGS[3] -eq 'check_pd') {

# Recuperation de l'ensemble des disques de la baie
$pd_state = &$plink -v -ssh $login -pw $password "showpd -showcols Id,State -nohdtot" 

# Calcul nombre de disque OK
$nb_PD_Normal = ($pd_state | select-string "normal" | measure-object).count

# Calcul nombre de disque Degraded
$nb_PD_Degraded = ($pd_state | select-string "degraded" | measure-object).count

# Calcul nombre de disque Failed
$nb_PD_Failed = ($pd_state | select-string "failed" | measure-object).count

# Traitement Channel PRTG
$result = "<prtg>

			<result>
			<channel>OK</channel>
			<value>$nb_PD_Normal</value>
			<CustomUnit>DISK</CustomUnit>
			</result>
			
			<result>
			<channel>Degraded</channel>
			<value>$nb_PD_Degraded</value>
			<CustomUnit>DISK</CustomUnit>
			</result>
			
			<result>
			<channel>Failed</channel>
			<value>$nb_PD_Failed</value>
			<CustomUnit>DISK</CustomUnit>
			<LimitMaxError>1</LimitMaxError>
            <LimitMaxWarning>0</LimitMaxWarning>
    		<LimitWarningMsg>$nb_PD_Failed</LimitWarningMsg>
    		<LimitMode>1</LimitMode>
			</result>
						
			</prtg>"
			
$result	
}

# =============================================================
#						CHECK_BATTERY
# =============================================================

if ($ARGS[3] -eq 'check_battery') {

# Recuperation de l'ensemble des battery de la baie
$battery_state = & $plink -ssh $login -pw $password "showbattery -showcols Node,State,Expired -nohdtot"

# Calcul nombre de battery OK
$nb_BATTERY_Normal = ($battery_state | select-string "OK" | measure-object).count

# Calcul nombre de battery Degraded
$nb_BATTERY_Degraded = ($battery_state | select-string "degraded" | measure-object).count

# Calcul nombre de battery Expired
#$nb_BATTERY_Expired = ($battery_state | select-string "expired" | measure-object).count

# Calcul nombre de battery Failed
$nb_BATTERY_Failed = ($battery_state | select-string "failed" | measure-object).count

# Traitement Channel PRTG
$result = "<prtg>

			<result>
			<channel>OK</channel>
			<value>$nb_BATTERY_Normal</value>
			<CustomUnit>BATTERY</CustomUnit>
			</result>
			
			<result>
			<channel>Degraded</channel>
			<value>$nb_BATTERY_Degraded</value>
			<CustomUnit>BATTERY</CustomUnit>
			</result>
            
            <result>
			<channel>Expired</channel>
			<value>$nb_BATTERY_Expired</value>
			<CustomUnit>BATTERY</CustomUnit>
			</result>
			
			<result>
			<channel>Failed</channel>
			<value>$nb_BATTERY_Failed</value>
			<CustomUnit>BATTERY</CustomUnit>
			<LimitMaxError>1</LimitMaxError>
            <LimitMaxWarning>0</LimitMaxWarning>
    		<LimitWarningMsg>$nb_BATTERY_Failed</LimitWarningMsg>
    		<LimitMode>1</LimitMode>
			</result>
						
			</prtg>"
			
$result	
}
# =============================================================
#						CHECK_BATTERY_v2
# =============================================================

if ($ARGS[3] -eq 'check_battery_v2') {

# Recuperation de l'ensemble des battery de la baie
$battery_state = & $plink -ssh $login -pw $password "showbattery -s"

# Calcul nombre de battery OK
$nb_BATTERY_Normal = ($battery_state | select-string "OK" | measure-object).count

# Calcul nombre de battery Degraded
$nb_BATTERY_Degraded = ($battery_state | select-string "degraded" | measure-object).count

# Calcul nombre de battery Expired
#$nb_BATTERY_Expired = ($battery_state | select-string "expired" | measure-object).count

# Calcul nombre de battery Failed
$nb_BATTERY_Failed = ($battery_state | select-string "failed" | measure-object).count

# Traitement Channel PRTG
$result = "<prtg>

			<result>
			<channel>OK</channel>
			<value>$nb_BATTERY_Normal</value>
			<CustomUnit>BATTERY</CustomUnit>
			</result>
			
			<result>
			<channel>Degraded</channel>
			<value>$nb_BATTERY_Degraded</value>
			<CustomUnit>BATTERY</CustomUnit>
			</result>
            
            <result>
			<channel>Expired</channel>
			<value>$nb_BATTERY_Expired</value>
			<CustomUnit>BATTERY</CustomUnit>
			</result>
			
			<result>
			<channel>Failed</channel>
			<value>$nb_BATTERY_Failed</value>
			<CustomUnit>BATTERY</CustomUnit>
			<LimitMaxError>1</LimitMaxError>
            <LimitMaxWarning>0</LimitMaxWarning>
    		<LimitWarningMsg>$nb_BATTERY_Failed</LimitWarningMsg>
    		<LimitMode>1</LimitMode>
			</result>
						
			</prtg>"
			
$result	
}

# =============================================================
#						CHECK_NODE
# =============================================================

if ($ARGS[3] -eq 'check_node') {
# Recuperation de l'ensemble des nodes de la baie
$node_state = & $plink -ssh $login -pw $password "shownode -s -nohdtot"

# Calcul nombre de nodes OK
$nb_NODE_Normal = ($node_state | select-string "OK" | measure-object).count

# Calcul nombre de nodes Degraded
$nb_NODE_Degraded = ($node_state | select-string "degraded" | measure-object).count

# Calcul nombre de nodes Failed
$nb_NODE_Failed = ($node_state | select-string "failed" | measure-object).count

# Traitement Channel PRTG
$result = "<prtg>

			<result>
			<channel>OK</channel>
			<value>$nb_NODE_Normal</value>
			<CustomUnit>NODE</CustomUnit>
			</result>
			
			<result>
			<channel>Degraded</channel>
			<value>$nb_NODE_Degraded</value>
			<CustomUnit>NODE</CustomUnit>
			<LimitMaxWarning>0</LimitMaxWarning>
    		<LimitWarningMsg>$nb_NODE_Degraded</LimitWarningMsg>
    		<LimitMode>1</LimitMode>
			</result>
            			
			<result>
			<channel>Failed</channel>
			<value>$nb_NODE_Failed</value>
			<CustomUnit>NODE</CustomUnit>
			<LimitMaxError>1</LimitMaxError>
    		<LimitMode>1</LimitMode>
			</result>
						
			</prtg>"
			
$result	
}

# =============================================================
#						CHECK_PORT
# =============================================================

 
if ($ARGS[3] -eq 'check_port') {
# Recuperation de l'ensemble des ports de la baie
$port_state = & $plink -ssh $login -pw $password "showport -state -nohdtot"

# Calcul nombre de ports OK
$nb_PORT_Normal = ($port_state | select-string "ready" | measure-object).count

# Calcul nombre de ports Degraded
if (($port_state | select-string "loss_sync" | measure-object ).count  -gt '0'){
	$nb_PORT_Degraded = ($port_state | select-string "loss_sync" | measure-object).count
}

elseif (($port_state | select-string "config_wait" | measure-object ).count -gt '0' ){
	$nb_PORT_Degraded = ($port_state | select-string "config_wait" | measure-object).count
}

elseif (($port_state | select-string "login_wait" | measure-object ).count -gt '0' ){
	$nb_PORT_Degraded = ($port_state | select-string "login_wait" | measure-object).count
}

elseif (($port_state | select-string "non_participate" | measure-object ).count -gt '0' ){
	$nb_PORT_Degraded = ($port_state | select-string "non_participate" | measure-object).count
}

# Calcul nombre de ports Failed
$nb_PORT_Failed = ($port_state | select-string "error" | measure-object).count

# Traitement Channel PRTG
$result = "<prtg>

			<result>
			<channel>OK</channel>
			<value>$nb_PORT_Normal</value>
			<CustomUnit>PORTS</CustomUnit>
			</result>
			
			<result>
			<channel>Degraded</channel>
			<value>$nb_PORT_Degraded</value>
			<CustomUnit>PORTS</CustomUnit>
            		<LimitMaxWarning>0</LimitMaxWarning>
			<LimitWarningMsg>(loss_sync, config_wait, login_wait or non_participate)</LimitWarningMsg>
			<LimitMode>1</LimitMode>
			</result>
			
			<result>
			<channel>Failed</channel>
			<value>$nb_PORT_Failed</value>
			<CustomUnit>PORTS</CustomUnit>
			<LimitMaxError>1</LimitMaxError>
            		<LimitMaxWarning>0</LimitMaxWarning>
    			<LimitWarningMsg>$nb_PORT_Failed</LimitWarningMsg>
    			<LimitMode>1</LimitMode>
			</result>
						
			</prtg>"
			
$result	
}

# =============================================================
#						CHECK_VV
# =============================================================
 
if ($ARGS[3] -eq 'check_vv') {
# Recuperation de l'ensemble des virtual volumes de la baie
$vv_state = & $plink -ssh $login -pw $password "showvv -showcols Name,State -notree -nohdtot"

# Calcul nombre de virtual volumes OK
$nb_VV_Normal = ($vv_state | select-string "normal" | measure-object).count

# Calcul nombre de virtual volumes Degraded
$nb_VV_Degraded = ($vv_state | select-string "degraded" | measure-object).count

# Calcul nombre de virtual volumes Failed
$nb_VV_Failed = ($vv_state | select-string "failed" | measure-object).count

# Traitement Channel PRTG
$result = "<prtg>

			<result>
			<channel>OK</channel>
			<value>$nb_VV_Normal</value>
			<CustomUnit>VV</CustomUnit>
			</result>
			
			<result>
			<channel>Degraded</channel>
			<value>$nb_VV_Degraded</value>
			<CustomUnit>VV</CustomUnit>
			</result>
			
			<result>
			<channel>Failed</channel>
			<value>$nb_VV_Failed</value>
			<CustomUnit>VV</CustomUnit>
            <LimitMaxError>1</LimitMaxError>
            <LimitMaxWarning>0</LimitMaxWarning>
    		<LimitWarningMsg>nb_VV_Failed</LimitWarningMsg>
    		<LimitMode>1</LimitMode>
			</result>
						
			</prtg>"
			
$result
}

# =============================================================
#						CHECK_SFP
# =============================================================
 
if ($ARGS[3] -eq 'check_sfp') {

# Recuperation de l'ensemble des sfp de la baie
$sfp_state = & $plink -ssh $login -pw $password "showport -sfp -nohdtot"

# Calcul nombre de sfp OK
$nb_SFP_Normal = ($sfp_state | select-string "OK" | measure-object).count

# Calcul nombre de sfp Failed
$nb_SFP_Failed = ($sfp_state | select-string "failed" | measure-object).count

# Traitement Channel PRTG
$result = "<prtg>

			<result>
			<channel>OK</channel>
			<value>$nb_SFP_Normal</value>
			<CustomUnit>SFP</CustomUnit>
			</result>
			
			<result>
			<channel>Failed</channel>
			<value>$nb_SFP_Failed</value>
			<CustomUnit>SFP</CustomUnit>
			<LimitMaxError>1</LimitMaxError>
            <LimitMaxWarning>0</LimitMaxWarning>
    		<LimitWarningMsg>$nb_SFP_Failed</LimitWarningMsg>
    		<LimitMode>1</LimitMode>
			</result>
						
			</prtg>"
			
$result	
}

# =============================================================
#			CHECK_NODEPS  (POWER SUPPLY)
# =============================================================

if ($ARGS[3] -eq 'check_nodeps') {

# Recuperation de l'ensemble des powersupply des nodes de la baie
$ps_state = & $plink -ssh $login -pw $password "shownode -ps -showcols Node,PSState -nohdtot"

# Calcul nombre de powersupply OK
$nb_PS_Normal = ($ps_state | select-string "OK" | measure-object).count

# Calcul nombre de powersupply Degraded
$nb_PS_Degraded = ($ps_state | select-string "degraded" | measure-object).count

# Calcul nombre de powersupply Failed
$nb_PS_Failed = ($ps_state | select-string "failed" | measure-object).count

# Traitement Channel PRTG
$result = "<prtg>

			<result>
			<channel>OK</channel>
			<value>$nb_PS_Normal</value>
			<CustomUnit>PS</CustomUnit>
			</result>
			
			<result>
			<channel>Degraded</channel>
			<value>$nb_PS_Degraded</value>
			<CustomUnit>PS</CustomUnit>
			</result>
			
			<result>
			<channel>Failed</channel>
			<value>$nb_PS_Failed</value>
			<CustomUnit>PS</CustomUnit>
			<LimitMaxError>1</LimitMaxError>
            <LimitMaxWarning>0</LimitMaxWarning>
			<LimitWarningMsg>$nb_PS_Failed</LimitWarningMsg>
    		<LimitMode>1</LimitMode>
			</result>
						
			</prtg>"
			
$result	
}

# =============================================================
#			CHECK_NODEPS  (POWER SUPPLY)_v2
# =============================================================

if ($ARGS[3] -eq 'check_nodeps_v2') {

# Recuperation de l'ensemble des powersupply des nodes de la baie
$ps_state = & $plink -ssh $login -pw $password "shownode -ps -s"

# Calcul nombre de powersupply OK
$nb_PS_Normal = ($ps_state | select-string "OK" | measure-object).count

# Calcul nombre de powersupply Degraded
$nb_PS_Degraded = ($ps_state | select-string "degraded" | measure-object).count

# Calcul nombre de powersupply Failed
$nb_PS_Failed = ($ps_state | select-string "failed" | measure-object).count

# Traitement Channel PRTG
$result = "<prtg>

			<result>
			<channel>OK</channel>
			<value>$nb_PS_Normal</value>
			<CustomUnit>PS</CustomUnit>
			</result>
			
			<result>
			<channel>Degraded</channel>
			<value>$nb_PS_Degraded</value>
			<CustomUnit>PS</CustomUnit>
			</result>
			
			<result>
			<channel>Failed</channel>
			<value>$nb_PS_Failed</value>
			<CustomUnit>PS</CustomUnit>
			<LimitMaxError>1</LimitMaxError>
            <LimitMaxWarning>0</LimitMaxWarning>
			<LimitWarningMsg>$nb_PS_Failed</LimitWarningMsg>
    		<LimitMode>1</LimitMode>
			</result>
						
			</prtg>"
			
$result	
}

# =============================================================
#			CHECK_QUORUM
# =============================================================

if ($ARGS[3] -eq 'check_quorum') {

# Recuperation de l'ensemble des powersupply des nodes de la baie
$quorum_state = & $plink -ssh $login -pw $password "showrcopy -qw targets -nohdtot"

# Calcul nombre de powersupply OK
$QUORUM_Normal = ($quorum_state | select-string "ready" | measure-object).count

# Calcul nombre de powersupply Failed
$QUORUM_Failed = ($quorum_state | select-string "Not-started" | measure-object).count

# Traitement Channel PRTG
$result = "<prtg>

			<result>
			<channel>OK</channel>
			<value>$QUORUM_Normal</value>
			<CustomUnit>QUORUM</CustomUnit>
			</result>
			
			<result>
			<channel>Failed</channel>
			<value>$QUORUM_Failed</value>
			<CustomUnit>QUORUM</CustomUnit>
			<LimitMaxError>0</LimitMaxError>
    		<LimitMode>1</LimitMode>
			</result>
						
			</prtg>"
			
$result	
}
