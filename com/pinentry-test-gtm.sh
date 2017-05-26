#!/bin/sh
#################################################################
#                                                               #
# Copyright (c) 2010-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

####################################################################################################################################
#
# NOTE:	This program is almost identical to pinentry-gtm.sh shipped with the encryption plug-in. The only difference is that instead
#	of invoking pinentry.m (also shipped with the plug-in) it executes pinentry-safe.sh, which then either fires up pinentry.m
#	(for versions V5.5-000 and up), or follows a simple gpg-agent communication protocol to return the default password to GPG.
#
#	PLEASE KEEP THIS SCRIPT IN SYNC WITH pinentry-gtm.sh AS MUCH AS POSSIBLE.
#
#	If you are making changes to this file, make sure to update it in the $gtm_com/gnupg directory, which is present and owned
#	by library on every box. To do that, simply issue the following command as library with the appropriate test version
#	specified:
#
#	  $cms_tools/doall.csh -server "linuxbox all" -run "$cms_tools/build_gnupghome.csh -force -tver T9XX " -doallmail <username>
#
#	To test the changes prior to committing them, modify the pinentry-program line in /tmp/gnupgdir/$USER/gpg-agent.conf (or
#	simply replace the file) on all requisite boxes to point to pinentry-test-gtm.sh in the specific test version.
#
# This script is used as a "pinentry-program" in gpg-agent.conf. If the gtm_passwd environment variable exists and a usable mumps
# exists, run pinentry.m to get the passphrase from the environment variable.
#
####################################################################################################################################

dir=`dirname $0` ; if [ -z "$dir" ] ; then dir=$PWD ; fi
if [ -z "$gtm_pinentry_log" ] ; then gtm_pinentry_log=$PWD/pin.log ; fi
punt=1

date >> $gtm_pinentry_log 2>&1

if [ -z "$gtm_dist" ] ; then
	# $gtm_dist is not set in the environment. See if we can use dirname to find one
	if [ "`echo $gtm_chset | tr utf UTF`" = "UTF-8" -a -x "$dir/../../utf8/mumps" ] ; then
		export gtm_dist=$dir/../../utf8
	elif [ -x "$dir/../../mumps" ] ; then
		export gtm_dist=$dir/../..
		unset gtm_chset
	fi
fi

# Test system directs pinentry to run in M mode only
if [ ! -z "$gtm_test_force_pinentry_chset" ] ; then
	export gtm_chset="$gtm_test_force_pinentry_chset"
fi

if [ -n "$gtm_passwd" -a -x "$gtm_dist/mumps" ] ; then
	# Prior versions put PINENTRY in $gtm_dist
	if [ -e "$gtm_dist/PINENTRY.o" ] ; then
		pinentry=PINENTRY
	else
		pinentry=pinentry
	fi
	# Password and MUMPS exists, perform some extended setup checks
	if [ -z "$gtmroutines" ] ; then
		utfodir=""
		if [ "`echo $gtm_chset | tr utf UTF`" = "UTF-8" -a -x "$dir/../../utf8/mumps" ] ; then
			utfodir="/utf8"
		fi
		# $gtmroutines is not set in the environment, attempt to pick it up from  $gtm_dist/plugin/o, $gtm_dist, libgtmutil.so
		if [ -e "$gtm_dist/plugin/o${utfodir}/pinentry.o" ] ; then
			export gtmroutines="$gtm_dist $gtm_dist/plugin/o${utfodir}"
		elif [ -e "$gtm_dist/PINENTRY.o" ] ; then
			export gtmroutines="$gtm_dist"
		elif [ -e "$gtm_dist/libgtmutil.so" ] ; then
			export gtmroutines="$gtm_dist/libgtmutil.so"
		fi
	fi

	# Validate gtmroutines. Redirect output or it will affect the password protocol
	printf 'zhalt (0=$zlength($text(pinentry^'$pinentry')))' | gtm_local_collate= LD_PRELOAD= gtm_trace_gbl_name= gtmdbglvl= gtmcompile= gtm_white_box_test_case_enable=0 gtm_white_box_test_case_number= $gtm_dist/mumps -direct >> /dev/null 2>&1
	needsprivroutines=$?
	echo "precheck gtm_dist='$gtm_dist' gtmroutines='$gtmroutines' GTMXC_gpgagent=$GTMXC_gpgagent pinentry=$pinentry needpriv=${needsprivroutines}" >> $gtm_pinentry_log 2>&1

	if [ 0 -ne "${needsprivroutines}" ] ; then
		pinentry=pinentry
		# Need to create a temporary directory for object routines
		if [ -x "`which mktemp 2>/dev/null`" ] ; then
			tmpdir=`mktemp -d`
		else
			tmpdir=/tmp/`basename $0`_$$.tmp ; mkdir $tmpdir
		fi
		trapstr="rm -rf $tmpdir"
		trap "$trapstr" HUP INT QUIT TERM TRAP
		export gtmroutines="$tmpdir($dir $gtm_dist/plugin/gtmcrypt)"
	fi

	echo "env gtm_dist='$gtm_dist' gtmroutines='$gtmroutines' GTMXC_gpgagent=$GTMXC_gpgagent pinentry=$pinentry $gtm_tst/com/pinentry-safe.csh" >> $gtm_pinentry_log 2>&1
	# Call a special script that, depending on the GT.M version, either invokes pinentry.m or
	# follows a simple gpg-agent communication protocol to return the default password.
	gtm_local_collate= LD_PRELOAD= gtm_trace_gbl_name= gtmdbglvl= gtmcompile= gtm_white_box_test_case_enable=0 gtm_white_box_test_case_number= pinentry=$pinentry \
		$gtm_tst/com/pinentry-safe.csh 2>&1 | tee -a $gtm_pinentry_log
	punt=$?
	if [ -d "$tmpdir" ] ; then rm -rf "$tmpdir" ; fi
fi

if [ 0 -ne $punt ] ;then
	echo "Punting: $punt : $$" >> $gtm_pinentry_log 2>&1
	# Punt to the regular pinentry program
	pinentry=`which pinentry 2>/dev/null`
	if [ -x "$pinentry" ] ; then $pinentry $* ; else exit 1 ; fi
fi
