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

set logfile = $1
#YDB-E-MUNOACTION is printed whenever rollback/recovery exits abruptly. Filter that out (since it is a secondary message)
$grep -E ".-[EFW]-" $logfile  | $grep -vE "FORCEDHALT|MUNOACTION|MUKILLIP" > /dev/null
if (! $status) then
	echo "TEST-E-MUPIP ERROR, there was an error in $logfile, cannot continue with the test"
	$grep -E ".-[EFW]-" $logfile  | $grep -vE "FORCEDHALT|MUNOACTION|MUKILLIP"
	exit 4
endif
