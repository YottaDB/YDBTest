#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2010, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 5 255 4096 8192
$gtm_exe/mumps -run validnames

$echoline
echo "Look at the file before mupip trigger -triggerfile=names.trg -noprompt"
cat names.trg
$MUPIP trigger -trig=names.trg -noprompt

$echoline
echo "load and run all those triggers"
$grep '^+' names.trg > append.trg
$load append.trg
$gtm_exe/mumps -run run^validnames
$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/backup_dbjnl.csh bak1 "*.dat *.gld" mv
$echoline

# Test select and delete by name
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 5 255 4096 8192
$gtm_exe/mumps -run namedelete
$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/backup_dbjnl.csh bak2 "*.dat *.gld" mv

echo "# Test triggers for > 21 character global names go to respective mapped regions"
echo "# and can coexist with conflicting auto-generated names in same gld."
$GDE << GDE_EOF >&! gde.out
add -region areg -dyn=aseg
add -segment aseg -file=a
add -region breg -dyn=bseg
add -segment bseg -file=b
add -region creg -dyn=cseg
add -segment cseg -file=c
add -name a23456789012345678901a -region=areg
add -name a23456789012345678901b -region=breg
add -name a23456789012345678901c -region=creg
add -name a23456789012345678901d -region=DEFAULT
add -name a23456789012345678901e -region=areg
add -name a23456789012345678901f -region=creg
exit
GDE_EOF

$MUPIP create
$gtm_exe/mumps -run longname21chars^namedelete
$gtm_tst/com/dbcheck_base.csh

