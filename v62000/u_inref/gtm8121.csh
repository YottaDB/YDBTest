#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# Test that MUPIP RUNDOWN does not issue DBFLCORRP error
# Also test DSE CHANGE -FILE -CORRUPT_FILE works without NOCRIT
#

# Non-replication set of tests
echo "-----------------------------------------------------------------------------------------"
echo "Test case (1) : Test that DSE CHANGE -FILE -CORRUPT_FILE works without -NOCRIT (actually a test for GTM-7396)"
echo "-----------------------------------------------------------------------------------------"
$gtm_tst/com/dbcreate.csh mumps
$DSE << DSE_EOF
	change -file -corrupt_file=TRUE
	buff
DSE_EOF
echo ""
$DSE << DSE_EOF
	change -file -corrupt_file=FALSE
DSE_EOF

echo ""
$gtm_tst/com/dbcheck.csh

if (! $?test_replic) then
	echo "-----------------------------------------------------------------------------------------"
	echo "Test case (2a) : Test that MUPIP RUNDOWN works fine in case of DBFLCORRP error : REQRUNDOWN"
	echo "-----------------------------------------------------------------------------------------"
	setenv gtm_test_jnl NON_SETJNL	# To avoid random journal creation at dbcreate time
	$gtm_tst/com/dbcreate.csh mumps
	echo "Start backgrounded GT.M process that does updates"
	setenv gtm_test_jobid 1
	$gtm_exe/mumps -run startbkgrnd^gtm8121
	$DSE << DSE_EOF
		change -file -corrupt=TRUE
		buff
DSE_EOF

	echo ""
	echo "Try to start GT.M. Expect DBFLCORRP error"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	echo "Kill backgrounded GT.M process"
	# It is possible the backgrounded GT.M process died on its own due to a DBFLCORRP error (see mrep <gtm8121_test_failures>).
	# So redirect output of kill to a file in case it finds the pid non-existent.
	source killbkgrnd.csh	 >& killbkgrnd.out

	set semid = `$gtm_exe/mupip ftok mumps.dat | $tst_awk '/mumps/ {print $3}'`
	echo "Remove database semaphore to induce REQRUNDOWN situation"
	$gtm_tst/com/ipcrm -s $semid

	echo "Try to start GT.M. Expect REQRUNDOWN error now"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	echo "Try to start DSE. Should get REQRUNDOWN error"
	$DSE << DSE_EOF
		quit
DSE_EOF

	echo ""
	echo "Start MUPIP RUNDOWN. Should work fine without DBFLCORRP error. Should also fix REQRUNDOWN error."
	$MUPIP rundown -reg "*"

	echo "Try to start GT.M. Expect DBFLCORRP error still"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	echo "Try to start DSE. Should NOT get REQRUNDOWN error. Fix DBFLCORRP error"
	$DSE << DSE_EOF
		change -file -corrupt_file=FALSE
		buff
		quit
DSE_EOF

	echo ""
	echo "Try to start GT.M. Expect NO errors"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	$MUPIP rundown -relinkctl >&! mupip_rundown_rctl1.logx

	echo "-----------------------------------------------------------------------------------------"
	echo "Test case (2b) : Test that MUPIP RUNDOWN works fine in case of DBFLCORRP error : REQRECOV"
	echo "-----------------------------------------------------------------------------------------"
	setenv gtm_test_jnl "SETJNL"
	$gtm_tst/com/dbcreate.csh mumps
	echo "Start backgrounded GT.M process that does updates"
	setenv gtm_test_jobid 2
	$gtm_exe/mumps -run startbkgrnd^gtm8121
	$DSE << DSE_EOF
		change -file -corrupt=TRUE
		buff
DSE_EOF

	echo ""
	echo "Try to start GT.M. Expect DBFLCORRP error"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	echo "Kill backgrounded GT.M process"
	# It is possible the backgrounded GT.M process died on its own due to a DBFLCORRP error (see mrep <gtm8121_test_failures>).
	# So redirect output of kill to a file in case it finds the pid non-existent.
	source killbkgrnd.csh	 >& killbkgrnd.out

	set semid = `$gtm_exe/mupip ftok mumps.dat | $tst_awk '/mumps/ {print $3}'`
	echo "Remove database semaphore to induce REQRECOV situation"
	$gtm_tst/com/ipcrm -s $semid

	echo "Try to start GT.M. Expect REQRECOV error now"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	echo "Try to start DSE. Should get REQRECOV error"
	$DSE << DSE_EOF
		quit
