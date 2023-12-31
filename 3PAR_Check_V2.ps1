#AUTEUR: Guillaume BOUTAIN
#Nom du script: 3PAR_Check_V1
#Date : 15/03/2012

# 15/03/2012 Création du script
# 26/06/2012 Ajout Check_DOMAIN
# 17/05/2013 Modif. Check_DOMAIN (filtre type base) car problème si snapshot de volume


$Username = $ARGS[1]
$Password = $ARGS[2]
$Inserv = $ARGS[0]

$plink = "C:\Program Files (x86)\PRTG Network Monitor\Outils\plink-0.58.exe"

$login = $Username+"@"+$Inserv



# =============================================================
#						CHECK_PD
# =============================================================

# Vérification des disques physiques
# Si "FAILED" alors erreur
# Si "DEGRADED" alors warning
# Sinon OK
# Affichage en valeur du nombre de disque et listage si probleme des PID des disques concernés

if ($ARGS[3] -eq 'check_pd') {

    $Check_PD = $null
	$PD_Sate = $null

	  $pd_state = & $plink -ssh $login -pw $password "showpd -showcols Id,State -nohdtot" 
	  #$PD_State = $Check_PD | select-string "degraded"
	  #$pd_state > "C:\Program Files (x86)\PRTG Network Monitor\Outils\test_pd.txt"
	  #$pd_state = get-content "C:\Program Files (x86)\PRTG Network Monitor\Outils\test_pd.txt" # | select-string "degraded"
	  
	  
	 # (get-content D:\3PAR_PRTG\csvtest3.txt | select-string "failed" ).count
	  if (($pd_state | select-string "failed" | measure-object ).count  -gt '0'){
		  [STRING]$pd_failed = $pd_state | select-string "failed"
		  $pd_hs_list = $pd_failed
		  $pd_total_count = $pd_state.count
		  $pd_failed_count = ($pd_state | select-string "failed" | measure-object ).count
		  $resultD = $pd_failed_count
		  write-host $resultD":Disk(s) "$pd_hs_list" Down"
		  exit 2
	  }
		 
	  elseif (($pd_state | select-string "degraded" | measure-object ).count -gt '0' ){
		  [STRING]$pd_degraded = $pd_state | select-string "degraded"
		  $pd_degraded = $pd_state | select-string "degraded"
		  $pd_hs_list = $pd_degraded
		  $pd_total_count = $pd_state.count
		  $pd_degraded_count = ($pd_state | select-string "degraded" | measure-object ).count
		  $resultW =$pd_degraded_count
		  write-host $resultW":Disk(s) "$pd_hs_list" Warning"
		  exit 2
	  }
	  
	  else {
			$result = $pd_state.count
			write-host $result":OK"
			exit 0  
	  }
	  
} 

# =============================================================
#						CHECK_NODE
# =============================================================
 
  
if ($ARGS[3] -eq 'check_node') {

  $node_state = & $plink -ssh $login -pw $password "shownode -s -nohdtot"
  #$node_state = get-content "C:\Program Files (x86)\PRTG Network Monitor\Outils\test_node.txt" # | select-string "degraded"
  
 if (($node_state | select-string "failed" | measure-object ).count  -gt '0'){
		  [STRING]$node_failed = $node_state -match "failed" | % {$_.substring(2,2)}
		  $node_hs_list = $node_failed +" "+ $node_degraded
		  $node_total_count = $node_state.count
		  $node_failed_count = ($node_state | select-string "failed" | measure-object ).count
		  $node_degraded_count = ($node_state | select-string "degraded" | measure-object ).count
		  $result = $node_total_count - $node_failed_count - $node_degraded_count
		  write-host "Nodes(s) "$node_hs_list" Down"
			exit 2
	  }
 
 	  elseif (($node_state | select-string "degraded" | measure-object ).count -gt '0' ){
		 [STRING]$node_degraded = $node_state -match "degraded" | % {$_.substring(2,2)}
		  $node_degraded = $node_state -match "degraded" | % {$_.substring(2,2)}
		  $node_hs_list = $node_degraded
		  $node_total_count = $node_state.count
		  $node_degraded_count = ($node_state | select-string "degraded" | measure-object ).count
		  $result = $node_total_count - $node_degraded_count
		  write-host $result":Node(s) "$node_hs_list" Warning"
		  exit 2
	  }
	  
	  else {
			$result = $node_state.count
			write-host $result":OK"
			exit 0  
	  }	  

}

