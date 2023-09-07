#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# dbcreate.csh called by createdb_start_updates.csh.
echo "# Check for a normal backup now. It should succeed"
mkdir online4
$MUPIP backup -online "*" ./online4 >&! online4.out
$grep "%YDB-I-BACKUPSUCCESS" online4.out
if !($status) then
        echo "PASS! BACKUP successfull"
else
        echo "TEST-E-ERROR BACKUP failed"
endif
stopsubtest
$gtm_tst/com/dbcheck.csh

