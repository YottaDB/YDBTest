#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

setenv JAVA_HOME `awk '$0 ~ /^#/ {next;} $1 ~ /^'$HOST:r:r:r'/ {print $10}' $gtm_test_serverconf_file`	# BYPASSOK
if (("NA" == $JAVA_HOME) || ("" == $JAVA_HOME)) then
	echo "Java is not available on this platform, or the installation path is missing in $gtm_test_serverconf_file"
	exit 1
endif

if ("Linux" == $HOSTOS) then
	if (-d $JAVA_HOME/jre/lib/amd64) then
		setenv JAVA_SO_HOME $JAVA_HOME/jre/lib/amd64
		setenv JVM_SO_HOME $JAVA_HOME/jre/lib/amd64/server
	else if (-d $JAVA_HOME/jre/lib/i386) then
		setenv JAVA_SO_HOME $JAVA_HOME/jre/lib/i386
		setenv JVM_SO_HOME $JAVA_HOME/jre/lib/i386/server
	else
		setenv JAVA_SO_HOME $JAVA_HOME/jre/lib/i686
		setenv JVM_SO_HOME $JAVA_HOME/jre/lib/i686/server
	endif
else if ("SunOS" == $HOSTOS) then
	setenv JAVA_SO_HOME $JAVA_HOME/jre/lib/sparcv9
	setenv JVM_SO_HOME $JAVA_HOME/jre/lib/sparcv9/server
else if ("AIX" == $HOSTOS) then
	setenv JAVA_SO_HOME $JAVA_HOME/jre/lib/ppc64
	setenv JVM_SO_HOME $JAVA_HOME/jre/lib/ppc64/j9vm
else
	exit 1
endif

