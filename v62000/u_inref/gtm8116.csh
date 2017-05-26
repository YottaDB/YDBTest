#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test that $TEXT returns silently in case of error (no incorrect TPQUIT errors etc.)
# Trigger a TRIGINVCHSET error by loading a trigger with one $gtm_chset and switching to another $gtm_chset
# when doing $TEXT on that trigger. We expect to see no output because $TEXT should swallow any errors according
# to the M-standard. Previously we used to see a TPQUIT show up.

$gtm_tst/com/dbcreate.csh mumps

cat << CAT_EOF >&! simple.trg
+^A -commands=set -xecute="do ^nothing" -name=trigger
CAT_EOF
$MUPIP trigger -triggerfile=simple.trg -noprompt
$MUPIP trigger -select

# The below section needs to switch to UTF-8 mode when run in M mode.
# This cannot be done on platforms that do not support unicode
if ( "TRUE" == $gtm_test_unicode_support ) then
	# Switch chset
	set newchset = "UTF-8"	# The current chset would be M in 2 out of 3 cases
	if ($?gtm_chset) then
		if ("UTF-8" == $gtm_chset) then
			set newchset = "M"
		endif
	endif
	$switch_chset $newchset >&! switch_chset.out

	$gtm_exe/mumps -run test1^gtm8116
	$gtm_exe/mumps -run test2^gtm8116
	$gtm_exe/mumps -run test3^gtm8116
endif

$gtm_tst/com/dbcheck.csh
