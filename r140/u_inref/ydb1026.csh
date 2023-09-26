#!/usr/local/bin/tcsh -f
#################################################################
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

echo "# Test that ZWRITE to file output device with STREAM + NOWRAP does not split/break lines"
echo "# This is an automated test of https://gitlab.com/YottaDB/DB/YDB/-/issues/1026#note_1560258223"

$ydb_dist/yottadb -run ydb1026

