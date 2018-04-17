#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# Tests performed:
#
#   1. Set an invalid $gtm_tmp, invoke GTM and verify get INVTMPDIR instead of INVLINKTMPDIR
#   2. Set an invalid $gtm_linktmpdir, invoke GTM and verify get INVLINKTMPDIR.
#   3. Set an invalid $gtm_tmp AND and invalid $gtm_linktmpdir expecting to see both errors.
#
# We also want to do tests 1 and 2 with gtmsecshr though the expected results are different. The first
# test is the same but whether $gtm_linktmpdir is good or bad for the 2nd test is irrelevant because the
# gtmsecshr wrapper turns the environment variable to a NULL string. This is an additional component to this
# fix - that gtmsecshr ignores $gtm_linktmpdir so it shouldn't do anything with either a good OR bad value
# so we'll just stick to the bad value.
#
# Before setting any bogus flags, start a gtmsecshr up in case one was not running so we have a gtmsecshr
# running sans bogus values. Then we can run our cases. Only one gtmsecshr can run at a time but envvars
# are checked before attempting to lock the gtmsecshr semaphore so we get far enough for our purposes and
# expect gtmsecshr to not start.
#
# Note the blow tests count the relevant (grep'd) lines since the format of syslog messages varies across the
# platforms.
#
$gtm_dist/gtmsecshr
#
$echoline
sleep 1
set syslog_start = `date +"%b %e %H:%M:%S"`
echo
echo "gtm_tmp is bogus - expect INVTMPDIR from mumps (1)"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tmp gtm_tmp "bogus"
$gtm_dist/mumps -run gtm8317util
sleep 1
set syslog_end = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_start" "$syslog_end" test_syslog1.txt
$grep INVTMPDIR test_syslog1.txt | $grep -c `cat runningMpid.txt`

#
# Bypass this gtmsecshr check on AIX. On AIX the gtmsecshr wrapper currently removes most envvars before driving
# gtmsecshr. This includes the TZ envvar which defines which timezone the process runs in. After initialization is
# complete, gtmsecshr re-establishes its default timezone but errors raised before that is done have a GMT/UTC
# time so syslog messages thusly recorded are not fetched by getoper.csh over the range of this test. This will
# likely be fixed when GTM-7778 is fixed which will fix the gtmsecshr wrapper's timestamped messages and leave TZ
# set properly for gtmsecshr.
#
if ("HOST_AIX_RS6000" != "$gtm_test_os_machtype") then
    echo
    $echoline
    sleep 1
    set syslog_start = `date +"%b %e %H:%M:%S"`
    echo
    echo "gtm_tmp is bogus - expect INVTMPDIR from gtmsecshr (1)"
    $gtm_dist/gtmsecshr
    sleep 1
    set syslog_end = `date +"%b %e %H:%M:%S"`
    $gtm_tst/com/getoper.csh "$syslog_start" "$syslog_end" test_syslog2.txt
    $grep INVTMPDIR test_syslog2.txt | $grep -c "SECSHR"
endif

#
# Bypass $gtm_linktmpdir validations on non-autorelink platforms
#
if ((HOST_LINUX_IX86 != "$gtm_test_os_machtype") && (HOST_HP-UX_IA64 != "$gtm_test_os_machtype")) then
    echo
    $echoline
    sleep 1
    set syslog_start = `date +"%b %e %H:%M:%S"`
    echo
    echo "gtm_tmp and gtm_linktmpdir are bogus - expect INVTMPDIR and INVLINKTMPDIR from mumps (2)"
    setenv gtm_linktmpdir "bogus"
    $gtm_dist/mumps -run gtm8317util
    sleep 1
    set syslog_end = `date +"%b %e %H:%M:%S"`
    $gtm_tst/com/getoper.csh "$syslog_start" "$syslog_end" test_syslog3.txt
    grep -E "INVTMPDIR|INVLINKTMPDIR" test_syslog3.txt | $grep -c `cat runningMpid.txt`

    echo
    $echoline
    sleep 1
    set syslog_start = `date +"%b %e %H:%M:%S"`
    echo
    echo "gtm_linktmpdir is bogus - expect INVLINKTMPDIR from mumps (1)"
    source $gtm_tst/com/unset_ydb_env_var.csh ydb_tmp gtm_tmp
    $gtm_dist/mumps -run gtm8317util
    sleep 1
    set syslog_end = `date +"%b %e %H:%M:%S"`
    $gtm_tst/com/getoper.csh "$syslog_start" "$syslog_end" test_syslog4.txt
    $grep INVLINKTMPDIR test_syslog4.txt | $grep -c `cat runningMpid.txt`

    echo
    $echoline
    sleep 1
    set syslog_start = `date +"%b %e %H:%M:%S"`
    echo
    echo "gtm_linktmpdir is bogus - expect gtmsecshr to not care (0)"
    $gtm_dist/gtmsecshr
    sleep 1
    set syslog_end = `date +"%b %e %H:%M:%S"`
    $gtm_tst/com/getoper.csh "$syslog_start" "$syslog_end" test_syslog5.txt
    $grep INVLINKTMPDIR test_syslog5.txt | $grep -c "SECSHR"
endif

exit 0
