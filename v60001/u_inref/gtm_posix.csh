#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set hostn = "$HOST:r:r:r"

# GTMXC_gtmposix is defined by sourcing /gtc/staff/common/gtm_cshrc.csh as part of login

# When testing changes to the posix routines in $gtm_com/gtmposix you must first run $cms_tools/test_gtmposix.csh as library. That
# script will create $gtm_com/tmp_gtmposix, copy all files from $cms_root/gtmplugins/posix into this directory, copy any files you
# have checked out from tools/gtmplugins/posix into this directory, copy any M files from tools/cms_tools that use the posix plugin
# (such as linerepl.m), and build the posix library there. The following line must be uncommented to point to the test version of
# gtmposix.xc:

#setenv GTMXC_gtmposix $gtm_com/tmp_gtmposix/gtmposix.xc

# linerepl.m, posixtest.m, and _POSIX.m are found in $gtm_com/gtmposix, which is defined in set_gtmroutines.csh. So, the following
# 2 lines must be uncommented to test modification to any of the M routines in $cms_root/gtmplugins/posix:

#set gpos = `echo "$gtmroutines" | sed -e s/gtmposix/tmp_gtmposix/`
#setenv gtmroutines "$gpos"

# create test file for linerepl.m
cat >& tempfile <<EOF
The quick
brown fox
jumps over
the lazy
dog.
EOF

echo "Contents of tempfile:"
cat tempfile
echo
echo "modified by:"
echo '$gtm_exe/mumps -r linerepl --match=/the/ --replace=:A: tempfile'
$gtm_exe/mumps -r linerepl --match=/the/ --replace=:A: tempfile
echo
echo "Contents of tempfile after linerepl change:"
cat tempfile

# need to setup syslog_info for some Linux boxes as rules in posixtest.m have conflicts
if ((jackal == $hostn) || (carmen == $hostn) || (tuatara == $hostn)) setenv syslog_info /var/log/messages

echo ""
echo "Executing posixtest and expect PASS for all"
echo ""

$gtm_exe/mumps -r posixtest
