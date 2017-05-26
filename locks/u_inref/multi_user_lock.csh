#! /usr/local/bin/tcsh -f
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
if ($?test_replic == 1 ) then
	echo "This subtest is not applicable to replication"
	exit
endif

$gtm_tst/com/dbcreate.csh mumps
echo "Multiple users trying to grab same lock"

$gtm_tst/$tst/u_inref/user2.csh >&! user2.log

$GTM << EOF
do ^user1
set status=\$\$^waitchld(1,400)
halt
EOF

echo "The output from the second user is:"
echo "#########################################################"
$tst_awk '/###/ {printit=1} printit {print}' remote_user.log  | $tst_awk -f $gtm_tst/$tst/inref/mask_pid.awk
echo "#########################################################"
echo "End of Multiuser locks test"
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0	# do rundown if needed before moving on to next phase of test
								# that has to do an unsetenv gtm_db_counter_sem_incr

echo "# Test case for GTM-8157: GTMSECSHRPERM errors during process rundown (e.g. DSE QUIT) loop indefinitely"

# With 16K counter semaphore bump per process, the 32K counter overflow happens with just 2 processes
# and affects the GTMSECSHR invocations of this very sensitive test. So disable counter overflows.
unsetenv gtm_db_counter_sem_incr

# For the issue to happen, gtmsecshr should be owned by the user.
# The best way to do it and not disturb the actual installation is to softlink all but gtmsechr locally
# and point $gtm_dist to the local directory
mkdir -p $tst_ver/$tst_image
cd $tst_ver/$tst_image
foreach file ($gtm_dist/*)
	ln -s $file .
end
\rm gtmsecshr
cp -p $gtm_dist/gtmsecshr .
cd -
setenv save_gtm_dist "$gtm_dist"
setenv gtm_dist $PWD/$tst_ver/$tst_image
setenv gtm_exe $gtm_dist

# Start the second user process which sets a global and waits for dse process (of first user) to start
# Start dse process (first user) and exit after the second user's GT.M process exits
# Expect two GTMSECSHRPERM errors (not loop the error infinitely)

$gtm_tst/$tst/u_inref/user2.csh gtm8157 >&! user2_gtm8157.log
$gtm_tst/com/wait_for_log.csh -log gtm.lock -duration 300 -waitcreation
$gtm_exe/dse << DSE_EOF
spawn "touch dse.lock"
spawn "$gtm_tst/com/wait_for_log.csh -log gtm.done -duration 300 -waitcreation"
q
q
DSE_EOF

touch gtm8157.done

set bgproc = `$tst_awk '{print $NF}' user2_gtm8157.log`
$gtm_tst/com/wait_for_proc_to_die.csh $bgproc

setenv gtm_dist $save_gtm_dist
setenv gtm_exe $gtm_dist
$gtm_tst/com/dbcheck.csh
