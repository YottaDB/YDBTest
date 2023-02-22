#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
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
# Verify that shared collation library is protected against buffer overflow.
$switch_chset M >&! switch_chset.log
# Note this is a special collation routine that goes beyond what the typical reverse
# collation routine does. First and foremost, it contains an error handler to trap an
# expected buffer overflow error that this test creates.
source $gtm_tst/com/cre_coll_sl.csh $tst/inref/col_gtm7740.c 1

# Create the DB with key-size 1019 and default collation 1.
$gtm_tst/com/dbcreate.csh mumps 1 1019 . 4096 . . . . 1
$gtm_exe/mumps -run gtm7740
$gtm_tst/com/dbcheck.csh
