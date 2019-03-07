#!/usr/local/bin/tcsh
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
# D9D12-002402 TID in the journal extract seems to be from innermost TSTART not outermost
#
$gtm_tst/com/dbcreate.csh mumps
$MUPIP set $tst_jnl_str -region "*" >&! mupip_set_jnl.out
$grep "YDB-I-JNLSTATE" mupip_set_jnl.out
$GTM <<GTM_EOF
	do ^d002402
GTM_EOF
$MUPIP journal -extract -noverify -forward -fences=none mumps.mjl
echo "------------------------------------"
echo "List of tids in journal extract file"
echo "------------------------------------"
$tst_awk -f $gtm_tst/$tst/inref/D9D12002402.awk mumps.mjf
$gtm_tst/com/dbcheck.csh
