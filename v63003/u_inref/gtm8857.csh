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
#
# Running pattern code with pattern that exceeds the max length
# Specific pattern was produced by running several tests with random
# strings, this was the only one that was able to reproduce the error
# we were looking for
#
$ydb_dist/mumps -run gtm8857
