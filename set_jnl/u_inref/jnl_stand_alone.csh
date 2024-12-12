#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This subtest covers test cases 38 to 44 (excluding replic)
# standalone access and journal state switching
echo "Standalone access subtest .."
$gtm_tst/com/dbcreate.csh mumps 4 125 1000 1024 4096 1024 4096
$gtm_tst/com/create_reg_list.csh
echo Test Case 38
echo "Journal state switching from 0 to 1 or 0 to 2 needs Standalone access"
echo "GTM Process starts in background..."
setenv gtm_test_dbfill "SLOWFILL"
setenv gtm_test_jobcnt 2
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep 10		# To allow some data to be set for all regions
echo "Try 0 to 1: $MUPIP set -journal=enable,off,nobefore -reg *"
set output = "set_jnl_0_to_1.out"
$MUPIP set -journal=enable,off,nobefore -reg "*" >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOFINISH' ${output}x >&! $output
echo "Journal States:(expected DISABLED):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
echo "Try 0 to 2: $MUPIP set -journal=enable,on,nobefore -reg *"
set output = "set_jnl_0_to_2.out"
$MUPIP set -journal=enable,on,nobefore -reg "*" >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOFINISH' ${output}x >&! $output
echo "Journal States:(expected DISABLED):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
echo "Try 0 to 0: $MUPIP set -journal=disable -reg *"
$MUPIP set -journal=disable -reg "*" |& sort -f
echo "Journal States:(expected DISABLED):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
echo "Attempt setting qdbrundown flag (requires standalone access)"
set output = "set_qdbrundown.out"
$MUPIP set -region DEFAULT -qdbrundown >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-W-WCWRNNOTCHG' ${output}x >&! $output
echo "Stop the background processes"
$gtm_tst/com/endtp.csh  >>& endtp1.out
$gtm_tst/com/dbcheck.csh -nosprgde
$gtm_tst/com/checkdb.csh
##
echo ""
echo "Now try to switch journal state when no active M process is present:"
echo ""
echo "Try 0 to 0: $MUPIP set -journal=disable -reg *"
$MUPIP set -journal=disable -reg "*" |& sort -f
echo "Journal States:(expected DISABLED):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
echo "Try 0 to 1: $MUPIP set -journal=enable,off,nobefore -reg *"
$MUPIP set -journal=enable,off,nobefore -reg "*" |& sort -f
echo "Journal States:(expected OFF):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
echo "Change state to 0:"
$MUPIP set -journal=disable -reg "*" |& sort -f
echo "Try 0 to 2: $MUPIP set -journal=enable,on,nobefore -reg *"
$MUPIP set -journal=enable,on,nobefore -reg "*" |& sort -f
#
echo "Journal States:(expected ON):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
echo Case 39
#
echo "Journal state switching from 1 or 2 to 0 needs standalone access"
echo "Change state to 1:"
$MUPIP set -journal=enable,off,before -reg "*" |& sort -f
echo "GTM Process starts in background..."
setenv gtm_test_jobid 2
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep 10		# To allow some data to be set for all regions
echo "Try to swtich from 1 to 0"
set output = "set_jnl_1_to_0.out"
$MUPIP set -journal=disable -reg "*" >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOFINISH' ${output}x >&! $output
echo "Journal States:(expected OFF):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
echo "Journal state switch from 1 to 1"
$MUPIP set -journal=off -reg "*" |& sort -f
echo "Journal States:(expected OFF):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
echo "Journal state switch from 1 to 2"
$MUPIP set -journal=on,before -reg "*" |& sort -f
echo "Journal States:(expected ON):"
$gtm_tst/$tst/u_inref/wait_for_update.csh
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
echo "Journal state switch from 2 to 2"
$MUPIP set -journal=on,before -reg "*" |& sort -f
echo "Journal States:(expected ON):"
$gtm_tst/$tst/u_inref/wait_for_update.csh
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
echo "Journal state switch from 2 to 1"
$MUPIP set -journal=off -reg "*" |& sort -f
echo "Journal States:(expected OFF):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
echo "Journal state switch from 1 to 2"
$MUPIP set -journal=on,before -reg "*" |& sort -f
echo "Journal States:(expected ON):"
$gtm_tst/$tst/u_inref/wait_for_update.csh
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
echo "Journal state switch from 2 to 0"
set output = "set_jnl_2_to_0.out"
$MUPIP set -journal=disable -reg "*" >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOFINISH' ${output}x >&! $output
echo "Journal States:(expected ON):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
echo "Stop the background process"
$gtm_tst/com/endtp.csh  >>& endtp2.out
$gtm_tst/com/dbcheck.csh -nosprgde
$gtm_tst/com/checkdb.csh
\mkdir ./save1; \cp {*.dat,*.mjl*} ./save1
$gtm_tst/com/dbcheck_base.csh -nosprgde
#
echo "No process are running in the background"
echo "Journal state switch to 0"
$MUPIP set -journal=disable -reg "*" |& sort -f
echo "Current state is 0:"
#
echo Case 42 and 43
#
echo "BUFFER_SIZE change requires stand alone access, but most others do not"
echo "Switch journal state to 2"
$MUPIP set -journal=enable,before,epoch=30 -reg "*" |& sort -f
echo "GTM Process starts in background..."
setenv gtm_test_jobid 3
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep 10		# To allow some data to be set for all regions.
echo "# Expect all the below buffer_size change commands to error out with 'File is in use/File already open'"
set output = "set_jnl_buff_areg.out"
$MUPIP set -journal=before,bu=256 -reg AREG >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOFINISH' ${output}x >&! $output
#
set output = "set_jnl_buff_bdat.out"
$MUPIP set -journal=before,bu=256 -file b.dat >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOFINISH' ${output}x >&! $output
#
set output = "set_jnl_buff_creg.out"
$MUPIP set -journal=before,bu=256 -reg CREG >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOFINISH' ${output}x >&! $output
#
set output = "set_jnl_buff_mumpsdat.out"
$MUPIP set -journal=before,bu=1024 -file mumps.dat >&! ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOFINISH' ${output}x >&! $output
#
echo "Journal Buffer Size:(expected 2308)"
$gtm_tst/$tst/u_inref/wait_for_update.csh
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal Buffer Size"
echo "Some qualifiers do not need standalone access"
echo "With nobefore option"
##
$MUPIP set -journal=nobefore,alignsize=4096 -file mumps.dat
#
$MUPIP set -journal=nobefore,allocation=2048 -file mumps.dat
#
$MUPIP set -journal=nobefore,autoswitchlimit=2097152 -file mumps.dat
#
$MUPIP set -journal=nobefore,extension=300 -file mumps.dat
#
$MUPIP set -journal=nobefore,filename="mumps_standalone_nobefore.mjl" -file mumps.dat
#
$MUPIP set -journal=nobefore,nosync_io -file mumps.dat
#
$MUPIP set -journal=nobefore,yield_limit=900 -file mumps.dat
#
$MUPIP set -journal=nobefore,epoch=1 -file mumps.dat
#
$gtm_tst/$tst/u_inref/wait_for_update.csh
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal"
##
echo "With before option"
$MUPIP set -journal=before,alignsize=4096 -reg "*" |& sort -f
#
$MUPIP set -journal=before,allocation=4000 -reg "*" |& sort -f
##DISABLED_TEST##REENABLE##
# See C9C07-002084 mupip set -journal needs to use same user specified value for all regions
#$MUPIP set -journal=before,autoswitchlimit=4194304 -reg "*" |& sort -f
##END_DISABLE##
#
$MUPIP set -journal=before,extension=200 -reg "*" |& sort -f
#
$MUPIP set -journal=before,filename="a_standalone_before.mjl" -file a.dat
#
$MUPIP set -journal=before,nosync_io -reg "*" |& sort -f
#
$MUPIP set -journal=before,yield_limit=1000 -reg "*" |& sort -f
#
$MUPIP set -journal=before,epoch=1 -reg "*" |& sort -f
#
$gtm_tst/$tst/u_inref/wait_for_update.csh
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal"
echo "Stop the background process"
$gtm_tst/com/endtp.csh  >>& endtp3.out
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/checkdb.csh
echo "No background processes are running"
echo "Now change journal buffer size"
$MUPIP set -journal=before,bu=2308 -reg "*" |& sort -f
#
echo "Journal Buffer Size:(expected 2308)"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal Buffer Size"
#
\mkdir ./save2; \cp {*.dat,*.mjl*} ./save2
$gtm_tst/com/dbcheck_base.csh -nosprgde
echo "Verify All Journals:"
foreach jnl (`ls *.mjl*`)
echo "$MUPIP journal -verify -for $jnl" >>& verification.out
$MUPIP journal -verify -for $jnl >>& verification.out
if ($status) echo $jnl
end
