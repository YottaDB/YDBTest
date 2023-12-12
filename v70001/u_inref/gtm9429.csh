#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
setenv ydb_msgprefix "GTM"	# So test runs correctly on GTM
#
echo '# GTM-9429 - Verify features such as $QLENGTH() and $QSUBSCRIPT() do tighter checking for canonic references'
echo
echo '# Release note:'
echo '#'
echo '# $QLENGTH() and $QSUBSCRIPT() report errors when a literal portion of the namevalue argument contains'
echo '# a leading decimal point (.) or minus-sign (-) not followed by one or more numeric digits, or text'
echo '# matching the appearance of a $[Z]CHAR() function. Previously these cases were not appropriately'
echo '# detected. (GTM-9429)'
echo
echo '# Drive gtm9429 to drive all the non-UTF8 cases (always done)'
$gtm_dist/mumps -run gtm9429 NonUTF8
if ($?gtm_chset) then
    if ("UTF-8" == "$gtm_chset") then
	echo
	echo '# Drive gtm9429 to drive all the UTF-8 cases'
	$gtm_dist/mumps -run gtm9429 UTF8
    endif
endif
