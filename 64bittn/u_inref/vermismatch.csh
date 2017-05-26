#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# priorver.txt is to filter the old version names in the reference file
echo $v4ver >& priorver.txt
# TEST to check all vermismatch errors
######################################################################################
# the test calls another script "check_util.csh" to test vermismatch across db & gld.#
# it accepts three arguments. first denoted gld version , second denotes db version  #
# third denotes the version to test.						     #
# GT.M DSE & MUPIP will be invoked with the given arguments & checked for errors     #
# if called with just one argument as "upgrade" it will upgrade the db from v4 to v5 #
######################################################################################
#
# first create v4 & v5 databases , gld & use this throughout the test
$sv4
$GDE_SAFE exit
$MUPIP create
\mv mumps.dat mumps_v4.dat
\mv mumps.gld mumps_v4.gld
#
$sv5
$GDE exit;$MUPIP create
\mv mumps.dat mumps_v5.dat
\mv mumps.gld mumps_v5.gld
cp $gtm_tst/$tst/inref/yes.txt .
################################################
# access v4 gld , v4 db with a v5 version
$gtm_tst/$tst/u_inref/check_util.csh v4 v4 $tst_ver
# now upgrade the database to V5
$gtm_tst/$tst/u_inref/check_util.csh "upgrade"
echo "do gde exit in V5. this should automatically convert gld to V5 without issue"
$sv5
$GDE exit
echo "global sets, mupip & dse expected to PASS here"
$GTM << gtm_eof
set ^a=1
if ^a'=1 write "TEST-E-ERROR.global set failed",!
halt
gtm_eof
$MUPIP extract -nolog fi.glo
if ($status) then
	echo "TEST-E-ERROR. MUPIP extract failed after upgrade to V5"
endif
$DSE dump -fileheader
if ($status) then
	echo "TEST-E-ERROR. DSE dump failed after upgrade to V5"
endif
# access v5 gld , v5 db with a v4 version
$gtm_tst/$tst/u_inref/check_util.csh v5 v5 $v4ver
#
# access v5 gld , v4 db with a v4 version
$gtm_tst/$tst/u_inref/check_util.csh v5 v4 $v4ver
#
# access v5 gld , v4 db with a v5 version
$gtm_tst/$tst/u_inref/check_util.csh v5 v4 $tst_ver
#
## check MUPIP recover/rollback
$sv4
\cp mumps_v4.gld mumps.gld
\cp mumps_v4.dat mumps.dat
$MUPIP set -journal="enable,on,before" -region "*" >>&! journalog.out
$grep -i "before" journalog.out
$GTM << gtm_eof
for i=1:1:20 set ^aglobal(i)=\$justify(i,10)
halt
gtm_eof
# save the journal file for rollback check
cp mumps.mjl mumps.mjl.bak
# upgrade the db before recover
$gtm_tst/$tst/u_inref/check_util.csh "upgrade"
$sv5
$GDE exit
echo "MUPIP recover attempted on V4 journals. should issue JNLBADLABEL but not explode"
# First create a mumps.repl:
setenv gtm_repl_instance mumps.repl
setenv gtm_repl_instname INSTANCE1
$MUPIP replic -instance_create
$MUPIP journal -recover -forward mumps.mjl
if (0 == $status) then
	echo "TEST-E-ERROR. Recovery expected to fail but didn't"
endif
#
echo "MUPIP rollback attempted on V4 journals. should issue JNLBADLABEL but not explode"
setenv gtm_repl_instance "mumps.repl"
$MUPIP replicate -instance_create
mv mumps.mjl mumps.mjl_move	# move mumps.mjl out of the way or else following command will error out with FILEEXISTS
$MUPIP set -replication=on -reg "*"
mv mumps.mjl.bak mumps.mjl
# Below backward rollback invocation is expected to fail. Therefore pass "-backward" explicitly to mupip_rollback.csh
# (and avoid implicit "-forward" rollback invocation that would otherwise happen by default.
$gtm_tst/com/mupip_rollback.csh -backward -resync=130 -losttrans=fetch.glo "*"
if ($status == 0) then
	echo "TEST-E-ERROR. Rollback expected to fail but didn't"
endif
#
