#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test that multi-threaded run of $INCR works fine with non-TP/TP/ZTP and journaling
# Test $INCR of a record whose position in the tree oscillates due to neighbouring record sets/kills
# Concurrency test for $increment within non-TP/TP/ZTP and choice of nojnl/nobefore-image/before-image
#
# Turn on journaling based on random choice : nojnl OR nobefore-image OR before-image
source $gtm_tst/com/set_env_random.csh gtm_test_jnl
#
echo "incrgv4 subtest - multithreaded  with tp/non-tp/ztp and journaling"
setenv test_reorg "NON_REORG"
$gtm_tst/com/dbcreate.csh mumps 1 -allocation=2048 -extension_count=2048
#
# Start reorg processes in background
$gtm_tst/com/bkgrnd_reorg.csh >& bkgrnd_reorg.out
#
# Start GT.M processes
$gtm_exe/mumps -run incrgv4
#
# Shut down reorg processes
$gtm_tst/com/close_reorg.csh >& close_reorg.out
#
# To  make the reference file easier, all output of journal/extract are
# redirected, but if there is an error we will see them in output (errors.csh will do that)
# set_randomjnl.csh will log the random option in settings.csh. Use it to check if it is enabled
set isjnlenabled = `$tst_awk '/setenv rand_jnl_enable/ {print $NF ; exit}' settings.csh`
if (1 == "$isjnlenabled") then
	$gtm_tst/com/backup_dbjnl.csh save # useful for debugging
	set mjl_files = `echo mumps.mjl* | sed 's/ /,/g'`
	$MUPIP journal -extract -forward $mjl_files >& extract.out
	$gtm_tst/$tst/u_inref/checkextract.csh
	$MUPIP extract db_extract.tmp >& db_extract.out
	$tail -n +3 db_extract.tmp > db_extract.glo
	\rm *.dat
	$MUPIP create >& newdbcreate.out
	source $gtm_tst/com/mupip_set_version.csh # re-do the mupip_set_version
	source $gtm_tst/com/change_current_tn.csh # re-change the cur tn
	$MUPIP journal -recover -forward $mjl_files >& recover.log
	$MUPIP extract jnl_extract.tmp >& jnl_extract.out
	$tail -n +3 jnl_extract.tmp > jnl_extract.glo
	$tst_cmpsilent db_extract.glo jnl_extract.glo
	if ($status) echo "diff db_extract.glo jnl_extract.glo failed"
endif
$gtm_tst/com/dbcheck.csh
echo "End of incrgv4 subtest"
