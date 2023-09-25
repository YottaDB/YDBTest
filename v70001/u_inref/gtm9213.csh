#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo
echo '# GTM9213 - Release note:'
echo '#'
echo '# GT.M accepts SET $SYSTEM=expr, where expr appends to the initial value up to the length'
echo '# permitted for an initial value; an empty string removes any current added value. Initial'
echo '# values are determined by the $gtm_sysid environment variable always preceded by "47,".'
echo '# Previously, an attempt to SET $SYSTEM produced an SVNOSET error. (GTM-9213)'
unsetenv gtm_sysid     # Remove any outside interference - use default value
unsetenv ydb_sysid
echo
echo '# Drive ^gtm9213'
$gtm_dist/mumps -run gtm9213
