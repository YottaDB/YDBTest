#################################################################
#								#
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Do not use V6 DB mode as encryption fails when enabled by older V6 releases. See
# https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1682#note_1521848301 for more information.
setenv gtm_test_use_V6_DBs 0
#
echo "# Test that CRYPTINIT error while opening an encrypted database does not leave ipcs (ftok semaphore)"

# Turn on Encryption
setenv test_encryption ENCRYPT
source $gtm_tst/com/set_encrypt_env.csh $tst_general_dir $gtm_dist $tst_src >>! $tst_general_dir/set_encrypt_env.log
setenv acc_meth BG		# MM and encryption is not supported

echo "# Create encrypted database"
$gtm_tst/com/dbcreate.csh mumps

echo "# Unset gtm_passwd env var and do a database reference. Expect CRYPTINIT error below"
set save_passwd = $gtm_passwd
unsetenv gtm_passwd
$ydb_dist/yottadb -run %XCMD 'set x=^x'

echo "# Verify ftok semaphore is not left around."
echo "# If it was, test framework would catch it and we would see a CHECK-W-SEM message below."

