#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test that MUPIP SET JOURNAL is able to switch older format journal files (without a FILEEXISTS error)"

set oldver = "V63014_R138" # We expect this build to exist in the system

source $gtm_tst/com/ydb_prior_ver_check.csh $oldver	# Get env vars unset/reset for "$oldver", in case needed

echo "# Switch to version $oldver (YottaDB r1.38)"
source $gtm_test/$tst_src/com/switch_gtm_version.csh $oldver $tst_image

echo "# Create journal file using YottaDB r1.38 (guaranteed to be an older format journal file)"
setenv gtm_test_jnl SETJNL	# We want dbcreate to create journal files
$gtm_tst/com/dbcreate.csh mumps

echo "# Verify mumps.mjl exists"
ls -1 mumps.mjl

echo "# Switch to current test version"
source $gtm_test/$tst_src/com/switch_gtm_version.csh $tst_ver $tst_image

echo "# Run [mupip set -journal] using current test version"
$MUPIP set $tst_jnl_str -reg "*"

echo "# Verify journal file switch happened and that there are 2 journal files mumps.mjl*"
ls -1 mumps.mjl*

$gtm_tst/com/dbcheck.csh
