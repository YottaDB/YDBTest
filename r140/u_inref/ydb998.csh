#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
echo "# TSTART should not open the default global directory"
echo "# Test 1: set local variables in a transaction without a database does not error"
$GTM << GTM_EOF
tstart ()
set x=1
tcommit
GTM_EOF

echo "# Test 2: set extended reference global variables without a global directory does not error"
$gtm_tst/com/dbcreate.csh mumps
unsetenv gtmgbldir
$GTM << GTM_EOF
tstart ()
set ^|"mumps.gld"|x=1
tcommit
GTM_EOF
