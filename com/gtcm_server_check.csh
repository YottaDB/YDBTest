#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Helper script checking proper GT.CM buddies

set tst_gtcm_remote_host_tmp = `echo $tst_gtcm_remote_host | sed "s/$tst_org_host//g"`
if (($tst_gtcm_remote_host != $tst_gtcm_remote_host_tmp) && ("default" != $tst_remote_dir)) then
	# a specified host was kicked out, so directories won't match
	echo "TEST-E-REMOTEHOST One (or more) of the GT.CM servers was local, and directories were specified."
	echo "This script does not handle this case."
	echo "Please specify non-local hosts."
	exit 4
endif
if (("$tst_gtcm_remote_host" == "$tst_org_host")||("default" == "$tst_gtcm_remote_host")) then
	# default
	setenv tst_other_servers_list  ""
	set count = 0
else
	setenv tst_other_servers_list "`echo $tst_gtcm_remote_host | sed 's/,/ /g' `"
	set count = `echo $tst_other_servers_list | wc -w`
endif
if (2 > $count) then
	set tmp_tst_other_servers_list = `$gtm_tst/com/get_buddy_server.csh GTCM`
	# if less then two hosts were specified, pad it upto 2
	foreach server ($tmp_tst_other_servers_list)
		if (`echo $tst_other_servers_list| $grep -c ${server:q}'$'`) continue
		setenv tst_other_servers_list  "$tst_other_servers_list $server"
		set  count = `echo  $tst_other_servers_list | wc -w`
		if (2 == $count) break
	end
endif
if (2 > $count) then
	echo "TEST-E-REMOTE GT.CM server count. 2 GT.CM servers are required for GT.CM testing but the servers are $tst_other_servers_list"
	echo "Provide proper remote host gtcm servers in the command line or check $gtm_test_serverconf_file for proper buddy setup for $tst_org_host"
	echo "Exiting now..."
	exit 4
endif
set tmp_tst_other_servers_list = ($tst_other_servers_list)
if ($?cms_tools) then
	set serveri = 1
	while ($serveri <= $count)
		setenv gtcm_server_location `$cms_tools/determine_server_location.csh $tmp_tst_other_servers_list[$serveri]:r:r:r:r`
		if ( "$gtcm_server_location" != "$gtm_server_location" ) then
			set tmpfile=/tmp/__${USER}_location_error_$$.out
			echo "TEST-E-REMOTE GT.CM SERVER ACROSS LOCATION. chosen gtcm_server is across locations." >&! $tmpfile
			echo "Host $tst_org_host is at $gtm_server_location whereas gtcm server $tmp_tst_other_servers_list[$serveri] is at $gtcm_server_location" >>&! $tmpfile
			echo "Pls. choose a gtcm server from $gtm_server_location and run again. You would want to check $gtm_test_serverconf_file Exiting ..." >>&! $tmpfile
			if (!($?tst_dont_send_mail)) mailx -s "TEST-E-REMOTE GT.CM SERVER ACROSS LOCATION, $HOST:r:r:r:r did not run tests" $mailing_list < $tmpfile
			cat $tmpfile;rm -f $tmpfile
			exit 4
		endif
		@ serveri = $serveri + 1
	end
endif
set uniqsrvrs = `echo $tmp_tst_other_servers_list $tst_org_host | $tst_awk '{for (i=0;++i<=NF;) srvr[$i]++} END {for (s in srvr) print s}'`
if (3 != $#uniqsrvrs) then
	echo "TEST-E-DUPLICATEHOST No duplicate hostnames allowed. (It won't work)"
	echo "GT.CM servers are $tst_other_servers_list"
	echo "GT.CM client is $tst_org_host"
	echo "Exiting..."
	exit 4
endif
setenv tst_gtcm_server_list "$tmp_tst_other_servers_list"

set totalx = `echo $tst_other_servers_list| wc -w`
if ($?remote_ver_gtcm) then
	set tmp_remote_ver_gtcm = (`echo $remote_ver_gtcm | sed 's/,/ /g'`)
	if ($totalx != $#tmp_remote_ver_gtcm) then
		echo "TEST-E-REMOTE_GTCM_VER Number of gtcm hosts do not match the number of remote versions."
		echo "Please check your arguments."
		exit 4
	endif
endif
if ($?remote_image_gtcm) then
	set tmp_remote_image_gtcm = (`echo $remote_image_gtcm | sed 's/,/ /g'`)
	if ($totalx != $#tmp_remote_image_gtcm) then
		echo "TEST-E-REMOTE_GTCM_VER Number of gtcm hosts do not match the number of remote images."
		echo "Please check your arguments."
		exit 4
	endif
endif
set xcnt = 1
foreach host_rmtx ($tst_other_servers_list)
	if ($?remote_ver_gtcm) then
		setenv remote_ver_gtcm_$host_rmtx:r:r:r:r $tmp_remote_ver_gtcm[$xcnt]
	else
		setenv remote_ver_gtcm_$host_rmtx:r:r:r:r $tst_ver
	endif
	if ($?remote_image_gtcm) then
		setenv remote_image_gtcm_$host_rmtx:r:r:r:r $tmp_remote_image_gtcm[$xcnt]
	else
		setenv remote_image_gtcm_$host_rmtx:r:r:r:r $tst_image
	endif
	set host_rmt = tst_remote_host_$xcnt
	setenv $host_rmt $host_rmtx
	set dir_rmt = tst_remote_dir_$xcnt
	set curvalue_total = `echo  $tst_gtcm_remote_dir | sed 's/,/ /g'`
	if ($#curvalue_total < $xcnt) then #less no directories specified than hosts
		set curvalue = "default"
	else
		set curvalue = $curvalue_total[$xcnt]
	endif
	if (("" == $curvalue)||("default" == $curvalue)) then
		eval 'set this_host_dir = (${gtm_tstdir_'${host_rmtx:r:r:r:r:q}'})' #' Keep vim highlighting happy
		if ("" == "$this_host_dir" ) then
			setenv $dir_rmt "$tst_dir"
		else
			# if test output directory includes version, include it in remote directories as well
			set dirn = $this_host_dir[$#this_host_dir]/$USER
			if ($tst_dir =~ *$tst_ver*) set dirn = $dirn/$tst_ver
			setenv $dir_rmt $dirn
		endif
	else
		setenv $dir_rmt "$curvalue"
	endif
	@ xcnt = $xcnt + 1
end
