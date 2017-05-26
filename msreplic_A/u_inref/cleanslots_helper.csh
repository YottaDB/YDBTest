#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# pick randomly [0,1]
set rand = `$gtm_exe/mumps -run rand 2`
set rand = 1
set echo
$gtm_tst/com/ipcs -a | $grep $USER > ipcs_bef.log
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
if (0 == $rand) then
	$MSR RUN INST1 'set msr_dont_chk_stat; $MUPIP replic -source -shutdown -timeout=0' >& helper.log
else if (1 == $rand) then
	$MSR RUN INST1 '$MUPIP RUNDOWN -REG "*"' > helper.log
endif
$gtm_tst/com/ipcs -a | $grep $USER > ipcs_aft.log
