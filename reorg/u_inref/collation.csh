#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
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

setenv test_reorg "NON_REORG"
source $gtm_tst/com/polish_collate.csh
$gtm_tst/com/dbcreate.csh "mumps" 1 125 500 -c=1
$GTM << \aaa
d ^colfill("set",15)
h
\aaa
$MUPIP reorg -fill_factor=50
$MUPIP reorg -fill_factor=100
$GTM << \aaa
d ^colfill("ver",15)
zwr ^A
zwr ^B
h
\aaa
$gtm_tst/com/dbcheck.csh
