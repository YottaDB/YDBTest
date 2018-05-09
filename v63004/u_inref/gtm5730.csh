#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

setenv gtm_test_jnl SETJNL
setenv gtm_repl_instance mumps.repl
setenv gtm_repl_instname INSTANCE1
#setenv gtm_test_spanreg 0		# Test requires traditional global mappings, so disable spanning regions

#setenv gtm_test_repl_skipsetreplic "" 	#setting this skips turning on replication in the passive start script
#setenv gtm_test_dbcreate_initial_tn 10	#setting initial db transaction number to 2**10 = 1024

$gtm_tst/com/dbcreate.csh mumps 2 255 8000 16384 1024 1024 1024 > db_log.txt

echo " #Calls gtm5730.m to set variables"
$ydb_dist/mumps -run gtm5730 > gtm5730.m.log


$MUPIP journal -forward -extract=./Reg.mjf -seqno=~0,1,~2 "a.mjl" >>& db_log.txt
echo "# Search extract file for set variables"
if (  -f Reg.mjf ) then
	$ydb_dist/mumps -run LOOP^%XCMD --xec=';write:$zfind(%l,"=") $zpiece(%l,"\",6)," ",$zpiece(%l,"\",11),!;' < Reg.mjf
	rm Reg.mjf
else
	echo "# Reg.mjf not created (not supposed to happen here)"
endif
####################################
##Excerpt from v60000/u_inref/gtm4525b.csh
####################################
#$gtm_tst/com/dbcreate.csh mumps 4 125 1000 4096 2000 4096 2000 >&! dbcreate.out
#
#
#
#echo ""
#echo "# Replication Setup"
#echo ""
#
#unsetenv gtm_repl_instance
#$MUPIP set -region "*" -journal=before -replic=on >&! journalcfg.out 	#changing journal settings
#setenv gtm_repl_instance mumps.repl				     	#mumps.repl will be our repl file
#if ($?test_replic) then							#probably unnecessary since we always want to do this?
#	$MSR START INST1 INST2 RP >&! msr_start_`date +%H_%M_%S`.out	#Look up use of INST1 and INST2
#	get_msrtime
#	set start_time=$time_msr				 	#So this is probably all that we need to do in order to generate a *.updproc file?
#else
#	# source this to get start_time variable
#	source $gtm_tst/com/passive_start_upd_enable.csh >&! passive_start_`date +%H_%M_%S`.out
#endif
#$gtm_tst/com/backup_for_mupip_rollback.csh # Needed for test_replic=1 because replication has been explicitly
					   # turned on before calling $MSR START in the test_replic=1 case.
					   # Needed for test_replic=0 because this test does rollback even in this case.
