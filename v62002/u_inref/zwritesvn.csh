#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Add debug build options if the image is dbg
set opts=()
if ($tst_image == "dbg") set opts=($gt_cc_option_debug $gt_cc_option_DDEBUG)

# Compile and link svndump
$gt_cc_compiler $gtt_cc_shl_options $opts $gtm_tst/$tst/inref/svndump.c -o svndump.o -I$gtm_inc >&! compile.out && \
	$gt_ld_linker $gt_ld_options_common -o svndump svndump.o -L$gtm_dist/obj -lmumps -lstub $gt_ld_sysrtns $gt_ld_syslibs >&! link.out
if ( ! -e svndump ) then
	echo "Compilation of svndump failed, exiting"
	exit 0
endif

$echoline
# Generate the MUMPS routine and execute it.
./svndump > isvndump.m

$echoline
# The expectation here is that any error will be caught by the test system's error checking
$gtm_dist/mumps -run isvndump >&! svndump.out
if (0 == $status) then
	echo "TEST-I-PASS"
else
	echo "TEST-F-FAIL"
	cat svndump.out
endif

$echoline
# The expectation here is that any error will be caught by the test system's error checking
# Strip out the intentionally induced zcompile error
$gtm_tst/com/check_error_exist.csh svndump.out FILENOTFND

