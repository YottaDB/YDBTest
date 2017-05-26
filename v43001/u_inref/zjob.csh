#! /usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
source $gtm_tst/com/dbcreate.csh mumps 1
$GTM << EOF
w "d ^zjobdrv(5)",! d ^zjobdrv(5)
w "zjobi^zjobdrv",! d zjobi^zjobdrv
w \$zj,!
for j=1:1 quit:\$\$^isprcalv(^goodjob)=0  hang 0.1 ; wait till child process spawned off in zjobi^zjobdrv really dies
h
EOF
$gtm_tst/com/dbcheck.csh -extract
