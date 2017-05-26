#!/usr/local/bin/tcsh -f
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
#
# This forces DEFAULT region's reg/resync seqno to 4G-16. Both for primary and secondary
#
set jnl_seqno = "FFFFFFF0"	# = 4G - 16  = 4294967280
set script = "set_resync_and_reg_seqno"
#
if !(-e mumps.repl)  $MUPIP replic -instance_create -name=$gtm_test_cur_pri_name $gtm_test_qdbrundown_parms $1
$sec_shell "$sec_getenv; cd $SEC_DIR; if !(-e mumps.repl)  $MUPIP replic -instance_create -name=$gtm_test_cur_sec_name $gtm_test_qdbrundown_parms $2"

$pri_shell "$pri_getenv; cd $PRI_DIR; echo `pwd`; $gtm_tst/com/${script}.csh DEFAULT $jnl_seqno ${script}_df.out"
$sec_shell "$sec_getenv; cd $SEC_DIR; echo `pwd`; $gtm_tst/com/${script}.csh DEFAULT $jnl_seqno ${script}_df.out"
