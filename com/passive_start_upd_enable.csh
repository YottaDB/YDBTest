#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Start passive sourver with update enable

#this script is called from tests that are not submitted with replication (but need a dummy replication server to be running), initialize the necessary:
if (! $?gtm_repl_instance) then
	setenv gtm_repl_instance mumps.repl
endif
if (! $?gtm_repl_instname) then
	setenv gtm_repl_instname INSTANCE1
endif
if (! -e $gtm_repl_instance) then
	$MUPIP replic -instance_create -name=$gtm_repl_instname $gtm_test_qdbrundown_parms
endif
if (! $?gtm_test_cur_pri_name) then
	setenv gtm_test_cur_pri_name $gtm_repl_instname
endif
if (! $?gtm_test_cur_sec_name) then
	setenv gtm_test_cur_sec_name INSTANCE2
endif
if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
endif
setenv start_time `date +%H_%M_%S`
if (! $?gtm_test_repl_skipsetreplic) $MUPIP set -replic=on -reg "*"
$MUPIP replic -source $gtm_test_instsecondary -passive -start -buffsize=$tst_buffsize  -log=SRC_{$start_time}.log -rootprimary
if (! $?gtm_test_repl_skipsrcchkhlth) then
	if ("" == `$MUPIP replicate -source $gtm_test_instsecondary -checkhealth | & $grep "server is alive"`) then
		echo "TEST-E-passive_upd_enable passive source server is not alive"
	endif
endif
