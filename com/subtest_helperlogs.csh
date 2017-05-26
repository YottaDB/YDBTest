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


set b4after = "$1"
setenv gtm_tst "$2"

# $3 will be of the form /testarea1/e3008919/V990/tst_..../test_1/subtest
set subtestdir  = "$3"
set sub_test    = "$3:t"
set testname    = "$3:h:t"
set outdir      = "$3:h:h"
set passfail    = "$4"

set shorthost       = "$HOST:ar"
set debuglocal      = "$outdir/debugfiles"
set debugglobal     = "$ggdata/tests/debuglogs/$outdir:t"		# hardcoding should be in sync with other scripts
set ipcslog         = "$debuglocal/$testname.ipcs"
set pslog           = "$debuglocal/$testname.pslist"
set remoteipcslog   = "$ipcslog:t"
set portcleanupfile = "delete_reserved_portfiles.csh"			# hardcoding should be in sync with other scripts
set portcleanuplog  = "$debugglobal/${testname}_${sub_test}_port.txt"	# hardcoding should be in sync with other scripts

if (! -d $subtestdir) mkdir -p $subtestdir
cd $subtestdir

source $gtm_tst/com/set_specific.csh
if (! -e helperlogs_env.csh) then
	set envtxt = `find . -name env.txt |& head -1`	# BYPASSOK head
	if ("" != "$envtxt") then
		$grep -E "^gtm|^tst|^test" $envtxt | sed 's/^/setenv /;s/=/ "/;s/$/"/' >&! helperlogs_env.csh
	endif
endif
if (-e helperlogs_env.csh) then
	source helperlogs_env.csh
endif
if (! $?tst_org_host) then
	# will not be defined if it is a remote host (a simple ssh is done, env is not sourced)
	set remoteipcslog = "${remoteipcslog}_$HOST:ar"
else
	if ("$tst_org_host:ar" != "$HOST:ar") then
		# If tst_org_host is defined (in case of GT.CM) but is not the original host
		set remoteipcslog = "${remoteipcslog}_$HOST:ar"
	endif
endif
source $gtm_tst/com/set_specific.csh

if (! -d $debuglocal) then
	mkdir -p $debuglocal
endif

echo "# $b4after $sub_test : `date`"		>>&! $ipcslog
$gtm_tst/com/ipcs -a |& $grep $USER		>>&! $ipcslog

echo "# $b4after $sub_test : `date`" 		>>&! $pslog
$ps						>>&! $pslog

if ("Before" == "$b4after") then
	$gtm_tst/com/ipcs -a 			>&! $outdir/ipcs.b4subtest
	ls -1 /tmp/relinkdir/$USER |& sort	>&! $outdir/relinkctl.b4subtest
	set syslog_before = `date +"%b %e %H:%M:%S"`
	echo "$syslog_before"			>&! $subtestdir/start_time_syslog.txt
endif

if ("After" == "$b4after") then
	cp -p $ipcslog $debugglobal/$remoteipcslog
endif

# Some after test activities :
if ("After" == "$b4after") then
	# If the subtest failed and if the current host is a broken-pipe infected one, look for broken pipe messages
	if (0 != "$passfail"  || $?tst_keep_output) then
		if ($shorthost =~ {inti,liza,atlhxit1,lespaul}) then
			find $PWD \( -name "*.out*" -o -name "*.log*" -o -name "*.mjo*" ! -name "*.gz" \) -exec $grep "Broken pipe" {} +
		endif
		# If the subtest failed, get syslog
		# The current environment setup ($gtm_tst and sourcing set_specific.csh) is enough to run getoper.csh.
		# If this changes or if new things have to be done, source env.txt in subtest directory before invoking scripts
		set syslog_before = `cat $subtestdir/start_time_syslog.txt`
		set syslog_after = `date +"%b %e %H:%M:%S"`
		$gtm_tst/com/getoper.csh "$syslog_before" "$syslog_after" $subtestdir/syslog_${sub_test}.txt
		# If the subtest used hugepages, check for "killed due to inadequate hugepage pool" syslog messages
		if ($?gtm_test_hugepages) then
			if (1 == $gtm_test_hugepages) $grep "hugepage" $subtestdir/syslog_${sub_test}.txt
		endif
		if ( ("ENCRYPT" == $test_encryption) && ( $?GNUPGHOME ) )  then
			if (-e $GNUPGHOME/gtm_pinentry.log) cp -pf $GNUPGHOME/gtm_pinentry.log .
		endif
	endif

	# If the subtest passed and portcleanup script exists, source it
	if ( (0 == $passfail) && (-e $portcleanupfile) ) then
		source $portcleanupfile >>&! $portcleanuplog && mv $portcleanupfile orig_$portcleanupfile
	endif
endif
