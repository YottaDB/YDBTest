#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo ENTERING ONLINE2
#
#
# Disable ENOSPC faking to prevent spurious "Not enough updates per second during backup" failures. This can occur
# if a session randomly enables Anticipatory Freeze regression testing (see "Random option - 24" in do_random_settings.csh).
# In that case, a fake ENOSPC can freeze the instance for several seconds and cause the rate check in online2.m to fail if that
# freeze happens while the test is measuring the update rate of MUPIP BACKUP. (YDBTest#987)
unsetenv gtm_test_fake_enospc
setenv gtmgbldir online2.gld
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh online2 1 125 700 1536 9000 256
else
	$gtm_tst/com/dbcreate.csh online2 1 125 700 1536 100 256
endif
$GTM << \onlinetest
d main^online2
h
\onlinetest
$gtm_tst/com/dbcheck.csh
#
#
echo LEAVING ONLINE2
