#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
################################################################################################################
# Since the test framework cannot write files to the $ydb_dist script, this function creates a pseudo $ydb_dist
# directory under the caller specified directory ($1) that contains all relevent files
################################################################################################################

mkdir $1
cp -r $ydb_dist/* $1/ >>& $1/not_copied.txt
setenv ydb_dist $1
