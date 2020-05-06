#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This file is invoked by ydb520.csh to source ydb_env_set and
# run the third part of the test which verifies that $ztrap is
# set correctly when the stack frame pointer does not overlap
# with the mval that $ztrap is to be set to.
# We need to save $gtmroutines and use it instead of the value
# that ydb_env_set will set it to. Otherwise, YottaDB won't be
# able to find ydb520C.
export routines=$gtmroutines
. $ydb_dist/ydb_env_set
export ydb_routines=$routines
export gtmroutines=$routines
$ydb_dist/yottadb -run ydb520C
