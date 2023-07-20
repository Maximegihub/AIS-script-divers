#!/bin/bash
#
#
# Array des Process surveilles
array=( vnetd bpcd vmd pbx_exchange NB_dbsrv nbemm bprd nbjm bpdbm bpjobd nbpem nbstserv spad spoold )

function service_status {

        if pgrep $1 >/dev/null 2>&1
        then
        # process present
                echo -n "1"

        else
        # process abscent
                echo -n "0"
        fi
}

echo "<prtg>"

# <-- Start
for i in "${array[@]}"
do

echo -n "   <result>
       <channel>Service: $i</channel>
         <value>"
service_status $i
echo "</value>
   </result>"
done
# End -->
echo "</prtg>"

exit
