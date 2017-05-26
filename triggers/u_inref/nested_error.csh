#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test of a secondary (nested) error inside $etrap AFTER a primary TRIGTCOMMIT error
# In addition, test various scenarios of TCOMMITDISALLOW error
#
# TRIGTCOMMIT
#
# TRIGTCOMMIT, TCOMMIT at $ZTLEVEL=LLLL not allowed as corresponding
# 		TSTART was done at lower $ZTLEVEL=BBBB
#
# Run Time Error:  A TCOMMIT in trigger logic attempted to complete the
# active transaction that was started outside of the current trigger.
# Because trigger actions are designed to be atomic with the update
# initiating them, this is an error.
#
#Action: Check the logic that led to the TCOMMIT.

# TRIGTLVLCHNG
#
# TRIGTLVLCHNG, Detected a net transaction level ($TLEVEL) change during
# 		trigger tttt. Transaction level must be the same at exit as when the
# 		trigger started
#
# Run Time Error:  While the trigger logic can use balanced sub-transactions,
# it can't cause a net change in $TLEVEL.
#
# Action: Review the transaction management (TSTART, TCOMMIT and
# TROLLBACK) within trigger logic to ensure that it commits or rolls
# back any transactions it starts and does not attempt to commit or
# rollback any transaction started prior to, or by, the trigger update.

# the same trigger is set to the same value several times, forcibly unset gtm_gvdupsetnoop
unsetenv gtm_gvdupsetnoop

# ------------------------------------------------------
# --- Create trignestederror.trg file (input for mupip trigger)
cat << CAT_EOF  > trignestederror.trg
-*
+^a(subs=:) -command=S -xecute=<<
	set (^c(subs),^b(subs))=\$ZTVAlue
	goto label1
	write "Should not get here",!
label1
	set ^d(subs)=\$ZTVAlue
	do next
	quit
next
	set ^e(subs)=\$ZTVAlue
	quit
>>
+^b(subs=:) -command=K,ZK -xecute="xecute ""\$ZTRIGgerop ^a(""_subs_"")"""
+^c(:) -command=ZTK -xecute="set a=\$ZTWOrmhole kill ^b,^e"
CAT_EOF
$convert_to_gtm_chset trignestederror.trg

# set gtm_trigger_etrap before dbcreate so that the replicated side gets
# the etrap. set test_specific_trig_file so that dbcreate loads the
# trigger file
setenv test_specific_trig_file "`pwd`/trignestederror.trg"
setenv gtm_trigger_etrap 'w $c(9),"$zlevel=",$zlevel," : $ztlevel=",$ztle," : $ZSTATUS=",$zstatus,! s $ecode=""'
$gtm_tst/com/dbcreate.csh mumps
unsetenv gtm_trigger_etrap
$MUPIP set $tst_jnl_str -reg "*" >&! subtest_set_jnl.out

# ------------------------------------------------------
#
echo ""
echo "---------------------------"
echo "Testing tcommit in err trap"
$gtm_exe/mumps -run nestederror

echo ""
echo "---------------------------"
echo "Testing conditional tcommit in err trap"
$gtm_exe/mumps -run nestederror 1

echo ""
echo "---------------------------"
echo "Testing conditional trollback in err trap"
$gtm_exe/mumps -run nestederror 2

# ------------------------------------------------------
echo ""
$gtm_exe/mumps -run setup^tcommitdisallow
$gtm_exe/mumps -run tcommitdisallow 1
$gtm_exe/mumps -run tcommitdisallow 2
$gtm_exe/mumps -run tcommitdisallow 3
$gtm_exe/mumps -run tcommitdisallow 4
$gtm_exe/mumps -run tcommitdisallow 5
$gtm_exe/mumps -run tcommitdisallow 6
# The following subtests are temporarily disabled. Remove the below if/endif when GTM-7507 is fixed.
if ( 0 ) then
$gtm_exe/mumps -run tcommitdisallow 7
$gtm_exe/mumps -run tcommitdisallow 8
$gtm_exe/mumps -run tcommitdisallow 9
$gtm_exe/mumps -run tcommitdisallow 10
endif

$gtm_tst/com/dbcheck.csh -extract
