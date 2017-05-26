#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# A test for a condition in cli_gettoken() that was writing to freed memory.  When gtmdbglvl is set to 0x1F0 an assert is
# thrown in gtm_malloc_src.h when it checks freed memory.  The error case is caused by reading in a line longer that the
# default allocated size which causes the old struct to be freed and a new, larger one allocated.  Note: the content of the
# line doesn't matter, it just needs to be long.  So we expect the following commands to have errors when they run.

#Verify malloced memory use
setenv gtmdbglvl 0x1F0

$gtm_tst/com/dbcreate.csh mumps

$echoline
####################################################
echo "1. Long DSE command"
$DSE << DSE_EOF
add -bl=3 -key="^aglobal(""xyz"")" -data="abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789"
DSE_EOF
echo
####################################################
$echoline
echo "2. Long LKE command"
$LKE << LKE_EOF
clear -nointeractive -reg=BNONEXISTENTREGIONTHISTIMEAVERYVERYLONGREGION6789012345678901234567890
LKE_EOF
echo
####################################################
$echoline
echo "3. Long MUPIP command"
# Need to create a journal file - no journaling is done in the test
$MUPIP set $tst_jnl_str -reg "*" >&! jnl.out
$MUPIP << MUPIP_EOF
journal -show=ACTIVE_PROCESSES,BROKEN_TRANSACTIONS,HEADER,PROCESSES,STATISTICS -FORWARD -BEFORE=\"0 00:00:00\" mumps.mjl
MUPIP_EOF
echo
####################################################
$echoline
$gtm_tst/com/dbcheck.csh
