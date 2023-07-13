#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
#
echo '# Test the -IMAGE option of the (debug-only) DSE BLOCK command. This option allows one to format'
echo '# and print, as if it were a current database block, an encoded PBLK from the journal file.'

setenv gtm_test_jnl "SETJNL"	   	   	    # Enable journaling
source $gtm_tst/com/gtm_test_setbeforeimage.csh	    # Test needs before image journaling
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo 'DB create failed - output below - test terminated'
	cat dbcreate_log.txt
	exit 1
endif
echo
echo '# Update a node twice in succession'
$gtm_dist/mumps -run %XCMD 'set ^x=1'
$gtm_dist/mumps -run %XCMD 'set ^x=2'
echo
echo '# Extract the journal information for block 3 using MUPIP JOURNAL -EXTRACT -DETAIL -BLOCK'
$gtm_dist/mupip journal -extract -noverify -detail -forward -fences=none -block=3 mumps.mjl
echo
echo '# Extract PBLK we want to print from the journal file to file x.bin'
unset backslash_quote   # needed in tcsh before next line (not needed with bash)
$grep PBLK mumps.mjf | $tail -1 | sed 's/[^$]*\$/$/' | $gtm_dist/mumps -run %XCMD 'use $p:chset="M" read x write $zwrite(x,1)' > x.bin
echo
echo '# Display the extracted block using DSE DUMP -BL=3 -IMAGE=x.bin'
$gtm_dist/dse dump -bl=3 -image=x.bin
echo
echo '# Verify database'
$gtm_tst/com/dbcheck.csh
