#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#---------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#----------------------------------------------------------------------------------------------------------------------------------------------------------
# ydb854     [nars]     Test that ICUSYMNOTFOUND error using Simple API does not assert fail
# ydb860     [nars]     Test various code issues identified by fuzz testing
# ydb861     [estess]   Test $ZATRANSFORM() returns correct value for 2/-2 3rd parm and does not sig-11 with computed input values
# ydb869     [nars]     Test boolean expressions involving huge numeric literals issue NUMOFLOW error (and not SIG-11)
# ydb872     [nars]     Test GTMASSERT2 fatal error no longer occurs when lots of short-lived processes open/close relinkctl files
# ydb864     [bdw]      Test online and -noonline MUPIP BACKUPs with path lengths from 220 to 265
# ydb888     [sam]      Test $ZGLD is a valid synonym for $ZGBLDIR
# ydb901     [nars,sam] SIG-11 when compiling with -NOLINE_ENTRY if M code contains a BREAK
# ydb919     [nars]     Test %ZMVALID M utility routine
# ydb940     [nars]     Test $PRINCIPAL output device flush, if it is a terminal, happens on call-out from M to C
# ydb877     [nars]     Test $VIEW("JOBPID")
# ydb908     [nars]     Test $ZGETJPI(PID,"CPUTIM") (and CSTIME,CUTIME,STIME,UTIME) works for any PID, not just the current process
# ydb708     [nars]     Test COMMAND device parameter for PIPE devices allows values longer than 255 bytes
# ydb943     [nars]     Test that YDBEncrypt scripts get installed with execute permissions in $ydb_dist/plugin/ydbcrypt
# ydb575     [nars]     Test that CRYPTINIT error while opening an encrypted database does not leave ipcs (ftok semaphore)
# ydb941     [nars]     Test that SET $ZGBLDIR sets ydb_cur_gbldir env var to new $ZGBLDIR
# ydb944     [nars]     Test that no %YDB-E-TPFAIL error (eeee) when cnl->tp_hint is almost 2GiB
# ydb565     [nars]     Test that ydb_buffer_t can be used to pass string values in call-ins and call-outs
# ydb951     [nars]     Test that OPEN of /dev/null correctly reads device parameters (no garbage-reads/overflows)
# ydb716     [nars]     Test that MUPIP CREATE -REGION= creates database file even for AUTODB regions
# ydb830     [nars]     Test that lvn in SET lvn=$FNUMBER stays unmodified if $FNUMBER errors out
# peekbyname [nars]     Test PEEKBYNAME for all fields output by LIST^%PEEKBYNAME and check no errors
# ydb945     [nars]     Test that ydb_env_set returns non-zero exit status on MUPIP CREATE errors
# ydb839     [sam]      Verify misspelt ISVs are not interpreted as valid ISVs
# ydb925     [sam]      Regression test for parsing incompletly specified Z* ISV, functions and commands
# ydb904     [sam]      Test that abbreviations starting with $ZY are not considered valid (with some exceptions)
# ydb954     [nars]     Test %YDB-E-SYSCALL message from stat() (while processing $ZROUTINES) identifies file name
# ydb956     [nars]     Test VIEW "GBLDIRLOAD"
# ydb961     [nars]     Test $ZTIMEOUT reset does not cause ASAN heap-use-after-free error
# ydb459     [nars]     Test MUPIP RUNDOWN reports REPLINSTACC error if replication instance file is missing
# ydb729     [nars]     Test ACTLSTTOOLONG and FMLLSTMISSING errors print SRCLOC message with line/column number detail
#----------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r136 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "ydb854 ydb860 ydb861 ydb869 ydb872 ydb864 ydb888 ydb901 ydb919 ydb940 ydb877 ydb908 ydb708"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb943 ydb575 ydb941 ydb944 ydb565 ydb951 ydb716 ydb830 ydb945 ydb839"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb925 ydb904 ydb954 ydb956 ydb961 ydb459 ydb729"
setenv subtest_list_replic     "peekbyname"

if ($?test_replic == 1) then
       setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
       setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

if (("rhel" == $gtm_test_linux_distrib) && ("7.9" == $gtm_test_linux_version)) then
	# ydb575 subtest creates an encrypted database. And that causes the following 2 lines to infinitely repeat
	# on the terminal only on a RHEL 7 system.
	#	Enter the user ID.  End with an empty line: No such user ID.
	#	Current recipients:
	# This does not happen on other distributions. Since RHEL 7 is no longer a supported distribution for YottaDB,
	# we exclude this test there.
	setenv subtest_exclude_list "$subtest_exclude_list ydb575"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r136 test DONE."
