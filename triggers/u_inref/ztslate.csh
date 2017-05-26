#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# inspectISV generates annoying compile errors
$gtm_exe/mumps $gtm_tst/$tst/inref/inspectISV.m >&! inspectISV.outx
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run ztslate
$gtm_exe/mumps -run assert^ztslate
$gtm_tst/com/dbcheck.csh -extract
