#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
source $gtm_tst/com/cre_coll_sl.csh com/col_polish.c 1
source $gtm_tst/com/cre_coll_sl.csh com/col_polish_rev.c 2
unsetenv gtm_local_collate # Unset value set by com/cre_coll_sl.csh

if ($?test_replic) then
	# replic
	# NOT TESTED
	if ($tst_org_host != $tst_remote_host) then
		$gtm_tst/com/send_env.csh
		$gtm_tst/com/cre_coll_sl.csh com/col_polish.c 1
		$gtm_tst/com/cre_coll_sl.csh com/col_polish_rev.c 2
	endif
else if ("GT.CM" == $test_gtm_gtcm) then
	#GT.CM
	$gtm_tst/com/send_env.csh
	$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM ; cd SEC_DIR_GTCM; $gtm_tst/com/cre_coll_sl.csh com/col_polish.c 1; $gtm_tst/com/cre_coll_sl.csh com/col_polish_rev.c 2"
endif
