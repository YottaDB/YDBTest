#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# This test exists to verify that the process listing uses the PATH of
# $gtm_dist even when $gtm_dist has a symlink to the real path of $gtm_dist
#


# WARNING: This test can fail on Solaris because the process listing is limited
# in length. If the path to PWD is too long, the AWK script below does not
# work.

set uniquepath=/tmp/__${user}_${test_subtest_name}_$$
# Create a symlink to $gtm_dist in PWD
ln -s $gtm_dist $uniquepath

# setenv the error message to a) prevent the error message from showing up in
# the PS listing and b) reduce the XCMD line length
setenv testfail "TEST-F-FAIL: wait expired"

# Execute MUMPS via the gtm_dist symlink using the JOB command to execute %XCMD
# doing a process listing while both parent and child are alive.
env gtm_dist=$uniquepath $uniquepath/mumps -run %XCMD \
	'job ^%XCMD:(output="_XCMD.mjx":cmdline="zsystem ""$ps""") for i=1:1:120 quit:$zsigproc($zjob,0)  write:i=120 $ztrnlnm("testfail"),! hang 0.25'

# Dump the paths
grep 'zsystem .*"$ps"' _XCMD.mjx | $tst_awk '{sub(/^.* \//,"/");sub(pwd,"/tmp/MASKED",$1);print $0}' pwd=${uniquepath}

# Delete the symlink
rm $uniquepath

