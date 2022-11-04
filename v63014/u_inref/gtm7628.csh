#!/usr/local/bin/tcsh
#################################################################
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

if (! $?test_replic) then
	echo '### Test requires being invoked with -replic'
	exit 1
endif
echo
echo '# gtm7628 - verify we can start up source and receiver servers with a 64GB jnlpool/recvpool respectively.'

setenv tst_buffsize `$gtm_dist/mumps -run ^%XCMD "write 2**36"`  # 64Gib
echo
echo '# Run dbcreate.csh'       # Should configure and start up replication
$gtm_tst/com/dbcreate.csh mumps 1
echo
echo '# Do some minor updates to the database to force a minor modicum of work'
$gtm_dist/mumps -run initDB^gtm7628
echo
echo '# Discover and print size of journal pool attached'
$gtm_dist/mumps -run printJPSize^gtm7628
$gtm_dist/mupip replic -source -jnlpool -show |& grep "CTL Journal Pool Size"
$gtm_dist/mupip replic -source -jnlpool -show >& mupipreplicshow.txt
echo
echo '# Discover and print size of receive pool attached'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_dist/mumps -run printRPSize^gtm7628"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_dist/mupip replic -source -jnlpool -show |& grep 'CTL Journal Pool Size'"
echo
echo "# Run dbcheck.csh -extract to ensure db extract on primary matches secondary"
$gtm_tst/com/dbcheck.csh -extract
