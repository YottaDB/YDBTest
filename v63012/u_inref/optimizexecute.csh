#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# While merging V6.3-012, we had an issue where xecutes"
echo "# were not being optimized due to an issue with the dqnoop"
echo "# macro. See https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1132#note_896487238"
echo "# for more information. This test verifies that the machine"
echo "# listing for an xecute statement is optimized."

cat >> optimizexecute.m << xx
 xecute "for i=1"
xx

$ydb_dist/yottadb -machine -lis=optimizexecute.lis optimizexecute.m
grep -E ";OC_|PUSHL" optimizexecute.lis
