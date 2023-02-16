#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
##########################################################################################################
# script to activate root or propagate primary based on the argument passed to it
##########################################################################################################
# if $1 is NULL then the software decides to activate the default scenario i.e. as rootprimary
setenv arg1 "$1"
#
if ($?gtm_test_replic_timestamp) then
	setenv time_stamp $gtm_test_replic_timestamp
else
	setenv time_stamp `date +%H:%M:%S`
endif
# Make sure we can talk IPv6 to the secondary, and scrub the v6 suffix if we can't.
if ($?test_no_ipv6_ver) then
	# Both v6 and v46 may be an issue, so drop all suffixes
	if ($tst_now_secondary != $tst_now_secondary:r:r:r:r) then
		echo "Removing suffixes from secondary '$tst_now_secondary' due to non-IPv6 prior version." >& activate_${time_stamp}_nov6.outx
		setenv tst_now_secondary $tst_now_secondary:r:r:r:r
	endif
else
	eval 'if (\! $?host_ipv6_support_'${tst_now_primary:r:r:r:r}') set host_ipv6_support_'${tst_now_primary:r:r:r:r}'=0'
	if (! `eval echo '$host_ipv6_support_'${tst_now_primary:r:r:r:r}`) then
		if ($tst_now_secondary =~ *.v6*) then
			echo "Removing v6 from secondary '$tst_now_secondary' due to missing IPv6 on primary '$tst_now_primary'" >& activate_${time_stamp}_nov6.out
			setenv tst_now_secondary ${tst_now_secondary:s/.v6//}
		endif
	endif
endif

# get gtm_test_instsecondary which will be set based on the link details provided for ACTIVATE action in multisite
if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
endif
$MUPIP replic -source -checkhealth $gtm_test_instsecondary >&! checkhealth_passive_${time_stamp}.out
$grep "PASSIVE" checkhealth_passive_${time_stamp}.out >& /dev/null
if ($status) then
	# this means the server is already in active mode and so we need to deactivate first
	$MUPIP replic -source -deactivate  $gtm_test_instsecondary >& deactivate_${time_stamp}.log
	@ reqmax = 120
	@ reqcount = 0
	while ($reqcount < $reqmax)
		sleep 1
		@ reqcount++
		$MUPIP replic -source -checkhealth $gtm_test_instsecondary >&! checkhealth_deactivate_${time_stamp}_${reqcount}.out
		$grep "REQUESTED" checkhealth_deactivate_${time_stamp}_${reqcount}.out >& /dev/null
		if ($status) break
	end
endif

source $gtm_tst/com/set_var_trigupdatestr.csh	# sets "trigupdatestr" variable to contain "" or "-trigupdate"

echo "$MUPIP replic -source $arg1 -activate $gtm_test_instsecondary -secondary=$tst_now_secondary":"$portno -log=SRC_activated_${time_stamp}.log $trigupdatestr" >&! ACTIVATE_${time_stamp}.out
$MUPIP replic -source $arg1 -activate $gtm_test_instsecondary -secondary="$tst_now_secondary":"$portno" -log=SRC_activated_${time_stamp}.log $trigupdatestr >>&! ACTIVATE_${time_stamp}.out
if ( $status ) then
	set msg = "Instance cannot be activated"
	if ("" != "$arg1") set msg = "$msg as $arg1"
	echo $msg
	echo "######################################################################"
	if ( -e SRC_activated_${time_stamp}.log ) then
		echo "Check SRC_activated_${time_stamp}.log"
	endif
	echo "Check ACTIVATE_${time_stamp}.out"
	echo "######################################################################"
	exit 1
else
	$grep "ACTIV" ACTIVATE_${time_stamp}.out
endif
#
