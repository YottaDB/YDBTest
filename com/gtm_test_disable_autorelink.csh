#/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script disables the autorelink functionality for the duration of one particular subtest. To fully take
# effect, this script needs to be *sourced* (not merely invoked) at the beginning of a respective test script.

# First, rid the current $gtmroutines of any autorelink-enabled directories.
setenv gtmroutines `echo "$gtmroutines" | sed -e "s|*||g"`

# Next, prevent all further $gtmroutines instances from re-enabling autorelink.
setenv gtm_test_autorelink_dirs 0

# Finally, unset the unconditional autorelink mode, should it be enabled.
unsetenv gtm_test_autorelink_always

# Because the randomly chosen value of $gtm_test_autorelink_dirs as well as $gtm_test_autorelink_always might
# have changed, record their new values in settings.csh.
echo "gtm_test_autorelink_dirs and gtm_test_autorelink_always modified by gtm_test_disable_autorelink.csh"	>> settings.csh
echo "setenv gtm_test_autorelink_dirs $gtm_test_autorelink_dirs"						>> settings.csh
echo "unsetenv gtm_test_autorelink_always"									>> settings.csh
