#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# use gde_long4 instead of dbcreate.csh since we do not want too many regions

setenv test_specific_gde $gtm_tst/$tst/inref/gdelong4.gde
$gtm_tst/com/dbcreate.csh .

echo "test long variable names for lock command"

$GTM << gtm_end >>&! lock_output.out
write "do ^lkelong",!  do ^lkelong
halt
gtm_end

echo "test long region names"
$LKE show -region=A
$LKE show -region=A234567890123456
$LKE show -region=A23456789012345678901234567890
$LKE show -region=A234567890123456789012345678901
$GTM << gtm_end >>& lock_output.out
write "do ^lkelongregion",! do ^lkelongregion
halt
gtm_end
$tst_awk '/^PID=/ {pids[++nopid]=$0;gsub(/PID=/,"",pids[nopid]);print "PID= PID"nopid;getline} {for(i=1;i<=nopid;i++) gsub("PID=[ ]*"pids[i]" ","PID= PID"i" ",$0);print}' lock_output.out

$gtm_tst/com/dbcheck.csh
