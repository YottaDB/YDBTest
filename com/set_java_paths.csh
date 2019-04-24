#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script sets JAVA_HOME, JAVA_SO_HOME, and JVM_SO_HOME environment variables to reflect the paths to
# the JDK installation, libjava.so, and libjvm.so. The purpose is to provide an easy way for GT.M tests
# (by sourcing this script) to set up environment for Java call-ins and call-outs.

setenv JAVA_HOME `$tst_awk '$1 == "'$HOST:ar'" {print $10}' $gtm_test_serverconf_file`
if ("NA" == $JAVA_HOME) then
	# Check if /usr/lib/jvm/*/jre directory can be found. If so use that.
	set nonomatch = 1 ; set jrelist = /usr/lib/jvm/*/jre; unset nonomatch
	if ("$jrelist" != '/usr/lib/jvm/*/jre') then
		# There might be multiple versions. In that case, choose the last one (hopefully the latest in terms of version)
		setenv JAVA_HOME $jrelist[$#jrelist]:h
	else
		setenv JAVA_HOME ""
	endif
endif
if ("" == $JAVA_HOME) then
	echo "Java is not available on this platform, or the installation path is missing in $gtm_test_serverconf_file"
	exit 1
endif

if ("Linux" == $HOSTOS) then
	cd $JAVA_HOME
	set javasodir = `find . -name libjava.so`
	if ($javasodir == "") then
		setenv JAVA_SO_HOME ""
		echo "TEST-E-FAIL : Could not set JAVA_SO_HOME to a non-null file path"
	else
		setenv JAVA_SO_HOME $JAVA_HOME/${javasodir:h}
	endif
	set jvmsodir = `find . -name libjvm.so`
	if ($jvmsodir == "") then
		setenv JVM_SO_HOME ""
		echo "TEST-E-FAIL : Could not set JVM_SO_HOME to a non-null file path"
	else
		setenv JVM_SO_HOME $JAVA_HOME/${jvmsodir:h}
	endif
	cd -
else
	exit 1
endif

