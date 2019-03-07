#!/usr/local/bin/tcsh -f
#################################################################
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
# This module is derived from FIS GT.M.
#################################################################
#
# GTM-7353 Database integrity errors in v51000/C9E12002698 test
#

###
# Consider an initial database state consisting of a global variable tree of depth 2.
#        ROOT
#         |
# |--------------------------------|
# INDEX1[rec1,rec2...]          INDEX2
#        |      |
#        DATA1  DATA2
#
# Process A does a TP update in block DATA1. This involves a search path (ROOT,INDEX1,DATA1) through rec1. These are the blocks
# that will be validated in tp_tend. Note that ROOT and INDEX are candidates for the indexmod optimization. The process calls
# tp_hist, sees no issues, and proceeds to tp_tend.
#
# Concurrently, process B does a set operation which requires a block split at the index level. As part of the update, rec1
# gets moved to a new block, INDEX3.
#        ROOT
#         |
# |--------------------------|-------------------------|
# INDEX3[rec1,...]          INDEX1[rec2,...]        INDEX2
#        |                          |
#        DATA1                      DATA2
#
# Process B then kills block DATA1, removing index record rec1. DATA1 is now marked free in its bitmap. This kill updates the
# killtn for the block-table entry corresponding to INDEX3. But note that neither the split-causing set nor the kill has updated
# the killtn for INDEX1.
#        ROOT
#         |
# |--------------------------|-------------------------|
# INDEX3          INDEX1[rec2,...]                  INDEX2
#                          |
#                          DATA2
#
# Process A then proceeds to validate INDEX1 and makes use of the indexmod optimization, since no M-kill or REORG operation has
# touched the block. In reality, an index record that was present in that block earlier in the transaction no longer exists.
# Process A then proceeds to update block DATA1 (even though it is now free) triggering the following assert in debug:
# %YDB-F-ASSERT, Assert failed in /usr/library/V55000/src/bml_status_check.c line 75
#		for expression ((gds_t_acquired == cs->mode) || (BLK_BUSY == bml_status))
###

$gtm_tst/com/dbcreate.csh mumps 1
# Start GT.M processes
$GTM << GTM_EOF
        do ^gtm7353
GTM_EOF
$gtm_tst/com/dbcheck.csh
