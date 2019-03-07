#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################


if ("" == "$1") then
	set type = "SE1"
else
	set type = "$1"
endif

if ("" == "$2") then
	set hostn = $HOST:ar
else
	set hostn = "$2"
endif

set gg_servers_file = "${TMP_FILE_PREFIX}_gg_servers_copy.txt"
cp $gtm_test_serverconf_file $gg_servers_file
set line = `$tst_awk '{if ($1 == "'$hostn'") {print ; exit}}' $gg_servers_file`
set buddy = ""

if ($?exclude_servers) then
	set exclude_list = `echo $exclude_servers | sed 's/,/ /g'`
	foreach xserver ($exclude_list)
		set alternateserver = `$tst_awk '{if ($1 == "'$xserver'") {print $7 ; exit}}' $gg_servers_file`
		set line = `echo $line | $tst_awk '{for(i=1;i<=NF;i++) if ("'$xserver'" == $i) {print "##'$alternateserver'##"} else {print $i}}'`
	end
	set line = `echo $line | sed 's/##//g'`
endif

switch($type)
case "SE1":
	set buddy = `echo $line | $tst_awk '{print $2}'`
breaksw

case "SE2":
	set buddy = `echo $line | $tst_awk '{print $3}'`
breaksw

case "RE":
	set buddy = `echo $line | $tst_awk '{print $4}'`
breaksw

case "GTCM":
	set buddy = `echo $line | $tst_awk '{print $5,$6}'`
breaksw

endsw

if ($?exclude_servers) then
	foreach bserver ($buddy)
		echo "$exclude_servers $hostn" | $grep -w $bserver >& /dev/null
		if !($status) then
			# This might happen if that alternate server is also in the excluded server list or if it cycles back to the original host
			# In that case exit with a null. Lets assume the caller of the script will take care of null response
			echo ""
			exit 1
		endif
	end
endif
# Print only unique server names
echo $buddy |& $tst_awk '{for(i=1;i<=NF;i++) buddy[$i]++} END { for(srvr in buddy) print srvr }'
