#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# If forward rollback was not randomly chosen by the test framework, then skip it.
if (0 == $gtm_test_forward_rollback) then
	exit 0
endif

set bakdir = `$gtm_tst/com/get_repl_inst_name.csh`
if ("$bakdir" == "") then
	echo "TEST-E-REPLINSTNAME : could not get replication instance name, which is used as backup directory name"
	exit 1
endif

if (-e dir_$bakdir) then
	# Backup directory already exists. Test has already invoked backup_for_mupip_rollback.csh. Return right away.
	exit 0
endif

mkdir dir_${bakdir}

# Backup all regions
# Use -nonewjnlfiles because we later want forward rollback and backward rollback (invoked as part of mupip_rollback.csh
# by the caller test script) to see the same set of journal files.
$MUPIP backup -dbg -nonewjnlfiles -online "*" dir_$bakdir >& ${bakdir}_backup.out
@ exit_status = $status
exit $exit_status
