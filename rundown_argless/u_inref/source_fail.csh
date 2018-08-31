#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# PRIMARY FAILURE Simulation
#
cd $PRI_SIDE
echo "Simulating failure of primary source server in `pwd`"
setenv kill_time `date +%H_%M_%S`
setenv KILL_LOG pkill_${kill_time}.logx

echo "Before Primary failed >>>>" 	>>& $KILL_LOG
echo "Current directory: $PRI_SIDE"	>>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER	>>& $KILL_LOG
$psuser | $grep -E "mupip|mumps" 	>>& $KILL_LOG

$MUPIP replicate -source -checkhealth >&! health
set pids=`$tst_awk  '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }' health`
# IPCS

#################################
# Actual crash of receiver side
echo "$kill9 $pids" 			>>& $KILL_LOG
$kill9 $pids
#################################

echo "After Primary failed>>>>" 	>>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER 	>>& $KILL_LOG
$psuser |$grep -E "mupip|mumps"		>>& $KILL_LOG
echo "Primary Source Server Failed!"
#=== End Crash ===
