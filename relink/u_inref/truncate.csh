#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Embed source in the object files for easier estimation of the final size.
setenv gtmcompile "-embed_source"

# Keep things local to avoid affecting concurrent tests.
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_linktmpdir gtm_linktmpdir .

# Define reasonable limits for object file sizes.
setenv max_object_size		131072
setenv min_object_size		2048
setenv max_truncate_ratio	100
setenv min_truncate_ratio	50

# Verify that invoking truncated objects causes INVOBJFILE.
$gtm_dist/mumps -run truncate 20 invoke
@ invoke_failed = $status

# Verify that explicitly ZLINKing truncated objects causes INVOBJFILE.
$gtm_dist/mumps -run truncate 20 zlink
@ zlink_failed = $status

# Verify that implicitly ZLINKing truncated objects after ZRUPDATE causes INVOBJFILE.
$gtm_dist/mumps -run truncate 20 zrupdate
@ zrupdate_failed = $status

# If neither case failed, the test passed.
if ((! $invoke_failed) && (! $zlink_failed) && (! $zrupdate_failed)) then
	echo "TEST-I-PASS, Test succeeded."
endif
