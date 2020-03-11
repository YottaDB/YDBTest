#!/usr/local/bin/tcsh -f
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

# Disable ydb_dbglvl (randomly set by test framework) as that can cause test to unnecessarily take lots of time
source $gtm_tst/com/unset_ydb_env_var.csh ydb_dbglvl gtmdbglvl

echo "# Test that no SYSTEM-E-UNKNOWN/SIG-11 occurs when invoked M function is one million M lines apart"
echo ""
echo "  -> Generate M program (funcgen.m) with M function invocation one million M lines apart"
$ydb_dist/yottadb -run ydb547 > funcgen.m
echo "  -> Run generated M program : [yottadb -run funcgen.m]"
$ydb_dist/yottadb -run funcgen

