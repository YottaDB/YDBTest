#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
@ bno = 0
echo "Standalone access subtest for mupip backup.."
# Note: We redirect backup output to *.txt instead of *.out,
#       so that test system does not look for warnings there
#       and cause reference file problem. In the output
#       the order of warning is not deterministic. -- Layek 4/25/02
##############################################################yy
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 2
$gtm_tst/com/create_reg_list.csh
echo "GTM Process starts in background..."
setenv gtm_test_dbfill "SLOWFILL"
setenv gtm_test_jobcnt 2
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep 10		# To allow some data to be set for all regions
#
@ bno = $bno + 1; \mkdir back{$bno}
echo "$MUPIP backup * -newjnl ./back{$bno} : Will warn"
$MUPIP backup "*" -newjnl ./back{$bno} >& back{$bno}.txt
$grep -vE "%YDB-I-BACKUPTN, Transactions from|shmpool lock preventing backup buffer flush"  back{$bno}.txt |& sort -f
echo "Journal States:(expected DISABLED):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
@ bno = $bno + 1; \mkdir back{$bno}
echo "$MUPIP backup *  -nonewjnl ./back{$bno} : Will succeed"
$MUPIP backup "*" -nonewjnl ./back{$bno} >& back{$bno}.txt
$grep -vE "%YDB-I-BACKUPTN, Transactions from|shmpool lock preventing backup buffer flush"  back{$bno}.txt |& sort -f
echo "Journal States:(expected DISABLED):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
@ bno = $bno + 1; \mkdir back{$bno}
echo "$MUPIP backup *  -newjnl=noprevlink ./back{$bno} : Will warn"
$MUPIP backup "*" -newjnl=noprevlink ./back{$bno} >& back{$bno}.txt
$grep -vE "%YDB-I-BACKUPTN, Transactions from|shmpool lock preventing backup buffer flush"  back{$bno}.txt |& sort -f
echo "Journal States:(expected DISABLED):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
@ bno = $bno + 1; \mkdir back{$bno}
echo "$MUPIP backup *  -newjnl=prevlink ./back{$bno} : Will warn"
$MUPIP backup "*" -newjnl=prevlink ./back{$bno} >& back{$bno}.txt
$grep -vE "%YDB-I-BACKUPTN, Transactions from|shmpool lock preventing backup buffer flush"  back{$bno}.txt |& sort -f
echo "Journal States:(expected DISABLED):"
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
echo "Stop the background processes"
$gtm_tst/com/endtp.csh  >>& endtp1.out
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/checkdb.csh
#
##############################################################yy
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 5 125 1000 1024 4096 1024 4096
if ("ENCRYPT" == $test_encryption) then
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed 's|dat: "'$cwd'/|dat: "|' ${gtmcrypt_config}.orig > $gtmcrypt_config
	setenv gtmcrypt_config $cwd/gtmcrypt.cfg
endif
$gtm_tst/com/create_reg_list.csh
echo "Take AREG in state 1"
echo "$MUPIP set -journal=enable,off,[no]before -reg AREG"
if (("MM" == $acc_meth) || (1 == $gtm_test_jnl_nobefore)) then
	$MUPIP set -journal=enable,off,nobefore -reg AREG
else
	$MUPIP set -journal=enable,off,before -reg AREG
endif
echo "Take BREG in state 2"
echo "$MUPIP set -journal=enable,on,[no]before -reg BREG"
$MUPIP set $tst_jnl_str -reg BREG
echo "GTM Process starts in background..."
setenv gtm_test_jobid 2
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep 10		# To allow some data to be set for all regions
#
@ bno = $bno + 1; \mkdir back{$bno}
echo "$MUPIP backup * -newjnl ./back{$bno}"
$MUPIP backup "*" -newjnl ./back{$bno} >& back{$bno}.txt
$grep -vE "%YDB-I-BACKUPTN, Transactions from|shmpool lock preventing backup buffer flush"  back{$bno}.txt |& sort -f
echo "Journal States:"
$gtm_tst/$tst/u_inref/wait_for_update.csh
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
$MUPIP journal -show=head -for b.mjl | & $grep "Prev journal" | $grep "b.mjl_"  >& show{$bno}.txt
if (0 != $status) then
	echo "Previous link not found for b.mjl"
	exit
endif
#
@ bno = $bno + 1; \mkdir back{$bno}
echo "$MUPIP backup *  -nonewjnl ./back{$bno}"
$MUPIP backup "*" -nonewjnl ./back{$bno} >& back{$bno}.txt
$grep -vE "%YDB-I-BACKUPTN, Transactions from|shmpool lock preventing backup buffer flush"  back{$bno}.txt |& sort -f
if ($status) then
	echo Above command failed
	exit
endif
echo "Journal States:"
$gtm_tst/$tst/u_inref/wait_for_update.csh
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
#
@ bno = $bno + 1; \mkdir back{$bno}
echo "$MUPIP backup *  -newjnl=noprevlink ./back{$bno}"
$MUPIP backup "*" -newjnl=noprevlink ./back{$bno} >& back{$bno}.txt
$grep -vE "%YDB-I-BACKUPTN, Transactions from|shmpool lock preventing backup buffer flush"  back{$bno}.txt |& sort -f
echo "Journal States:"
$gtm_tst/$tst/u_inref/wait_for_update.csh
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
$MUPIP journal -show=head -for b.mjl | & $grep "Prev journal" | $grep "b.mjl_"  >& show{$bno}.txt
if (0 == $status) then
	echo "Previous link found for b.mjl"
	exit
endif
#
@ bno = $bno + 1; \mkdir back{$bno}
echo "$MUPIP backup *  -newjnl=prevlink ./back{$bno}"
$MUPIP backup "*" -newjnl=prevlink ./back{$bno} >& back{$bno}.txt
$grep -vE "%YDB-I-BACKUPTN, Transactions from|shmpool lock preventing backup buffer flush"  back{$bno}.txt |& sort -f
echo "Journal States:"
$gtm_tst/$tst/u_inref/wait_for_update.csh
$gtm_tst/$tst/u_inref/check_jnl_state.csh "Journal State "
$MUPIP journal -show=head -for b.mjl | & $grep "Prev journal" | $grep "b.mjl_"  >& show{$bno}.txt
if (0 != $status) then
	echo "Previous link not found for b.mjl"
	exit
endif
$MUPIP journal -show=head -for a.mjl | & $grep "Prev journal" | $grep "a.mjl_"  >& show{$bno}.txt
if (0 != $status) then
	echo "Previous link not found for a.mjl"
	exit
endif
#
echo "Stop the background processes"
$gtm_tst/com/endtp.csh  >>& endtp1.out
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/checkdb.csh
#
foreach file (`ls ./back*/*.dat`)
	cd ${file:h}
	$MUPIP integ -file ${file:t} >>& ../integ.out
	if ($status) echo "$file has integ errors"
	cd ..
end
$grep "No errors detected by integ" integ.out
#
