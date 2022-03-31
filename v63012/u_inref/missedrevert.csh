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

echo "# This tests for SIG-11s caused by missed REVERTs in m_for.c."
echo "# While merging V6.3-012, we had an issue due to a missed REVERT"
echo "# in sr_port/m_for.c. This test checks that a FOR works correctly"
echo "# and does not crash with a SIG-11. See"
echo "# https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1132#note_896366838"
echo "# for more information."

cat >> missedrevert.m << xx
 xecute "for i=1"
 for a=1:1:2 kill a
xx

$ydb_dist/yottadb -run missedrevert
