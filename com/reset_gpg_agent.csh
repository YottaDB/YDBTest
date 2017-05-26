#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# Script to kill an existing instance of gpg-agent based on the current setting of $GNUPGHOME.
# It is needed to work around the passphrase-caching issue in the gpg-agent.
#

if (! $?kill9) then
	# It is possible that this script is invoked in the remote host by multihost_encrypt_settings.csh,
	# even before the test output directories are created. Even thought set_specific.csh is sourced, it wouldn't have set
	# $kill9 and other variables that point to com scripts since $gtm_test_com_individual is not visible.
	# Calling send_env.csh at this point is not possible too. So explicitly define kill9 to Kill -9
	# instead of kill9.csh, since that would in turn require other com scripts dependencies
	set kill9 = "kill -9" # BYPASSOK kill
endif
if ($?GNUPGHOME) then
	set gnupg_home = $GNUPGHOME
else
	# The encryption/encr_env.csh test sometimes unsets both $GNUPGHOME and $HOME, which means
	# that though ~/.gnupg should be the default $GNUPGHOME, we cannot refer to it via '~'
	# because it is unusable. Hence, the test defines a special $HOMEDIR variable as a path to
	# $HOME.
	set gnupg_home = $HOMEDIR/.gnupg
endif

setenv reset_time		`date +%H_%M_%S`
setenv GPG_AGENT_RESET_LOG_BASE	gpg_agent_reset_${reset_time}
setenv GPG_AGENT_RESET_LOG	$GPG_AGENT_RESET_LOG_BASE.logx

@ i = 1
while (-f $GPG_AGENT_RESET_LOG)
	setenv GPG_AGENT_RESET_LOG ${GPG_AGENT_RESET_LOG_BASE}_$i.logx
	@ i++
end

$psuser | $grep -E "gpg\-agent .*\-\-homedir $gnupg_home .*\-\-daemon" > $GPG_AGENT_RESET_LOG
@ ps_count = `$tst_awk 'END {print NR}' $GPG_AGENT_RESET_LOG`

if (1 < $ps_count) then
	echo "More than one gpg-agent daemon with the same \$GNUPGHOME. See $GPG_AGENT_RESET_LOG for details. Exiting..."
	exit 1
endif

if (0 == $ps_count) then
	rm $GPG_AGENT_RESET_LOG
else
	@ agent_pid = `$tst_awk '{print $2}' $GPG_AGENT_RESET_LOG`
	echo "Sending SIGKILL to process $agent_pid." >> $GPG_AGENT_RESET_LOG
	$kill9 $agent_pid
	exit $status
endif
