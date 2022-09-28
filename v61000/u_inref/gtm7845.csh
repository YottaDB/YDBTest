#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test simply crashes the database right after an update leaving shared memory and semaphores behind. After that, we (randomly)
# remove shared memory and see if both semaphores are removed. Set remove_shm to 1 to remove shared memory.

$gtm_tst/com/dbcreate.csh mumps >& dbcreate_out.out

if (! $?remove_shm) then
    setenv remove_shm `$gtm_exe/mumps -run rand 2`
endif
echo "# Remove shared memory inside gtm7845 test" >> settings.csh
echo "setenv remove_shm $remove_shm" >> settings.csh

echo '/mumps.dat/{print $3}' > semid.awk #BYPASSOK
echo '/mumps.dat/{print $6}' > shmid.awk #BYPASSOK

$GTM << EOF
set ^x=1
write "Saving access semaphore id to semid.txt",!
zsystem "\$gtm_exe/mupip ftok mumps.dat |& \$tst_awk -f semid.awk  | tee semid.txt"
write "Saving shared memory id to shmid.txt",!
zsystem "\$gtm_exe/mupip ftok mumps.dat |& \$tst_awk -f shmid.awk | tee shmid.txt"
write "Crashing database "
zsystem "$kill9 "_\$j
EOF

set semid = `cat semid.txt`
set shmid = `cat shmid.txt`

if ($remove_shm) then
    echo "Removing shared memory"
    $gtm_tst/com/ipcrm -m $shmid
else
    echo "Keeping shared memory"
endif

# Set WBTEST_CRASH_SHUTDOWN_EXPECTED to avoid assert from wcs_flu(). This test does kill -9 followed by a MUPIP RUNDOWN. A kill -9
# could hit the running GT.M process while it is in the middle of executing wcs_wtstart. This could potentially leave some dirty
# buffers hanging in the shared memory. So, set the white box test case to avoid asserts in wcs_flu.c
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29

echo "Executing MUPIP RUNDOWN"
# Here -override flag can be randomized once GTM-7859 is fixed
$MUPIP rundown -override -file mumps.dat >& rundown.out

$gtm_tst/com/ipcs -s | $grep $USER >&! ipcs_s.out
$grep -w $semid ipcs_s.out
if (0 == $status) then
    echo "TEST-E-ERROR The access semaphore is not removed. MUPIP RUNDOWN did not remove $semid."
    exit -1
endif

$gtm_tst/com/ipcs -m | $grep $USER >&! ipcs_m.out
$grep -w $shmid ipcs_m.out
if (0 == $status) then
echo "TEST-E-ERROR The shared memory is not removed. MUPIP RUNDOWN did not remove $shmid."
    exit -1
endif

echo "TEST-I-PASS"

# $gtm_tst/com/dbcheck.csh doesn't make sense on a crashed database
