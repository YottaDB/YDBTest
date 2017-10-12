#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
set log=crea_$$_`date +%H_%M_%S`.log
echo DBCREATE >>& $log
\rm -f mumps.gld	# make sure we don't have a left over global directory
$gtm_tst/com/dbcreate.csh mumps $1 >>& $log
echo MUPIP SET -JOURNAL >>& $log
$MUPIP set -journal=enable,on,before -reg "*" >>& $log
echo DATABASE FILES >>& $log
$gtm_tst/com/lsminusl.csh *.dat *.mjl |& $tst_awk '{print($1,$NF);}' | tee -a $log
# dbcheck.csh is called by callers of this script.
