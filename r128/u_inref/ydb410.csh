#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test signal forwarding enable/disable.
#
# Turn off ydb_dbglvl/gtmdbglvl as certain settings can influence how this test runs.
#
unsetenv ydb_dbglvl
unsetenv gtmdbglvl
echo "---------------------------------------------------------------------------"
echo "ydb410: Tests forwarding (from YDB to non-YDB base program) of all signals"
echo "        except SIGTSTP, SIGTTIO, and SIGTTOU (which cause process suspension)"
echo
#
echo "** First build ydb410 executable to create a handler for a given signal and see"
echo "** if it gets forwarded or not. Note either answer (yes it was forwarded or no"
echo "** it was not) can be the correct answer depending on the setup. An 'invald"
echo "** argument' reply is also possible for the signals that the OS disallows"
echo "** setting a sigaction() handler for. Also SIGCHLD is a signal we do not allow"
echo "** to be forwarded. It is also unconditionally installed with an 'ignore' type"
echo "** handler so it's forwarding won't work."
echo
#
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/ydb410.c -I$gtm_dist
set savestatus = $status
if (0 != $savestatus) then
    echo "Error building ydb410 - failure status: $savestatus"
    exit 1
endif
$gt_ld_linker $gt_ld_option_output ydb410 $gt_ld_options_common ydb410.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if( $status != 0 ) then
    cat link.map
endif
# Only need map if was an error. Also get rid of ydb410.o since we'll be driving ydb410.m which will look at this object file from
# compiling the C program as an invalid format object file and complain.
rm -f link.map ydb410.o
#
# By default SIGALRM and SIGUSR1 are NOT forwarded by default so set them into the forward list. All other signals, except
# the restricted signals (see sr_unix/ydb_sigfwd_init.c), are by default setup to be forwarded.
setenv ydb_signal_fwd "ALRM usr1"
# Drive ydb410.m which will drive our C routine once for each signal type to see if it can be intercepted. Since this
# routine only currently runs with a PRO build (differences between PRO run and DBG run are significant due to how fatal signals
# are handled at this time), we should see the signal forwarded from all but the restricted signals. Some of those generate
# errors (i.e. SIGKILL and SIGSTOP are not catchable so generate runtime errors when we try to setup a handler for them). The
# others though will generate timeouts or suspend the process (temporarily - they resume very quickly).
$ydb_dist/yottadb -run ydb410
#
# Now, without clearing ydb_signal_fwd, set SIGALRM and SIGUSR1 into the NOFWD list. Since this list is processed
# second, it should actually remove the request to forward being done by $ydb_signal_fwd. Note we also add an
# invalid signal to both the forward and noforward lists which should send an error to the operator log which we will verify.
# This check is added here instead of above as a message above would repeat 128 times while this one only reproduces 4 times.
setenv ydb_signal_fwd "$ydb_signal_fwd notasig"
setenv ydb_signal_nofwd "sigalrm USR1 signotis"
echo
echo "---------------------------------------------------------------------------"
echo
echo "Test forwarding for SIGALRM and SIGUSR1 after also adding them to the NOFWD list"
echo
#
# Now run a ydb410 (C routine) invocation just for these two signals (note the arguments to ydb410 have to be numeric). Note
# these two are SIGALRM (14) and SIGUSR1 (10) respectively on Linux. If this test starts failing, verify these numbers are
# still correct.
ydb410 14
ydb410 10

