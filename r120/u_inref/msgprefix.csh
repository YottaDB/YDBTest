#!/usr/local/bin/tcsh -f
#################################################################
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
#
$echoline
echo "# Test of <ydb_msgprefix> environment variable"
$echoline
#
echo ""
echo "# Test that ydb_msgprefix undefined defaults to YDB"
unsetenv ydb_msgprefix
$gtm_exe/mumps -run %XCMD 'zmessage 150372371'

echo ""
echo "# Test ydb_msgprefix set to strings of length 0, 3, 31, 32. For 32, the value is ignored. For < 32, it is honored."
foreach value ("" "abc" "ABCDEFGHIJKLMNOPWRSTUVWXYZ12345" "ABCDEFGHIJKLMNOPWRSTUVWXYZ123456")
	echo "#   env ydb_msgprefix=$value"
	setenv ydb_msgprefix $value
	$gtm_exe/mumps -run %XCMD 'zmessage 150372371'
end

echo ""
echo "# Test that ydb_msgprefix set to some value (###) does not affect error messages in .msg files other than merrors.msg."
setenv ydb_msgprefix "###"
echo "#   Test Error codes in cmerrors.msg : INVPROT and CMSYSSRV"
$gtm_exe/mumps -run %XCMD 'zmessage 150568970'
$gtm_exe/mumps -run %XCMD 'zmessage 150569010'
echo "#   Test Error codes in cmierrors.msg : DCNINPROG and REASON_CONFIRM"
$gtm_exe/mumps -run %XCMD 'zmessage 150634508'
$gtm_exe/mumps -run %XCMD 'zmessage 150634698'
echo "#   Test Error codes in gdeerrors.msg : INPINTEG and NOPERCENTY"
$gtm_exe/mumps -run %XCMD 'zmessage 150503508'
$gtm_exe/mumps -run %XCMD 'zmessage 150504114'
echo "#   Test Error codes in merrors.msg : BREAKZST and STPCRIT"
$gtm_exe/mumps -run %XCMD 'zmessage 150372371'
$gtm_exe/mumps -run %XCMD 'zmessage 150384274'
echo "#   Test Error codes in ydberrors.msg : QUERY2 and MIXIMAGE"
$gtm_exe/mumps -run %XCMD 'zmessage 151027722'
$gtm_exe/mumps -run %XCMD 'zmessage 151027730'

