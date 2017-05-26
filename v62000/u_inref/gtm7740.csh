#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Verify that shared collation library is protected against buffer overflow.
$switch_chset M >&! switch_chset.log
$gtm_tst/$tst/u_inref/cre_coll_sl.csh reverse 1
setenv gtm_collate_1  `pwd`"/lib_reverse${gt_ld_shl_suffix}"
#create the DB with key-size 1019 and default collation 1.
$gtm_tst/com/dbcreate.csh mumps 1 1019 . 4096 . . . . 1
$gtm_exe/mumps -run gtm7740
$gtm_tst/com/dbcheck.csh
