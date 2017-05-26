#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# transbig1:  test that in tp update, the threshold of read-set and write-set for number global buffers is not crossed

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"
alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

setenv gtm_poollimit 0 # This test needs to use the maximum available buffers, for it checks the limit on block read/writes
BEGIN "Create a database with maximum block size(1008) and fill it with 64K+1 blocks of data"
setenv gtmgbldir mumps.gld
setenv test_specific_gde $gtm_tst/$tst/u_inref/recsize.gde
$gtm_tst/com/dbcreate.csh mumps 1

$gtm_exe/mumps -run %XCMD 'for i=1:1:((64*1024)+1) set ^x(i)=$j(i,990)'
END

BEGIN "Test the read-set limit of 64K blocks, for number of global buffers in one transaction, is not violated"
$gtm_exe/mumps -run dbread^transtoobig
END

BEGIN "Test the write-set limit of half of the number of blocks, for number of global buffers in one transaction, is not violated"
$gtm_exe/mumps -run dbwrite1^transtoobig
END
$gtm_tst/com/dbcheck.csh
