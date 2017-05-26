#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv test_reorg "NON_REORG"
if ("OS/390" == $HOSTOS) setenv tst_disable_dbx		#prevent CEE2530S Debug Tool not available

# Since we are playing with mupltiple GLDs, unsetenv gtm_custom_errors to avoid REPLINSTMISMTCH errors in MUPIP SET -VERSION
unsetenv gtm_custom_errors

setenv gtmgbldir mumps.gld

if ( "GT.CM" == "$test_gtm_gtcm") then
	setenv gtm_test_spanreg 0	# because we dont support remote regions for globals spanning multiple regions
endif
# for GT.CM: Test if up-bar'd (extended) gld is GT.CM
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh second 3

if ( "GT.CM" == "$test_gtm_gtcm") setenv gtcm_save "$test_gtm_gtcm"
setenv test_gtm_gtcm "GT.M"
if ($?test_replic) then
	setenv repl_save  $test_replic
	unsetenv test_replic
endif
# the dbcreate below will rename the existing databases. So move them away temporarily
mkdir bak ; mv *.dat *.gld bak/ ##BYPASSOK
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh mumps 1
mv bak/* .
if ($?repl_save) then
	setenv test_replic $repl_save
endif
if ($?gtcm_save) then
	setenv test_gtm_gtcm "$gtcm_save"
endif

#
setenv gtmgbldir mumps.gld
$GTM << aaa
d ^extgbl1
h
aaa
#
#
echo "setenv gtmgbldir mumps.gld"
setenv gtmgbldir mumps.gld
cat $gtm_tst/$tst/inref/extgbl.txt | $gtm_exe/mumps -run list
#
echo "setenv gtmgbldir second.gld"
setenv gtmgbldir second.gld
cat $gtm_tst/$tst/inref/extgbl.txt | $gtm_exe/mumps -run list
if ( "GT.CM" == "$test_gtm_gtcm" || ($?test_replic && (0 != $test_replic_mh_type)) ) $gtm_tst/com/send_env.csh	# To reflect the changes in gtmgbldir
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcheck.csh -extr
setenv test_gtm_gtcm "GT.M"
unsetenv test_replic
setenv gtmgbldir mumps.gld
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcheck.csh mumps
