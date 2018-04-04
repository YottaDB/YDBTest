#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
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
unset backslash_quote
alias check_mjf 'unset echo; ($tst_awk -f $gtm_tst/$tst/inref/extract.awk -v "user=$USER" -v "host=$HOST:r:r:r" \!:* | sed '"'"'s/\\/ %/g;s/.*:://g'"'"' | $tst_awk -F% -f $gtm_tst/$tst/inref/extract_summary.awk ); $gtm_exe/mumps -run mjfhdate \!:* > \!:*_date; set echo'
##NOTE extract_summary.awk ignores EPOCH records

$gtm_tst/com/dbcreate.csh .
$MUPIP set -journal="enable,on,before,file=mumps1.mjl" -file mumps.dat

$gtm_tst/com/abs_time.csh time1 |& sed 's/into time1:/into time1:GTM_TEST_DEBUGINFO/'
set time1 = `cat time1_abs`
echo "start second process..."
$gtm_tst/$tst/u_inref/same_user_multi_generation_ztp.csh > process.log
##############################################################
echo "Wait for second process to finish its processing..."
$GTM << ENDWAIT
w "\$H = GTM_TEST_DEBUGINFO ",\$H,!
for i=1:1:240 quit:\$data(^sema1)  h 1
i i=240 w "TEST-E-TIMEOUT: USER2 DID NOT FINISH ITS PROCESSING"
w "second process should have finished",!
w "\$H = GTM_TEST_DEBUGINFO ",\$H,!
ENDWAIT

echo "Updates done, test..."
echo ""
##############################################################

set echo
echo "Before crash:"
# make sure everything is in the journal
$GTM << EOF
view "JNLFLUSH"
h
EOF

$MUPIP journal -extract=ext1b.mjf -detail -forward mumps1.mjl  -fences=none
check_mjf ext1b.mjf
$MUPIP journal -extract=ext2b.mjf -detail -forward mumps2.mjl  -fences=none
check_mjf ext2b.mjf
# Also make sure that recover errors out with an active process accessing the db.
unset echo
echo "$MUPIP journal -recover -extract=norecov.mjf -detail -lost=norecov.lost -broken=norecov.broken -back mumps2.mjl"
set output = "journal_recover.out"
$MUPIP journal -recover -extract=norecov.mjf -detail -lost=norecov.lost -broken=norecov.broken -back mumps2.mjl >& ${output}x
$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOACTION' ${output}x >&! $output

$gtm_tst/com/gtm_crash.csh
$MUPIP rundown -reg "*" -override
$gtm_tst/$tst/u_inref/second_process_end.csh

# since there was no ZTC before the gtm_crash, all updates should go into
# the broken file
unset echo
echo '$MUPIP journal -recover -extract=recov.mjf -detail -lost=recov.lost -broken=recov.broken -back mumps2.mjl -since=$time1'
$MUPIP journal -recover -extract=recov.mjf -detail -lost=recov.lost -broken=recov.broken -back mumps2.mjl -since=\"$time1\"
check_mjf recov.mjf
check_mjf recov.broken
check_mjf recov.lost
unset echo
$grep SET ext1b.mjf ext2b.mjf | sed 's/.*\\//g' > before_recov.gbl
$grep SET recov.mjf recov.lost recov.broken| sed 's/.*\\//g'  > recov.gbl
diff before_recov.gbl recov.gbl > /dev/null
if ($status) then
	echo "TEST-E-VERIFY FAILED"
	diff before_recov.gbl recov.gbl
else
	echo "VERIFY PASSED"
endif

echo '$MUPIP journal -extract=ext1.mjf -detail -forward mumps1.mjl  -fences=none'
$MUPIP journal -extract=ext1.mjf -detail -forward mumps1.mjl  -fences=none
check_mjf ext1.mjf
unset echo

echo '$MUPIP journal -extract=ext2.mjf -detail -forward *mumps2.mjl_*  -fences=none'
$MUPIP journal -extract=ext2.mjf -detail -forward *mumps2.mjl_*  -fences=none
check_mjf ext2.mjf

$GTM << EOF
S ^AAA=1
h
EOF

$gtm_tst/com/dbcheck.csh
