#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
setenv gtm_test_tp "TP"
### If nct collation and journaling works fine, this is a good place to test it with reorg
if (0 == $?test_replic) then
	setenv gtm_test_jnl "SETJNL"
endif
$gtm_tst/com/dbcreate.csh mumps 8 125 1000 4096 4096 4096 4096
echo "Multi-Process GTM Process starts in background..."
$gtm_tst/com/imptp.csh "3" >&! imptp.out
#
# Randomly choose to do 500K to 1m global sets (multiples of 100k for simplicity)
if !($?gtm_test_replay) then
	set rand = `$gtm_exe/mumps -run rand 5 1 5`
	@ on_tp_jnl_multi_reorg_count = $rand * 100000
	echo "# Random count of globals to wait for chosen by on_tp_jnl_multi_reorg subtest"	>> settings.csh
	echo "setenv on_tp_jnl_multi_reorg_count $on_tp_jnl_multi_reorg_count"			>> settings.csh
endif
$gtm_exe/mumps -run waitforgvstats "SET" $on_tp_jnl_multi_reorg_count 600
echo "Now GTM process ends"
$gtm_tst/com/endtp.csh >>& endtp.out
$gtm_tst/com/dbcheck.csh "-extract"
$gtm_tst/com/checkdb.csh
#
# In the -recover -backward -since command below, use half the time it took for updates for the minute value of -since qualifier
set since_min = `$tst_awk '/After .* seconds/ {secs=$2} END {print int(secs/(60*2))}' waitforgvstats.out `
$gtm_tst/com/backup_dbjnl.csh save # useful for debugging
#
unsetenv test_replic
setenv test_reorg "NON_REORG"
echo "Extract from database..."
$MUPIP extract tmp.glo >>& extract.out
$tail -n +3  tmp.glo >! data1.glo
\rm -f tmp.glo
date >>& $tst_general_dir/recov_time.log
# Since V44002 without -since qualifier -recover -backward command on a clean database/journal system is a noop.
# So -since time is introduced to excersize recover code
echo "$MUPIP journal -recover -verbose -backward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,mumps.mjl"
$MUPIP journal -recover -verbose -backward -since=\"0 0:${since_min}:00\" a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,mumps.mjl >>& back_recover.log
set stat1 = $status
$grep "successful" back_recover.log
date >>& $tst_general_dir/recov_time.log
if ($stat1 != 0) then
	echo "$MUPIP journal -recover -backward failed"
	cat back_recover.log
	exit 1
endif
$gtm_tst/com/dbcheck_filter.csh -nosprgde
echo "Extract from database..."
$MUPIP extract tmp.glo >>& extract.out
if ($status) echo "Extract fails"
$tail -n +3  tmp.glo >! data2.glo
\rm -f tmp.glo
\rm *.dat
$MUPIP create |& sort -f
source $gtm_tst/com/mupip_set_version.csh # re-do the mupip_set_version
source $gtm_tst/com/change_current_tn.csh # re-change the cur tn
echo "$MUPIP journal -recover -verbose -forward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,mumps.mjl"
date >>& $tst_general_dir/recov_time.log
$MUPIP journal -recover -verbose -forward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,mumps.mjl  >>& forw_recover.log
set stat2 = $status
$grep "successful" forw_recover.log
date >>& $tst_general_dir/recov_time.log
if ($stat2 != 0) then
	echo "$MUPIP journal -recover -forward failed"
	cat forw_recover.log
	exit 1
endif
$gtm_tst/com/dbcheck.csh -nosprgde
$MUPIP extract tmp.glo >>& extract.out
if ($status) echo "Extract fails"
$tail -n +3  tmp.glo >! data3.glo
\rm -f tmp.glo
echo "diff data1.glo data2.glo"
$tst_cmpsilent data1.glo data2.glo
if ($status) echo "TEST falied in MUPIP recover -BACKWARD"
echo "diff data1.glo data3.glo"
$tst_cmpsilent data1.glo data3.glo
if ($status) echo "TEST falied in MUPIP recover -FORWARD"