# =============================================================
#						CHECK_BATTERY
# =============================================================
 
  
if ($ARGS[3] -eq 'check_battery') {

  $battery_state = & $plink -ssh $login -pw $password "showbattery -state -nohdtot"
  #$node_state = get-content "C:\Program Files (x86)\PRTG Network Monitor\Outils\test_node.txt" # | select-string "degraded"
  
 if (($battery_state | select-string "failed" | measure-object ).count  -gt '0'){
		  [STRING]$battery_failed = $battery_state -match "failed" | % {$_.substring(2,2)}
		  [STRING]$battery_degraded = $battery_state -match "degraded" | % {$_.substring(2,2)}
		  $battery_hs_list = $battery_failed +" "+ $battery_degraded
		  $battery_total_count = $battery_state.count
		  $battery_failed_count = ($battery_state | select-string "failed" | measure-object ).count
		  $battery_degraded_count = ($battery_state | select-string "degraded" | measure-object ).count
		  $result = $battery_total_count - $battery_failed_count - $battery_degraded_count
		  write-host "Battery(s) "$battery_hs_list" Down"
			exit 2
	  }
 
 	  elseif (($battery_state | select-string "degraded" | measure-object ).count -gt '0' ){
		  $battery_degraded = $battery_state -match "degraded" | % {$_.substring(2,2)}
		  $battery_hs_list = $battery_degraded
		  $battery_total_count = $battery_state.count
		  $battery_degraded_count = ($battery_state | select-string "degraded" | measure-object ).count
		  $result = $battery_total_count - $battery_degraded_count
		  write-host $result":Battery(s) "$battery_hs_list" Warning"
		  exit 2
	  }
	  
	  else {
			$result = $battery_state.count
			write-host $result":OK"
			exit 0  
	  }	  

}

# =============================================================
#			CHECK_NODEPS  (power supply)
# =============================================================


if ($ARGS[3] -eq 'check_nodeps') {

  $nodeps_state = & $plink -ssh $login -pw $password "shownode -ps -showcols Node,PSState -nohdtot"
  #$nodeps_state = get-content "C:\Program Files (x86)\PRTG Network Monitor\Outils\test_nodeps.txt" # | select-string "degraded"
  #$nodeps_state > "C:\Program Files (x86)\PRTG Network Monitor\Outils\test_nodeps.txt"
  
 if (($nodeps_state | select-string "failed" | measure-object ).count  -gt '0'){
		  [STRING]$nodeps_failed = $nodeps_state -match "failed" | % {$_.substring(3,4)} | % {$_.replace(" ","")} | % {$_.insert(1,"-")}
		  [STRING]$nodeps_degraded = $nodeps_state -match "degraded" | % {$_.substring(3,4)} | % {$_.replace(" ","")} | % {$_.insert(1,"-")}
		  $nodeps_hs_list = $nodeps_failed +" "+ $nodeps_degraded
		  $nodeps_total_count = $nodeps_state.count
		  $nodeps_failed_count = ($nodeps_state | select-string "failed" | measure-object ).count
		  $nodeps_degraded_count = ($nodeps_state | select-string "degraded" | measure-object ).count
		  $result = $nodeps_total_count - $nodeps_failed_count - $nodeps_degraded_count
		  write-host "Power Supply"$nodeps_hs_list" Down"
			exit 2
	  }
 
 	  elseif (($nodeps_state | select-string "degraded" | measure-object ).count -gt '0' ){
		  $nodeps_degraded = $nodeps_state -match "degraded" | % {$_.substring(3,4)} | % {$_.replace(" ","")} | % {$_.insert(1,"-")}
		  $nodeps_hs_list = $nodeps_degraded
		  $nodeps_total_count = $nodeps_state.count
		  $nodeps_degraded_count = ($nodeps_state | select-string "degraded" | measure-object ).count
		  $result = $nodeps_total_count - $nodeps_degraded_count
		  write-host $result":Power Supply "$nodeps_hs_list" Warning"
		  exit 2
	  }
	  
	  else {
			$result = $nodeps_state.count
			write-host $result":OK"
			exit 0  
	  }		  
	 
 } 
 
# =============================================================
#						CHECK_VV
# =============================================================

 
if ($ARGS[3] -eq 'check_vv') {

  $vv_state = & $plink -ssh $login -pw $password "showvv -showcols Name,State -notree -nohdtot"
  #$vv_state = get-content "C:\Program Files (x86)\PRTG Network Monitor\Outils\test_vv.txt" # | select-string "degraded"
  
if (($vv_state | select-string "failed" | measure-object ).count  -gt '0'){
		  [STRING]$vv_failed = $vv_state -match "failed"
		  [STRING]$vv_degraded = $vv_state -match "degraded"
		  $vv_hs_list = $vv_failed +" "+ $vv_degraded
		  $vv_total_count = $vv_state.count
		  $vv_failed_count = ($vv_state | select-string "failed" | measure-object ).count
		  $vv_degraded_count = ($vv_state | select-string "degraded" | measure-object ).count
		  $result = $vv_total_count - $vv_failed_count - $vv_degraded_count
		  write-host "VV(s) "$vv_hs_list" Down"
			exit 2
	  }
 
 	  elseif (($vv_state | select-string "degraded" | measure-object ).count -gt '0' ){
		  $vv_degraded = $vv_state -match "degraded"
		  $vv_hs_list = $vv_degraded
		  $vv_total_count = $vv_state.count
		  $vv_degraded_count = ($vv_state | select-string "degraded" | measure-object ).count
		  $result = $vv_total_count - $vv_degraded_count
		  write-host $result":VV(s) "$vv_hs_list" Warning"
		  exit 2
	  }
	  
	  else {
			$result = $vv_state.count
			write-host $result":OK"
			exit 0  
	  }		  
	 
 }


