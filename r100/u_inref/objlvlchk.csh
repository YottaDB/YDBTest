#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test YDB object versioning. Each object file has a version associated with it (see sr_port/objlabel.h).
# Test should verify:
#   1. An object created by GT.M (both old and new) is recognized by YDB and ALWAYS recompiled even
#      if the source has not changed.
#   2. An object created by YDB and the source is changed, YDB recompiles the routine.
#   3. [** Future expansion once a version of YDB is available with an incremented object version **] An
#      object created by a previous version of YDB is recompiled appropriately with the new YDB version.
#
set prior_ver = `$gtm_tst/com/random_ver.csh -lt V70000 >& rand_ver.txt; cat rand_ver.txt`
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
source $gtm_tst/com/switch_gtm_version.csh $prior_ver pro
#echo "Selected GT.M version [$prior_ver] to do initial compile"
#
# Now that a random GT.M version is ready to go, just compile an M routine from this test after saving original.
#
$gtm_exe/mumps $gtm_tst/$tst/inref/zlen2arg.m
cp -p zlen2arg.o zlen2arg.o.priorver
#
# Now switch back to our test version and recompile. Verify object file changed
#
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$gtm_exe/mumps -run %XCMD 'zlink "zlen2arg"' # zlink won't recompile if it likes the existing object label
diff -q zlen2arg.o.priorver zlen2arg.o >& diff-output.txt
set diffstat = $status
if (0 == $diffstat) then
    echo "FAIL - YDB did not recompile a file built by GT.M"
else
    echo "PASS"
endif
rm -f zlen2arg.o*
exit $diffstat
