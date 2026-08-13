#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Holds the database open for $1 seconds and returns at once. A separate script so that the calling
# subtest never backgrounds anything itself : tcsh prints "[1] <pid>" when it does, and a pid in the
# output would differ on every run and could not be compared against a reference file. Redirect this
# script's own output and that notice goes with it.

$ydb_dist/mumps -run %XCMD "set ^hold=1 hang $1" &
