#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	setenv test_specific_gde $gtm_tst/$tst/inref/truncate_simple.gde
endif
setenv gtm_test_spanreg 0	# Since test_specific_gde is set in case of spanning regions
setenv test_reorg NON_REORG
setenv gtm_test_mupip_set_version "V5"

$gtm_tst/com/dbcreate.csh mumps 4 255 500 1024
set verbose
$gtm_exe/mumps -run %XCMD 'for i=1:1:10000 set v=$j(i,200) set ^a(i)=v,^b(i)=v,^c(i)=v,^d(i)=v'
$MUPIP reorg -truncate
$gtm_exe/mumps -run %XCMD 'kill ^a,^b,^c,^d'
$MUPIP reorg -truncate
unset verbose
$gtm_tst/com/dbcheck.csh
