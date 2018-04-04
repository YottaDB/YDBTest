#!/usr/local/bin/tcsh
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
# D9902-001105 Close the disabling Control-C hole on Unix
#

set expectpath = `which expect`
if ("$expectpath" != "") then
	setenv TERM xterm
	expect -f $gtm_tst/$tst/u_inref/ctrlc.exp $gtm_dist >&! ctrlc.out
endif

set numfound = `$grep -c YDB-I-CTRLC ctrlc.out`
# Should only see YDB-I-CTRLC once (when gtm_nocenable is not set)
if (1 == $numfound) then
	set ctrlclinenum = `$grep -n YDB-I-CTRLC ctrlc.out| cut -d: -f1`
	set nocenablelinenum = `$grep -n "unsetenv gtm_nocenable" ctrlc.out| cut -d: -f1`
#	Should see YDB-I-CTRLC after gtm_nocenable is unset
	if (`expr "$ctrlclinenum" \> "$nocenablelinenum"`) then
		echo "PASS"
		exit
	endif
endif
# Otherwise the test failed
echo "FAIL"
