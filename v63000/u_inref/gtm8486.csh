#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
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

# We do not want autorelink-enabled directories that have been randomly assigned by the test system because we are explicitly
# testing the autorelink functionality, as opposed to the rest of the test system which may be testing it implicitly.
source $gtm_tst/com/gtm_test_disable_autorelink.csh
set save_gtmroutines = "$gtmroutines"

# Create routine and object directories
mkdir obj rtn
cp $gtm_tst/$tst/inref/gtm8486.m rtn/

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_link gtm_link RECURSIVE
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_routines gtmroutines "obj*(rtn) $gtm_dist"

$gtm_dist/mumps -run gtm8486

