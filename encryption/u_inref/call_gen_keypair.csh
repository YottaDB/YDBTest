#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# gen_keypair.sh on some servers leaves behind gpg-agent process that does not have --homedir in the ps listing,
# so reset_gpg_agent.csh will not be able to kill it. Manually get the list of gpg-agents before and after and kill the new one.
# Filter processes that either do not have homedir or homedir pointing to $GNUPGHOME above
set before_file = "gpg_agents_before_${USER}"
set after_file  = "gpg_agents_after_${USER}"
$psuser |& $grep 'gpg-agent --' | $grep -v grep					>&!  ${before_file}.out
$grep -v homedir ${before_file}.out |& $tst_awk '{print $2}'			>&!  ${before_file}.pids
$grep "homedir $GNUPGHOME" ${before_file}.out |& $tst_awk '{print $2}' 		>>&! ${before_file}.pids
set before_pids = `cat ${before_file}.pids`
set before_pids_2 = ($before_pids)
# Do a find to generate entropy to make gen_keypair.csh finish quicker
@ find_pid = `(find / >&! /dev/null &; echo $!) | $grep -v ' '` # ` - to fix vim highlighting
printf "%s\n%s" $USER $USER | $gtm_tst_ver_gtmcrypt_dir/gen_keypair.sh $USER@fnis.com $USER >&! gen_keypair.out
$kill9 $find_pid
$psuser |& $grep 'gpg-agent --' | $grep -v grep					>&!  ${after_file}.out
$grep -v homedir ${after_file}.out |& $tst_awk '{print $2}'			>&!  ${after_file}.pids
$grep "homedir $GNUPGHOME" ${after_file}.out |& $tst_awk '{print $2}'		>>&! ${after_file}.pids
set after_pids = `cat ${after_file}.pids`

foreach pid ($after_pids)
	set -l before_pids_2 = ($before_pids_2 $pid)
	if ($#before_pids_2 != $#before_pids) then
		# set "-l" appends an element to the array only if it is not already existing
		# This is a new pid not in the before_pid list. This is what we need to kill
		set killpid = $pid
		break
	endif
end

if ($?killpid) then
	$kill9 $killpid
endif
