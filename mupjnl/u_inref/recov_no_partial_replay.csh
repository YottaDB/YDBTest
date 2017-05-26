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
# Test To do: 17
# ----------------------
# AREG    BREG    CREG
# ----------------------
# T1       T1
# 	   T2      T2
# T3       T3
# ----------------------
# Ensure recovery never plays half of a TP transaction into the db and the remaining half into
# a losttn file
# If recovery is done by specifying only a.mjl and b.mjl, T2 is considered broken.
# Since T3 happened after T2 in BREG, T3 but otherwise is a complete transaction, it is considered as a lost transaction.
# Earlier recovery algorithm processed one region at a time so it did not recognize this broken transaction while processing AREG and therefore played T1 and T3.
# While playing BREG, it played forward T1 and moved T2 into the broken transaction file and T3 into the lost transaction file.
# The final state of the database is that T1 is completely applied and T3 is partially applied (only in AREG) and the remaining part lies in the lost transaction file.
# With the new algorithm the complete transaction T3 should go into lost transaction files and should not be played partially.
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 4
$gtm_tst/com/jnl_on.csh
echo "Do tp updates now"
echo `date +'%d-%b-%Y %H:%M:%S'` > time1.txt
$GTM << GTMEND
do init^tpmultireg
do ^tpmultireg
GTMEND
$gtm_tst/com/backup_dbjnl.csh bak "*.dat *mjl *.gld" cp nozip
set time1=`cat time1.txt`
# Do backward recovery without specifying c.mjl
$MUPIP journal -recover -back -since=\"$time1\" a.mjl,b.mjl -lost=x.lost
$MUPIP extract extract.glo
cat extract.glo
echo "Lost transaction file"
$gtm_tst/$tst/u_inref/extr_req_info.csh "x.lost" | sort
echo "Broken transaction file"
$gtm_tst/$tst/u_inref/extr_req_info.csh "b.broken"
$gtm_tst/com/dbcheck.csh