DSE_EOF

	echo ""
	echo "Start MUPIP RUNDOWN. Should issue error saying run MUPIP JOURNAL -RECOVER"
	$MUPIP rundown -reg "*"

	echo ""
	echo "Start MUPIP RUNDOWN -OVERRIDE. Should work fine without DBFLCORRP error. Should also fix REQRECOV error."
	$MUPIP rundown -override -reg "*"

	echo "Try to start GT.M. Expect DBFLCORRP error still"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	echo "Try to start DSE. Should NOT get REQRECOV error. Fix DBFLCORRP error"
	$DSE << DSE_EOF
		change -file -corrupt_file=FALSE
		buff
		quit
DSE_EOF

	echo ""
	echo "Try to start GT.M. Expect NO errors"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	$MUPIP rundown -relinkctl >&! mupip_rundown_rctl2.logx

	$gtm_tst/com/dbcheck.csh
else
	# Replication set of tests
	setenv gtm_test_jnl_nobefore 0	# We want to test REQROLLBACK error. For that we need before-image journaling.
	setenv acc_meth "BG"		# Before image journaling does not work with MM
	setenv tst_jnl_str "-journal=enable,on,before"
	setenv gtm_test_jnlfileonly 0	# To avoid the source server tripping over the corrupt db
	unsetenv gtm_test_jnlpool_sync	# ditto
	echo "--------------------------------------------------------------------------------------------"
	echo "Test case (2c) : Test that MUPIP RUNDOWN works fine in case of DBFLCORRP error : REQROLLBACK"
	echo "--------------------------------------------------------------------------------------------"
	$gtm_tst/com/dbcreate.csh mumps
	echo "Start backgrounded GT.M process that does updates"
	setenv gtm_test_jobid 3
	$gtm_exe/mumps -run startbkgrnd^gtm8121
	$DSE << DSE_EOF
		change -file -corrupt=TRUE
		buff
DSE_EOF

	echo ""
	echo "Try to start GT.M. Expect DBFLCORRP error"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	echo "Kill backgrounded GT.M process"
	# It is possible the backgrounded GT.M process died on its own due to a DBFLCORRP error (see mrep <gtm8121_test_failures>).
	# So redirect output of kill to a file in case it finds the pid non-existent.
	source killbkgrnd.csh	 >& killbkgrnd.out

	echo "Kill source server"
	$gtm_tst/com/primary_crash.csh "NO_IPCRM"

	set semid = `$gtm_exe/mupip ftok mumps.dat | $tst_awk '/mumps/ {print $3}'`
	echo "Remove database semaphore to induce REQROLLBACK situation"
	$gtm_tst/com/ipcrm -s $semid

	echo "Try to start GT.M. Expect REQROLLBACK error now"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	echo "Try to start DSE. Should get REQROLLBACK error"
	$DSE << DSE_EOF
		quit
DSE_EOF

	echo ""
	echo "Start MUPIP RUNDOWN. Should issue error saying run MUPIP JOURNAL -ROLLBACK"
	# If instance freeze is enabled, the jnlpool gets rundown first.
	# If it is not enabled, the jnlpool gets rundown last.
	# Since instance freeze is enabled randomly in test system, sort the output to avoid ordering issues.
	$MUPIP rundown -reg "*" |& sort

	echo ""
	echo "Start MUPIP RUNDOWN -OVERRIDE. Should work fine without DBFLCORRP error. Should also fix REQROLLBACK error."
	$MUPIP rundown -override -reg "*"

	echo "Try to start GT.M. Expect DBFLCORRP error still"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	echo "Try to start DSE. Should NOT get REQROLLBACK error. Fix DBFLCORRP error"
	$DSE << DSE_EOF
		change -file -corrupt_file=FALSE
		buff
		quit
