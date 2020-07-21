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

echo "# In V6.3-008, GT.M now properly prints out the 64bit transaction number when"
echo "# issuing a continuity check failure. Previously only the lower 32bits would be printed."
echo "# This test uses MUPIP JOURNAL -RECOVER -FORWARD on 3 journal files to create the continuity check failure."
echo "setenv gtm_test_dbcreate_initial_tn 62" >>! settings.csh
setenv acc_meth BG
setenv gtm_test_mupip_set_version "disable"
unsetenv gtm_autorelink_keeprtn
$gtm_tst/com/dbcreate.csh mumps 1

$MUPIP set -journal=enable,on,nobefore -reg "*" >& journal.log
$GTM << EOF
for i=1:1:4 set ^x=i
EOF
ln -s mumps.mjl j1.mjl >& j1.log
cp mumps.mjl j2.mjl >& j2.log

echo "# Verifying that 16 hex digits are represented for the transaction number"
$MUPIP journal -recover -forward -nochecktn mumps.mjl,j2.mjl >& continuity.log
grep "continuity check failed:" continuity.log

$gtm_tst/com/dbcheck.csh
