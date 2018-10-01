#################################################################
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
echo "# Test that Source Server shutdown command says it did not delete jnlpool ipcs even if the instance is frozen"
echo ""

echo "# Create database file. Source server is now running in the background."
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo "# Randomly decide to start a background mumps process that attaches to the journal pool"
$ydb_dist/mumps -run start^ydb364

echo "# Freeze the instance"
$MUPIP replic -source -freeze=on -comment="ydb364"

echo '# Shut down the source server. Verify that "Not deleting jnlpool ipcs." message shows up'
$MUPIP replic -source -shutdown -timeout=0

echo "# Unfreeze the instance. Note that this needs to be done before restarting the source server as the latter can hang otherwise."
$MUPIP replic -source -freeze=off

echo "# Restart the source server"
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
$gtm_tst/com/SRC.csh "." $portno "" >>&! START_2.out

echo "# Stop backgrounded mumps process if it was randomly started before"
$ydb_dist/mumps -run stop^ydb364

echo "# Do dbcheck.csh"
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