DSE_EOF

	echo ""
	echo "Try to start GT.M. Expect NO errors"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	$MUPIP rundown -relinkctl >&! mupip_rundown_rctl3.logx
	echo "Run MUPIP JOURNAL -ROLLBACK to fix crashed journal files"
	$gtm_tst/com/mupip_rollback.csh "" -back -lost=rollback3.los "*" >&! mupip_rollback_3.logx

	echo "Restarting source server"
	setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
	setenv start_time `date +%H_%M_%S`
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null "">>&!"" START_${start_time}.out"
	$gtm_tst/com/dbcheck.csh -extract

	echo "--------------------------------------------------------------------------------------------"
	echo "Test case (2d) : Test that MUPIP JOURNAL -ROLLBACK works fine in case of DBFLCORRP error"
	echo "--------------------------------------------------------------------------------------------"
	$gtm_tst/com/dbcreate.csh mumps
	echo "Start backgrounded GT.M process that does updates"
	setenv gtm_test_jobid 4
	$gtm_exe/mumps -run startbkgrnd^gtm8121
	$DSE << DSE_EOF
		change -file -corrupt=TRUE
		buff
DSE_EOF

	echo ""
	echo "Try to start GT.M. Expect DBFLCORRP error"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	echo "Kill backgrounded GT.M process"
	# It is possible the backgrounded GT.M process died on its own due to a DBFLCORRP error (see mrep <gtm8121_test_failures>).
	# So redirect output of kill to a file in case it finds the pid non-existent.
	source killbkgrnd.csh	 >& killbkgrnd.out

	echo "Kill source server"
	$gtm_tst/com/primary_crash.csh "NO_IPCRM"

	set semid = `$gtm_exe/mupip ftok mumps.dat | $tst_awk '/mumps/ {print $3}'`
	echo "Remove database semaphore to induce REQROLLBACK situation"
	$gtm_tst/com/ipcrm -s $semid

	echo "Try to start GT.M. Expect REQROLLBACK error now"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	echo "Try to start DSE. Should get REQROLLBACK error"
	$DSE << DSE_EOF
		quit
DSE_EOF

	echo ""
	echo "Start MUPIP RUNDOWN. Should issue error saying run MUPIP JOURNAL -ROLLBACK"
	# If instance freeze is enabled, the jnlpool gets rundown first.
	# If it is not enabled, the jnlpool gets rundown last.
	# Since instance freeze is enabled randomly in test system, sort the output to avoid ordering issues.
	$MUPIP rundown -reg "*" |& sort

	echo ""
	echo "Start MUPIP JOURNAL -ROLLBACK. Should work fine without DBFLCORRP error. Should fix REQROLLBACK and DBFLCORRP error."
	# If instance is supplementary (randomly chosen by test system), an additional YDB-I-RLBKSTRMSEQ shows up in the output
	# To keep reference file deterministic, filter that out.
	$gtm_tst/com/mupip_rollback.csh "" -back -lost=rollback4.los "*" |& $grep -v RLBKSTRMSEQ

	echo ""
	echo "Try to start GT.M. Expect NO errors"
	$GTM << GTM_EOF
		write ^bkgrndpid,!
GTM_EOF

	$MUPIP rundown -relinkctl >&! mupip_rundown_rctl4.logx

	echo "Restarting source server"
	setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
	setenv start_time `date +%H_%M_%S`
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null "">>&!"" START_${start_time}.out"
	$gtm_tst/com/dbcheck.csh -extract
	# filter out messages from dbcheck which vary based on test variables (e.g., gtm_test_fake_enospc)
	foreach file (dse_buffer_flush.out dse_df.log rf_sync_*_src_sc.out src_checkhealth.log)
		foreach msg ("YDB-[EW]-DBFLCORRP" "YDB-E-DBNOREGION")
			$gtm_tst/com/check_error_exist.csh $file "$msg" >>& ${file:as/./_/}_err.outx
		end
	end
endif
# filter out DBFLCORRP error message from *.mje* if any. See mrep <gtm8121_test_failures>
foreach file (child_gtm8121*.mje*)
	$gtm_tst/com/check_error_exist.csh $file "YDB-E-DBFLCORRP" "YDB-E-NOTALLDBRNDWN" "YDB-E-GVRUNDOWN" >& ${file:r}.tmpx
	if (-e ${file}x) then
		# YDB-E-... in *.mje*x will get caught by test framework. So rename file to escape from that.
		mv ${file}x $file:r.orig
	endif
end
