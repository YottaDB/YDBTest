#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2021-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo "# Tests that R/O databases are rundown correctly. Prior to V63009, the semaphore was not properly run down"
echo "# (see GTM-8921 added via YDBTest#336 for more information)"
echo "#"
echo "# Creating MM database"
setenv gtm_test_db_format "NO_CHANGE"	# do not switch db format as that will cause incompatibilities with MM
       			  		# which this test sets the access method to in the early stages.
# This test requires MM so force MM and therefore disable encryption & nobefore as they are incompatible with MM
setenv acc_meth MM
setenv test_encryption NON_ENCRYPT
source $gtm_tst/com/mm_nobefore.csh     # Force NOBEFORE image journaling with MMsetenv acc_meth MM
#
$gtm_tst/com/dbcreate.csh mumps
echo "# Set database to read/only (turning off stats as can't share stats with read/only else get READONLYNOSTATS error)"
$MUPIP set -nostats -read_only -file mumps.dat
echo "# Briefly open database for a moment with DSE to see if it leaves any IPCs laying around"
$DSE d -f >& dse_header_output.txt
echo "# See if any IPCs were left over - If any IPCs show up here, the test fails as there should be none"
# Use ftok to get the id of the semaphore that may have been left around
set leftoveripcid = `$MUPIP ftok mumps.dat |& grep "mumps.dat" | awk '{print substr($10, 2, 10);}'`
# See if an IPC for our database was left over
$gtm_tst/com/ipcs -s >& ipcs_sem.txt
set output = `$tst_awk '$3 == "'$leftoveripcid'" {print $0};' ipcs_sem.txt`
if ("" == "$output") then
    echo "Test PASSED"
else
    echo "Test FAILED - read-only database not correctly rundown"
endif
echo "# Rundown the file to clean any leftover IPCs. Note the only reliable way to get rid of this IPC on prior"
echo "# versions (V63008 or prior based versions) that create it is to undo the read-only specification and only"
echo "# THEN run it down."
$MUPIP set -noread_only -file mumps.dat
$MUPIP rundown -reg DEFAULT
echo "# Integ check"
$gtm_tst/com/dbcheck.csh
