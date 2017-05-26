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
# incrollback:  test that if transaction is too big, incremental rollback makes enough room for future global references

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"
alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

setenv gtm_poollimit 0 # This test needs to use the maximum available buffers, for it checks the limit on block read/writes
BEGIN "Create the database with maximum block size(1008)"
setenv gtmgbldir mumps.gld
setenv test_specific_gde $gtm_tst/$tst/u_inref/recsize.gde
$gtm_tst/com/dbcreate.csh mumps 1
END

#64K is the read-set limit for number of blocks to be read in single transaction. Hence we are making > 64K updates on database.
$GTM <<EOF
	for i=1:1:((64*1024)+10) set ^x(i)=\$j(i,990)
EOF

BEGIN "Test that incremental rollback creates enough room for future global references"
$gtm_exe/mumps -run incrb^incrollback
END
$gtm_tst/com/dbcheck.csh
