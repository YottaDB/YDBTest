#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-8083 TXTSRCMAT error inside trigger code + TP restarts does not cause SIG-11 anymore
#

$gtm_tst/com/dbcreate.csh mumps
$gtm_exe/mumps -run gtm8083

# HPUX Itanium occasionally gives the following errors in some .mje* files.
#	1) YDB-E-FILENOTFND
#	2) SYSTEM-E-ENO13
#	3) YDB-E-ZLINKFILE
# It is not clear how those errors are possible but we filter those out so we still test no SIG-11s happen.
source $gtm_tst/com/set_gtm_machtype.csh
if ("hp-ux_ia64" == $os_machtype) then
	foreach file (*.mje*)
		set newfile=${file:r}_${file:e}.filtered
		mv $file $newfile
		$grep -vE "YDB-E-FILENOTFND|SYSTEM-E-ENO13|YDB-E-ZLINKFILE" $newfile > $file
	end
endif

$gtm_tst/com/dbcheck.csh
