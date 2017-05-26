#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Specific errors are already triggered in this test. We don't want ENOSPC error to interfere with
# the particular error we expect to happen.
unsetenv gtm_test_freeze_on_error
unsetenv gtm_test_fake_enospc

setenv gtm_poollimit 0 # Poollimit settings causes issues because of the way we try to mimic DBDANGER.

# With 16K counter semaphore bump per process, the 32K counter overflow happens with just 2 processes
# and prevents exercising white-box code which this test relies upon so disable counter overflow
# in this test by setting the increment value to default value of 1 (aka unset).
unsetenv gtm_db_counter_sem_incr

# Enable -defer_allocate so that we can get the GBLOFLOW error
setenv gtm_test_defer_allocate 1
#Every test must call testend to avoid fine name conflicts.

if ("MM" != $acc_meth) then
    setenv journalstr "-journal=enable,before"
else
    setenv journalstr ""
endif

# Creates db and sets up passive replication with before image journaling.
alias createdb '\\
echo "# CreateDatabase";\\
$gtm_tst/com/dbcreate.csh mumps 1 125 1000 4096 2000 4096 2000 >&! dbcreate_`date +%H_%M_%S`.out;\\
echo "# Replication Setup";\\
unsetenv gtm_repl_instance;\\
$MUPIP set -region "*" $journalstr -replic=on -inst >&! journalcfg_`date +%H_%M_%S`.out;\\
setenv gtm_repl_instance "mumps.repl";\\
$gtm_tst/com/passive_start_upd_enable.csh >&! passive_start_`date +%H_%M_%S`.out;\\
setenv serverlog `ls SRC_*`\\
'

# Sets regular expression to search within server log and syslog, also sets the file to keep PID.
alias prepare '\\
echo \# \!:1;\\
setenv logmess \(REPLINSTFREEZECOMMENT\).\*\(\!:1\);\\
setenv gtm_white_box_test_case_enable 1;\\
setenv gtm_white_box_test_case_number \!:2;\\
setenv pidf p${pnum}.outx;\\
setenv syslog_before1 `date +"%b %e %H:%M:%S"`;\\
'

alias finalize '\\
echo "# End of this test. Log number: $pnum";\\
setenv pnum `expr $pnum + 1`;\\
'

# Checks syslog and server log for the expected messages.
alias wbdiswait '\\
unsetenv gtm_white_box_test_case_enable;\\
unsetenv gtm_white_box_test_case_number;\\
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog${pnum}.txt "" "$logmess";\\
$gtm_tst/com/wait_for_log.csh -log $serverlog -useE -message "$logmess" -duration 600;\\
'
# Unfreeze and wait for unfreeze messages in both syslog and server log.
alias unfreezecheck '\\
echo "# Unfreezing";\\
$MUPIP replicate -source -freeze=off >>&! unfreeze.out;\\
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog${pnum}.txt "" "REPLINSTUNFROZEN";\\
$gtm_tst/com/wait_for_log.csh -log $serverlog -message "REPLINSTUNFROZEN -count $unfreezecount";\\
setenv unfreezecount `expr $unfreezecount + 1`;\\
'

alias stoppid '\\
set pid=`$head -n 1 $pidf`;\\
echo "Stopping: " $pid;\\
$MUPIP stop $pid >>&! mupip_stop.logx;\\
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog${pnum}.txt "" "FORCEDHALT";\\
'

# End this test after doing MUPIP stop to the offender process.
# This is done to avoid repeated freezes caused by the offender process
alias endwithkill '\\
wbdiswait;\\
stoppid;\\
unfreezecheck;\\
finalize;\\
'
# End this test without stopping offender process
alias testend '\\
wbdiswait;\\
unfreezecheck;\\
finalize;\\
'

setenv gtm_custom_errors $gtm_tools/custom_errors_sample.txt
setenv gtm_white_box_test_case_count 1
setenv pnum 1
setenv unfreezecount 1

createdb
if ("MM" != $acc_meth) then
    prepare DBBMLCORRUPT 70
    ($gtm_exe/mumps -run %XCMD 'write $job,! set ^x=2' >&! $pidf &)
    endwithkill

    # This error can take time to generate. Be patient.
    prepare DBDANGER 71
    ($gtm_exe/mumps -run %XCMD 'write $job,! set ^x=3 set ^x=4' >&! $pidf &)
    endwithkill

    prepare DBFSYNCERR 72
    ($gtm_exe/mumps -run %XCMD 'write $job,! set ^x=5' >&! $pidf &)
    testend