# =============================================================
#						CHECK_PORT
# =============================================================

 
if ($ARGS[3] -eq 'check_port') {

  $port_state_brut = & $plink -ssh $login -pw $password "showport -state -nohdtot"
  #$port_state_brut = get-content "C:\Program Files (x86)\PRTG Network Monitor\Outils\test_port.txt" # | select-string "degraded"
  
  $port_state = ($port_state_brut -notmatch 'free') -notmatch 'rcip'
  
 if (($port_state | select-string "error" | measure-object ).count  -gt '0'){
		  [STRING]$port_failed = $port_state -match "error" | % {$_.substring(0,5)} | % {$_.replace(":",";")}
		  [STRING]$port_degraded = $port_state -match "loss_sync" | % {$_.substring(0,5)} | % {$_.replace(":",";")}
		  $port_hs_list = $port_failed +" "+ $port_degraded
		  $port_total_count = $port_state.count
		  $port_failed_count = ($port_state | select-string "loss_sync" | measure-object ).count
		  $port_degraded_count = ($port_state | select-string "loss_sync" | measure-object ).count
		  $result = $port_total_count - $port_failed_count - $port_degraded_count
		  write-host "Port(s) "$port_hs_list" Error"
			exit 2
	  }
 
 	  elseif (($port_state | select-string "loss_sync" | measure-object ).count -gt '0' ){
		  $port_degraded = $port_state -match "loss_sync" | % {$_.substring(0,5)} | % {$_.replace(":",";")}
		  $port_hs_list = $port_degraded
		  $port_total_count = $port_state.count
		  $port_degraded_count = ($port_state | select-string "loss_sync" | measure-object ).count
		  $result = $port_total_count - $port_degraded_count
		  write-host $result":Port(s) "$port_hs_list" loss_sync"
		  exit 2
	  }
	  
	  else {
			$result = $port_state.count
			write-host $result":OK"
			exit 0  
	  }		  
	 
 } 
 
 
 
