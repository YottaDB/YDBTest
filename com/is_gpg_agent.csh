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

# This is a helper script that determines if a gpg agent is needed for encryption/decryption
# This script is sourced by set_encrypt_env.csh to set the value for $gtm_gpg_use_agent

ps -e |& grep -wq gpg-agent 	# BYPASSOK ps
if (! $status) then
	# An agent is already running. Simply assume this host needs gpg agent
	# This is because, reset_gpg_agent.csh call below kills the running gpg-agent process
	# and that sometimes (if the timing is bad) causes test failures.
	# e.g when this host is running an encryption test and this script is invoked in this host as a part of multi-host run on a different server
	exit 0	# Agent IS needed
endif
$gtm_dist/plugin/gtmcrypt/gen_sym_key.sh 0 agentcheck.key >&! gen_sym_key.out
$gtm_tst/com/reset_gpg_agent.csh
setenv gtm_passwd `echo gtmrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
setenv GTMXC_gpgagent $gtm_dist/plugin/gpgagent.tab
set result = `$gpg --no-tty --batch -d agentcheck.key | wc -c`
rm agentcheck.key
$gtm_tst/com/reset_gpg_agent.csh
if (32 != $result) then
	# Agent NOT needed
	exit 1
else
	# Agent IS needed
	exit 0
endif
