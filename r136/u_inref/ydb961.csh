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

echo '# Test $ZTIMEOUT reset does not cause ASAN heap-use-after-free error'
echo '# This test used to fail with the above error if YottaDB was built with ASAN and did not have the YDB#961 code fixes'

echo '# To ensure this test does its job with ASAN, ensure we use the system malloc/free and not the yottadb malloc/free'
source $gtm_tst/com/set_gtmdbglvl_to_use_system_malloc_free.csh

$ydb_dist/yottadb -run ydb961

