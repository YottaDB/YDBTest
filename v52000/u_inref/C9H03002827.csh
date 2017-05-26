#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2007-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#=====================================================================
$echoline
cat << EOF
C9H03002827 -- Test for REPLINSTNOSHM error
This is to test that even though having the source server die when at an inconvenient time might result
	in a REPLINSTNOSHM error, the error stops once the source server is restarted.
1.	Create two primary instances and start source servers
2.	Start GTM process and do an update to each region, AREG and BREG. Do not halt the GTM process.
3.	Start another GTM process. Do not halt the GTM process.
4.	\$kill -15 the source server.
5.	Halt the GTM process started in Step 2.
6.	Update region BREG.  This will cause a REPLINSTNOSHM error if gtm_custom_errors env var is not set and not otherwise.
	Now restart the source server. And try another update. This should NOT cause a REPLINSTNOSHM error.
	The update should work fine now onwards. Let this GTM process run to completion.
7.	Try to create primary instance A without gtm_repl_instance defined.  Should cause a REPLINSTUNDEF error.
8.	Clean up from previous test.

EOF

if ($?test_replic == 0) then
    echo "Test needs to be run with -replic"
endif

$echoline
echo "#- Step 1:"
setenv gtm_repl_instance mumps.repl
$gtm_tst/com/dbcreate.csh mumps 3
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`

$echoline
echo '#- Step 2:'
$GTM << EOF
	set jmaxwait=0
	set jobid=1
	do ^job("gtm1^c9h03002827",1,"""""")
	quit
EOF

# Wait until the updates in Step 2 are finished
$gtm_tst/com/wait_for_log.csh -waitcreation -log midbgupdate1.txt -duration 900

$echoline
echo '#- Step 3:'
$GTM << EOF
	set jmaxwait=0
	set jobid=2
	do ^job("gtm2^c9h03002827",1,"""""")
	quit
EOF

# Now we need to wait until the first update in Step 3 is finished
$gtm_tst/com/wait_for_log.csh -waitcreation -log midbgupdate2.txt -duration 900

$echoline
echo '#- Step 4:'
$MUPIP replicate -source -checkhealth >&! health
set pidsrc=`$tst_awk  '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }' health`

echo "#  kill -15 source server for INSTANCE1."
$kill -15 $pidsrc
$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc 100
if ($status) then
	echo "TEST-E-ERROR source server $pidsrc did not die."
endif

# In case we hit a FAKE_ENOSPC freeze, force an unfreeze. Otherwise, BREG may not be run down
# when gtm1 exits (due to gds_rundown() running in safe_mode when the instance is frozen),
# in which case we won't see the REPLINSTNOSHM from gtm2 below.
$MUPIP replicate -source -freeze=off >&! unfreeze.out

$echoline
echo '#- Step 5:'
echo '# signal Step 2 process to stop'
touch endbgupdate1.txt

# Make sure Step 2 process has finished
$GTM << EOF
	set jobid=1
	do wait^job
EOF

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 b.dat # do rundown of b.dat if needed as later test relies on this

$echoline
echo '#- Step 6:'
echo '# signal Step 3 process to continue and unsuccessfully update region BREG'
touch endbgupdate2.txt
echo '# Now we need to wait until the second update that results in a potential REPLINSTNOSHM error is finished'
$gtm_tst/com/wait_for_log.csh -waitcreation -log midbgupdate3.txt -duration 900
echo '# Now restart source server'
$gtm_tst/com/SRC.csh "." $portno "" >>&! START_2.out
echo '# signal Step 3 process to continue and successfully update region BREG'
touch endbgupdate3.txt
echo '# Now we need to wait until the third update that does NOT result in a potential REPLINSTNOSHM error is finished'

# Make sure Step 3 process has finished
$GTM << EOF
	set jobid=2
	do wait^job
EOF

echo "# Now that Step 3 process is done, dump its output"
cat gtm2*.mjo1

$echoline
echo '#- Step 7:'
echo '# Try to cause a REPLINSTUNDEF error'
set save_repl_instance = `echo $gtm_repl_instance`
unsetenv gtm_repl_instance
$MUPIP replicate -instance -name=INSTANCE1 $gtm_test_qdbrundown_parms
if ($status == 0) then
	echo "TEST-E-ERROR Access should have caused an E-REPLINSTUNDEF"
endif

$gtm_exe/mumps -run ^c9h03002827

$echoline
echo '#- Step 8:'
echo '# Clean up and exit'
setenv gtm_repl_instance $save_repl_instance
$gtm_tst/com/dbcheck.csh
