#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1321] ZCOMPILE and ZLINK with a qualifier repeated without a value do not corrupt the heap    #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# A qualifier repeated without a value left a pointer to freed memory, which the next command freed'
echo '# again.'
echo '#'
echo '# Each stage runs its lines in direct mode in a new process, and checks its output for the lines'
echo '# named, and for no fatal error.'
echo
set dm = "$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1321dm"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : ZLINK and ZCOMPILE with a qualifier that is repeated without a value'
echo '#   expect only the errors for the invalid qualifier value and the missing files, then $VIEW("REGION")'
echo '#   to work'
echo '#   previously the second free of the same memory made a Release build get a SIG-11, and a Debug build'
echo '#   fail an assert in gtm_malloc_src.h, at the second ZLINK or a later command'
$dm zcrepeat FILENOTFND NOTMNAME ZLINKFILE ZLNOOBJECT
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
