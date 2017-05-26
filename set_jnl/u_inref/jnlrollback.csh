#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
if ($?test_debug != 0) then
	$gtm_tst/com/backup_dbjnl.csh save "*.dat *.mjl*" cp nozip
endif
#
set resno = $1
if (resno == "") resno = 1
ls -lart *.* >>& list.out
echo '$gtm_tst/com/mupip_rollback.csh -resync='$resno' -lost=lost.glo *' >>& list.out
echo '$gtm_tst/com/mupip_rollback.csh -resync='$resno' -lost=lost.glo *'
$gtm_tst/com/mupip_rollback.csh -resync=$resno -lost=lost.glo "*"
if ($status) then
	echo "rollback command failed"
	exit 1
endif
