#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
##############################################################################
##############
# Set Encryption related environment variable
if ($?test_replic) then
	if ($tst_org_host != $tst_remote_host) then
		$rsh $tst_remote_host "cd $tst_remote_dir/$gtm_tst_out/$testname ; source $gtm_tst/com/set_encrypt_env.csh $tst_remote_dir/$gtm_tst_out/$testname $gtm_dist $tst_src"
	endif
	if ("MULTISITE" == "$test_replic") then
		# on top of the above, we need to remove the directories on the other hosts
		set cnt = `setenv | $grep -E "tst_remote_dir_ms_[0-9]" | wc -l`
		set cntx = 1
		while ($cntx <= $cnt)
			set tst_remote_hostx = `echo echo \$tst_remote_host_ms_$cntx | $tst_tcsh`
			set tst_remote_dirx  = `echo echo \$tst_remote_dir_ms_$cntx | $tst_tcsh`
			$rsh $tst_remote_hostx "cd $tst_remote_dirx/$gtm_tst_out/$testname ; source $gtm_tst/com/set_encrypt_env.csh $tst_remote_dirx/$gtm_tst_out/$testname $gtm_dist $tst_src"
			$rcp "$tst_remote_hostx":$tst_remote_dirx/$gtm_tst_out/$testname/encrypt_env_settings.txt $tst_dir/$gtm_tst_out/$testname/$tst_remote_hostx"_encrypt_env_settings.txt"
			@ cntx = $cntx + 1
		end
	endif
endif
### Create Encryption related environment variables for all GT.CM hosts ####
if ($?test_gtm_gtcm_one) then
	source $gtm_tst/com/gtcm_command.csh "SEC_SHELL_GTCM ; cd TST_REMOTE_DIR_GTCM/$gtm_tst_out/$testname ; source $gtm_tst/com/set_encrypt_env.csh TST_REMOTE_DIR_GTCM/$gtm_tst_out/$testname $gtm_dist $tst_src"
endif
