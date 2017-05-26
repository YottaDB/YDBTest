#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_trigger_etrap 'w $c(9),"$ZSTATUS=",$zstatus,! s $ecode=""'
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run compile

$drop >& /dev/null
$echoline

# Don't do the remaining tests on platforms that use mutex socket files
# Platforms that use mutex files
# NO: MUTEX_MSEM_WAKE is defined (linux, sun, hpux, dux, aix)
# Yes: MUTEX_MSEM_WAKE is undefined (z/OS, tru64, ia32 linux)
$echoline
if ( "HOST_OSF1_ALPHA" == "$gtm_test_os_machtype" || \
	"HOST_OS390_S390" == "$gtm_test_os_machtype" || \
	"HOST_LINUX_IX86" ==  "$gtm_test_os_machtype" ) then
	$gtm_tst/com/dbcheck.csh -extract
	exit 0
endif

# save the original gtm_tmp
if ($?gtm_tmp) then
	setenv gtm_tmp_bak $gtm_tmp
endif

# Since this test plays with $gtm_tmp, unset the below dbg-only env var as otherwise it can cause the pinentry script
# (which is invoked under the covers in case of an encrypted test run) to do a "mumps -run pinentry" and try locating
# pinentry.o assuming an autorelink-enabled directory in $zroutines. And since $gtm_linktmpdir is not defined, we will
# try to create the relinkctl file in $gtm_tmp where we dont have permissions and will end up with errors.
unsetenv gtm_test_autorelink_always

echo "Checking what happens when GTM_DEFAULT_TMP / P_tmpdir don't exist"
setenv gtm_tmp "/tmp/trg${user}compile$$/deny"
$load compile_pass.trg
echo ""

echo "Checking what happens with bad permissions on GTM_DEFAULT_TMP / P_tmpdir"
echo "No perms at all"
rm -rf $gtm_tmp
mkdir -p $gtm_tmp
chmod 111 $gtm_tmp
$load compile_pass.trg
echo ""
echo "No write perms"
chmod 555 $gtm_tmp
$load compile_pass.trg
echo ""

echo "Checking what happens when GTM_DEFAULT_TMP / P_tmpdir is a file"
chmod 777 $gtm_tmp
rm -rf $gtm_tmp
touch $gtm_tmp
$load compile_pass.trg

# cleanup the top level tmp directory created
rm -rf $gtm_tmp:h

# Run only on a system with smallfs TODO
# echo "Checking what happens with disk space issues GTM_DEFAULT_TMP / P_tmpdir"
# moved to the smallfs test

# restore the original gtm_tmp
if ($?gtm_tmp_bak) then
	setenv gtm_tmp $gtm_tmp_bak
else
	unsetenv gtm_tmp
endif

$echoline
$gtm_tst/com/dbcheck.csh -extract
