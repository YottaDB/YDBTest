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
# Test To do: 20
# Test that broken transactions which are ordered based on a missing region's records get placed in an arbitrary order in the brokentn file.

# ----------------
# R1    R2    R3
# ----------------
#       T1    T1
# T2          T2
# ----------------
# In this case, T1 happened BEFORE T2. But if R1,R2 mjl files are the only ones specified,
# recovery has no way of determining which happened before since the order is determined
# in R3 (missing region). So it will place either T1 or T2 first in the brokentn file.
# Either of them is correct.
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 4
$gtm_tst/com/jnl_on.csh
echo "Starting updates"
echo `date +'%d-%b-%Y %H:%M:%S'` > time1.txt
$GTM << GTMEND
do init^tpmultireg
do brkntransordr^tpmultireg
GTMEND
$gtm_tst/com/backup_dbjnl.csh bak "*.dat *.mjl*" cp nozip
set time1=`cat time1.txt`
# Do backward recovery without specifying c.mjl
$MUPIP journal -recover -back -broken=a.broken -lost=a.lost -since=\"$time1\" a.mjl,b.mjl
echo "DB Extract"
$MUPIP extract extract.glo
cat extract.glo
echo "Check a(2) and b(1) are there in the broken file"
$gtm_tst/$tst/u_inref/extr_req_info.csh "a.broken" >> broken_file.log
$grep "\^b(1)" broken_file.log
$grep "\^a(2)" broken_file.log
$gtm_tst/com/dbcheck.csh
