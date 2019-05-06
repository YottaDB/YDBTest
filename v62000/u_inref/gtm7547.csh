#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
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
# Verify $etrap retains the same value when new'ed. Verify call-in functions respect etrap when it is set by the gtm_etrap environment variable

$gtm_exe/mumps -run gtm7547a^gtm7547
# Check the other aspects of NEW and SET
$gtm_exe/mumps -run gtm7547b^gtm7547
$gtm_exe/mumps -run gtm7547c^gtm7547
$gtm_exe/mumps -run gtm7547d^gtm7547

# Verify call-ins respect $gtm_etrap
setenv GTMCI ctom.tab
cat >> $GTMCI << EOF
callin:  void callin^gtm7547()
EOF

# Options to record Load Path in executables. Similar options needed for OS390 platform
if (( $HOSTOS == "OSF1") || ($HOSTOS == "Linux") || ($HOSTOS =~ "CYGWIN*")) then
    setenv ci_ldpath "-Wl,-rpath,"
else if ( $HOSTOS == "HP-UX" ) then
    setenv ci_ldpath "+b "
else if ( $HOSTOS == "AIX" ) then
    setenv ci_ldpath "-L "
else if ( $HOSTOS == "SunOS" ) then
    setenv ci_ldpath "-R "
else if ( $HOSTOS == "OS/390" ) then
    # Hijacking ci_ldpath to add -L$gtm_obj for -lascii (nee -lgtmzos)
    # -blibpath does not work, leaving it in for now
    setenv ci_ldpath "-L$gtm_obj -blibpath"
endif
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/callinerr.c -I$gtm_dist
$gt_ld_linker $gt_ld_option_output callinerr $gt_ld_options_common callinerr.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking callinerr.o failed. See below output (also in link.map)"
	cat link.map
	exit -1
endif

setenv gtm_etrap 'write "callin PASS!",!'
`pwd`/callinerr