else
    setenv pnum `expr $pnum + 3`
endif

# -999 is bogus value because we don't need WB test case to cause this error.
prepare GBLOFLOW -999
$MUPIP set -exten=0 -reg "*"
($gtm_exe/mumps -run %XCMD 'write $job,! for i=1:1  set ^a(i)=$justify(1,200)' >&! $pidf &)
wbdiswait
unfreezecheck
$MUPIP set -exten=100 -reg "*"
finalize

prepare GVDATAFAIL 73
($gtm_exe/mumps -run %XCMD 'write $job,! set ^x=1000 write $data(^x) set ^x=6' >&! $pidf &)
testend

prepare GVGETFAIL 74
($gtm_exe/mumps -run %XCMD 'write $job,! set ^x=1000 write $get(^x) set ^x=7' >&! $pidf &)
testend

prepare GVINCRFAIL 75
($gtm_exe/mumps -run %XCMD 'write $job,! if $incr(^x)' >&! $pidf &)
testend

prepare GVPUTFAIL 75
($gtm_exe/mumps -run %XCMD 'write $job,! set ^x=8' >&! $pidf &)
testend

prepare GVKILLFAIL 76
($gtm_exe/mumps -run %XCMD 'write $job,! kill ^x' >&! $pidf &)
testend

prepare GVORDERFAIL 77
($gtm_exe/mumps -run %XCMD 'write $job,! set ^x=8 write $order(^x)' >&! $pidf &)
testend

prepare GVQUERYFAIL 78
($gtm_exe/mumps -run %XCMD 'write $job,! s ^x=9 write $query(^x)' >&! $pidf &)
testend

prepare GVQUERYGETFAIL 79
($gtm_exe/mumps -run %XCMD 'write $job,! set ^y(1)=10 merge ^y=^x' >&! $pidf &)
testend

if ("MM" != $acc_meth) then
    prepare OUTOFSPACE 81
    ($gtm_exe/mumps -run %XCMD 'write $job,! set ^x=10' >&! $pidf &)
    testend
else
    setenv pnum `expr $pnum + 1`
endif

# This error can take time to generate. Be patient.
prepare JNLCLOSE 69
($gtm_exe/mumps -run %XCMD 'write $job,! set ^x=3' >&! $pidf &)
testend

$MUPIP replicate -source -shutdown -timeout=0

\mkdir t1
\mv mumps.dat t1/
\mv mumps.gld t1/
\mv mumps.mjl* t1/
\mv mumps.repl t1/
\mv $serverlog t1/${serverlog}x
setenv unfreezecount 1


createdb

prepare TRIGDEFBAD 31

# The following damages database to cause TRIGDEFBAD
alias dse_corrupt '$DSE overwrite -block=3 -offset=\!:1 -data=\!:2'
cat << CAT_EOF >&! test.trg
+^a(acn=:) -commands=SET -xecute="set ^a(acn,acn)=\$ztval"
CAT_EOF
$MUPIP trigger -triggerfile=test.trg -noprompt
# Corrupt the 1-byte value field of the ^#t("a","#LABEL") node.
# The DSE DUMP of block 3 will display something like the below
#	Rec:E  Blk 3  Off FF  Size C  Cmpc 8  Key ^#t("a","#LABEL")
# In this case, we want to add 0xFF and 0xC and subtract 1 to get the offset of the value field.
# And then use that to do the corruption.
$DSE dump -block=3 >&! dse_dump_bl3.out
set corruptoffset = `$tst_awk '/#LABEL/ {a=strtonum("0x"$5)+strtonum("0x"$7)-1} END{ printf "%X\n", a}' dse_dump_bl3.out`
dse_corrupt $corruptoffset "."
($gtm_exe/mumps -r %XCMD 'write $job,! set ^a(1)=1,^b(1)=1' >&! $pidf &)
testend

prepare JNLFILOPN 43
($gtm_exe/mumps -run %XCMD 'write $job,! set ^x=11' >&! $pidf &)
testend

\mv $serverlog{,x}
$MUPIP replicate -source -shutdown -timeout=0

# Clean up relinkctl shared memory.
$MUPIP rundown -relinkctl >&! mupip_rundown_rctl.logx

# dbcheck does not make sense in a damaged database so we don't do it.
