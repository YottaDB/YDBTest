#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test To do: 18
# Test that broken transactions are resolved in correct order
# R1, R2 and R3 represents regions while T1 and T2 represent multi-region transactions in time order
# ----------------
# R1    R2    R3
# ----------------
#       T1    T1
# T2    T2    T2
# -----------------
# If recovery is done with only R1,R2 mjl files specified, both T1 and T2 are considered broken
# T2 happened AFTER T1 so should be placed in broken transaction file AFTER T1
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 4
$gtm_tst/com/jnl_on.csh
echo "Do multi-region updates"
echo `date +'%d-%b-%Y %H:%M:%S'` > time1.txt
$GTM << GTMEND
do init^tpmultireg
do inorder^tpmultireg
GTMEND
$gtm_tst/com/backup_dbjnl.csh bak "*.dat *mjl *.gld" cp nozip
set time1=`cat time1.txt`
# Do backward recovery without specifying c.mjl
$MUPIP journal -recover -back -since=\"$time1\" -lost=b.lost -broken=b.broken a.mjl,b.mjl
echo "DB Extract"
$MUPIP extract extract.glo
cat extract.glo
$gtm_tst/$tst/u_inref/extr_req_info.csh "b.broken"
$gtm_tst/com/dbcheck.csh

