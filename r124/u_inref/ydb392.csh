#!/usr/local/bin/tcsh -f
#################################################################
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
#
echo "------------------------------------------------------------------------------------------------------"
echo "# Test that ydb_linktmpdir/gtm_linktmpdir env var default to ydb_tmp/gtm_tmp before defaulting to /tmp"
echo "------------------------------------------------------------------------------------------------------"


echo "# Create test output directories to be set as env vars"
mkdir case2-dir
mkdir case3a-dir
mkdir case3b-dir

echo ""
echo "# Test Case 1: Test that when neither ydb_linktmpdir/gtm_linktmpdir or ydb_tmp/gtm_tmp are set, the path for Relinkctl is /tmp"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_linktmpdir gtm_linktmpdir
source $gtm_tst/com/unset_ydb_env_var.csh ydb_tmp gtm_tmp

echo ""
echo "# Relinkctl should be set to the path of /tmp"
$ydb_dist/mumps -direct > case1.txt << EOF
	set \$zroutines=".*"
	zshow "a"
EOF

$grep "filename" case1.txt

echo ""
echo "------------------------------------------------------------------------------------------------------"
echo "# Test Case 2: Test that when ydb_linktmpdir/gtm_linktmpdir is unset and ydb_tmp/gtm_tmp is set, the path for Relinkctl is the same as ydb_tmp/gtm_tmp"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_linktmpdir gtm_linktmpdir
source $gtm_tst/com/unset_ydb_env_var.csh ydb_tmp gtm_tmp

echo ""
echo "# Randomly set either ydb_tmp or gtm_tmp to case2-dir"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tmp gtm_tmp case2-dir

echo ""
echo "# Relinkctl should be set to the path of case2-dir"
$ydb_dist/mumps -direct > case2.txt << EOF
	set \$zroutines=".*"
	zshow "a"
EOF

$grep "filename" case2.txt

echo ""
echo "------------------------------------------------------------------------------------------------------"
echo "# Test Case 3: Test that when ydb_linktmpdir/gtm_linktmpdir and ydb_tmp/gtm_tmp are set, the path for Relinkctl is the same as ydb_linktmpdir/gtm_linktmpdir"

echo ""
echo "# Randomly set either ydb_linktmpdir or gtm_linktmpdir to case3a-dir"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_linktmpdir gtm_linktmpdir case3a-dir
echo "# Randomly set either ydb_tmp or gtm_tmp to case3b-dir"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tmp gtm_tmp case3b-dir

echo ""
echo "# Relinkctl should be set to the path of case3a-dir"
$ydb_dist/mumps -direct > case3.txt << EOF
	set \$zroutines=".*"
	zshow "a"
EOF

$grep "filename" case3.txt