# =============================================================
#						CHECK_CAP_SSD
# =============================================================

 
if ($ARGS[3] -eq 'check_cap_ssd') {

	  $Cap_SSD_brut = & $plink -ssh $login -pw $password "showpd -p -devtype SSD -showcols Size_MB,Free_MB -csvtable"
	  
	  $CSV = convertfrom-csv $Cap_SSD_Brut
		$size_Go = ($CSV[(($CSV.count)-1)].size_mb) / 1024
		$free_Go = ($CSV[(($CSV.count)-1)].free_mb) / 1024
		
		[int]$percent_free = (($free_Go/$size_Go)*100)
	 
	<#
	  if ($percent_free -le '12') {
			Write-host "ESPACE RESTANT CRITIQUE "$percent_free"%" 
			exit 2
	    } 

	  elseif ($percent_free -le '20') {
			Write-host $percent_free":Attention espace libre limite" 
			exit 1
		}
	
	  else {
	#>
			Write-host $percent_free":OK"
			exit 0
	    #} 	 	 
	 
 } 
 
# =============================================================
#						CHECK_CAP_FC
# =============================================================

 
if ($ARGS[3] -eq 'check_cap_fc') {

	  $Cap_FC_brut = & $plink -ssh $login -pw $password "showpd -p -devtype FC -showcols Size_MB,Free_MB -csvtable"
	  
	  $CSV = convertfrom-csv $Cap_FC_Brut
		$size_Go = ($CSV[(($CSV.count)-1)].size_mb) / 1024
		$free_Go = ($CSV[(($CSV.count)-1)].free_mb) / 1024
		
		[int]$percent_free = (($free_Go/$size_Go)*100)
	 
	<#
	  if ($percent_free -le '12') {
			Write-host "ESPACE RESTANT CRITIQUE "$percent_free"%" 
			exit 2
	    } 

	  elseif ($percent_free -le '20') {
			Write-host $percent_free":Attention espace libre limite" 
			exit 1
		}
	
	  else {
	#>
			Write-host $percent_free":OK"
			exit 0
	    #} 	 	 
	 
 } 
 
 
# =============================================================
#						CHECK_CAP_NL
# =============================================================

 
if ($ARGS[3] -eq 'check_cap_nl') {

	  $Cap_nl_brut = & $plink -ssh $login -pw $password "showpd -p -devtype NL -showcols Size_MB,Free_MB -csvtable"
	  
	  $CSV = convertfrom-csv $Cap_nl_Brut
		$size_Go = ($CSV[(($CSV.count)-1)].size_mb) / 1024
		$free_Go = ($CSV[(($CSV.count)-1)].free_mb) / 1024
		
		[int]$percent_free = (($free_Go/$size_Go)*100)
	 
	 <#
	  if ($percent_free -le '12') {
			Write-host "ESPACE RESTANT CRITIQUE "$percent_free"%" 
			exit 2
	    } 

	  elseif ($percent_free -le '20') {
			Write-host $percent_free":Attention espace libre limite" 
			exit 1
		}
	  else { 
	  #>
			Write-host $percent_free":OK" 
			exit 0
	    #} 	 	 
	 
 } 
 
 
 
# =============================================================
#						CHECK_FREE_CPG
# =============================================================

 
if ($ARGS[3] -eq 'check_free_cpg') {
		

	  $CPG_Name = $ARGS[4]
		
	  $free_cpg_brut = & $plink -ssh $login -pw $password "showspace -cpg $CPG_Name -csvtable"

		$collection = @()
		[ARRAY]$collection = 'Name,Rawfree,LDFree,Total1,Used1,Total2,Used2,Total3,Used3'
		[ARRAY]$collection += $free_cpg_brut[3]

		$CSV = convertfrom-csv $collection
		[INT]$result = ($CSV.ldfree)/1024

			write-host $result":LD Free (NET)"
			exit 0
	 
 } 
 
 
 
# =============================================================
#						CHECK_FILLING_PD
# =============================================================

 
if ($ARGS[3] -eq 'check_filling_pd') {
		

		$DevType = $ARGS[4]
		
	  $filling_pd_brut = & $plink -ssh $login -pw $password "showpd $DevType -csvtable"
		
		$result = @()
		$CSV = convertfrom-csv $filling_pd_brut[1..(($filling_pd_brut.count)-3)]
		
			  foreach ($a in $CSV){
			  
				  $percent_free = (($a.free)/($a.total))*100
				  [int]$percent_occuped = 100-$percent_free
				  
				  $result += $percent_occuped
			  
			  }
			
			$measure = $result | measure-object -maximum -minimum -average
			
			[int]$Max = $measure.maximum
			[int]$Min = $measure.minimum
			[int]$Ave = $measure.average
			write-host $Max":Ave "$Ave"% | Max "$Max"% | Min "$Min"%"
			exit 0
	 
 } 
 
# =============================================================
#						CHECK_RCOPY
# =============================================================

 
if ($ARGS[3] -eq 'check_rcopy') {
		

		  $Chk_rcopy_brut = & $plink -ssh $login -pw $password "showrcopy groups -csvtable"
		
		
		  [ARRAY]$rcopy_brut = 'Name,Target,Status,Role,Mode,Options'
		  [ARRAY]$rcopy_brut += $Chk_rcopy_brut -match 'primary'
		  [ARRAY]$rcopy_brut += $Chk_rcopy_brut -match 'secondary'
		  $csv= convertfrom-csv $rcopy_brut
		  $total_count = $csv.count


			$failed = $null
			$failed = @()
			$warning = $null
			$warning = @()


		  foreach ($a in $csv){
			  
			  if ($a.status -match 'failed'){
				$failed += $a.name +" "+ $a.status
					}
										
			  elseif ($a.status -match 'error'){
				$failed += $a.name +" "+ $a.status
					}
					
			   elseif ($a.status -match 'stopped'){
				$warning += $a.name +" "+ $a.status
					}  
		  
		  }
		
			if ($failed -ne $null){
				$result = ($total_count)-(($failed.count)+($warning.count))
				write-host $result":"$failed " ; " $warning
				exit 2
			}
			
			elseif ($warning -ne $null){
				$result = $total_count - ($warning.count)
				write-host $result":"$warning
				exit 1
			}
			
			else {
			write-host $total_count":OK"
			exit 0
			}		
	 
 } 
 
 
 # =============================================================
#						CHECK_DOMAIN
# =============================================================
 
#Affiche la taille utilisé sur les Domains en GO 
 
  
if ($ARGS[3] -eq 'check_domain') {

	$Domain_Name = $ARGS[4]

	$result = & $plink -ssh $login -pw $password "showvv -p -type base -showcols Usr_Rsvd_MB -domain $Domain_Name -nohdtot -csvtable"
  
	[INT]$Total_Go = (($result | measure-object -sum).sum)/1024

  
	Write-host $Total_Go":OK"
	exit 0

}
 
 
 
 
 