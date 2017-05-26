#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if !($?gtm_test_replay) then
	@ rand = `$gtm_exe/mumps -run rand 2`
	if (0 == $rand) then
		setenv interrupted_rolrec ROLLBACK
	else
		setenv interrupted_rolrec RECOVER
	endif
	echo "# interrupted_rolrec chosen in interrupted_rollback_or_recover.csh "	>>&! settings.csh
	echo "setenv interrupted_rolrec $interrupted_rolrec"				>>&! settings.csh
endif
$gtm_tst/$tst/u_inref/rolrec_intr_stop_idemp.csh $interrupted_rolrec CRASH . . 1
if ($status) exit
mkdir round1
$gtm_tst/com/errors.csh round1_error.log >&! round1_error.logx
if (-e showbacklog.log) mv showbacklog.log round1
$gtm_tst/com/backup_dbjnl.csh round1 '*.dat *.gld *.mjl*  *.log* *.txt time* *.csh *.repl* *.out'
$tst_gunzip round1/time1_abs*
mv bak_* round1
cp -p MUPIP_${interrupted_rolrec}.log MUPIP_${interrupted_rolrec}_1.log
echo "### One more time ###"
$gtm_tst/$tst/u_inref/rolrec_intr_stop_idemp.csh $interrupted_rolrec CRASH . . 2
if ($status != 0) echo "TEST-I-INFO script status was $status"
$gtm_tst/$tst/u_inref/check_timing.csh
