#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script sets JAVA_HOME, JAVA_SO_HOME, and JVM_SO_HOME environment variables to reflect the paths to
# the JDK installation, libjava.so, and libjvm.so. The purpose is to provide an easy way for YottaDB tests
# (by sourcing this script) to set up environment for Java call-ins and call-outs.

set curdir = $PWD
setenv JAVA_HOME `$tst_awk '$1 == "'$HOST:ar'" {print $10}' $gtm_test_serverconf_file`
if ("NA" == $JAVA_HOME) then
	# Check if /usr/lib/jvm/* directory can be found such that it contains libjava.so. If so use that.
	# There might be multiple versions. In that case, choose the last one (hopefully the latest in terms of version)
	foreach jvmdir (/usr/lib/jvm /usr/lib64/jvm)
		if (! -e $jvmdir) then
			continue
		endif
		setenv JAVA_HOME ""	# set to default value to be overridden below
		if (-e $jvmdir) then
			cd $jvmdir
			set javasohome = `find . -name libjava.so |& grep libjava.so | tail -1`
			cd -
			if ("$javasohome " != "") then
				setenv JAVA_HOME $jvmdir/`echo $javasohome | sed 's,^./,,g;s,/.*,,g'`
			endif
		endif
	end
endif
if ("" == $JAVA_HOME) then
	echo "TEST-E-FAIL : Java is not available on this platform, or the installation path is missing in $gtm_test_serverconf_file"
	cd $curdir
	exit 1
endif

if ("Linux" == $HOSTOS) then
	cd $JAVA_HOME
	set javasohome = `find . -name libjava.so |& grep libjava.so | tail -1`
	if ($javasohome == "") then
		setenv JAVA_SO_HOME ""
		echo "TEST-E-FAIL : Could not set JAVA_SO_HOME to a non-null file path"
	else
		setenv JAVA_SO_HOME $JAVA_HOME/${javasohome:h}
	endif
	set jvmsohome = `find . -name libjvm.so |& grep libjvm.so | tail -1`
	if ($jvmsohome == "") then
		setenv JVM_SO_HOME ""
		echo "TEST-E-FAIL : Could not set JVM_SO_HOME to a non-null file path"
	else
		setenv JVM_SO_HOME $JAVA_HOME/${jvmsohome:h}
	endif
	cd -
else
	cd $curdir
	exit 1
endif

cd $curdir
