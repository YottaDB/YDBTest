#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# [Mohammad] Modified make_pre_alloc and added max pre_alloc
setenv GTM "$gtm_dist/mumps -direct"
setenv gtm_side_effects 1	# use this test to verify external calls work in standard mode
#	Unix external call mechanism tests.
#
#	Some naming conventions to indicate correspondence between source
#	programs or shell scripts and external call definitions:
#
#		"c"		caret
#		"fcn"		FunCtioN - these tests verify that function
#				return values work as expected
#		"i"		input - refers to argument usage
#		"io"		input/output - refers to argument usage
#		"o"		output - refers to argument usage
#		"old"		"old" types, i.e., arguments and/or return
#				value types are declared in terms of native
#				C types (e.g., "int", "float") rather than
#				in terms of types defined in gtmxc_types.h.
#		"pk"		package
#		"x"		eXternal
#		"xc"		eXternal Call
#
#
#	Verify environment.

if ($HOSTOS == "SunOS") then
	setenv GTMXC_DLL 1
endif

if ( $?gtt_cc_shl_options == "0"  ||  $?gt_ld_shl_options == "0" ) then
	echo ""		# attempt to match first line of expected output so warnings appear at begining of diff file
	echo "xcall-F-noenv, Cannot test external calls; either gtt_cc_shl_options or gt_ld_shl_options is undefined."
	echo "xcall-I-noenv, These should be defined in gtm_env_sp.csh"
	exit
endif
#
#	Test math function calls
# make_math.csh here is modified to check for long entryref's & external calls.
source $gtm_tst/$tst/u_inref/make_math.csh
$GTM <<make_math
Write "Do ^mathtst",!  Do ^mathtst
Halt
make_math
unsetenv GTMXC
#
#	Test function calls and return value mechanism.
source $gtm_tst/$tst/u_inref/make_fcn.csh
$GTM <<xcall_fcn
Write "Do ^xcfcn",!  Do ^xcfcn
Halt
xcall_fcn
unsetenv GTMXC
#
#	Test function calls and return value mechanism.
#	Use old type names for backward compatibility for SCA.
source $gtm_tst/$tst/u_inref/make_fcn_old.csh
$GTM <<xcall_fcn_old
Write "Do ^xcfcn (old type names)",! Do ^xcfcn
Halt
xcall_fcn_old
unsetenv GTMXC
#
# source $gtm_tst/$tst/u_inref/make_oops.csh
# $GTM <<xcall_oops
# Do ^xcoops
# Halt
# xcall_oops
unsetenv GTMXC
#
#	Test caret notation in function invocation.
source $gtm_tst/$tst/u_inref/make_void_caret.csh
$GTM <<xcall_void_caret
Write "Do ^xcvoidc",!  Do ^xcvoidc
Halt
xcall_void_caret
unsetenv GTMXC
#
#	Test caret notation in function invocation.
#	Use old type names for backward compatibility for SCA.
source $gtm_tst/$tst/u_inref/make_void_caret_old.csh
$GTM <<xcall_void_caret_old
Write "Do ^xcvoidc (old type names)",!  Do ^xcvoidc
Halt
xcall_void_caret_old
unsetenv GTMXC
#
#	Test input argument passing.
source $gtm_tst/$tst/u_inref/make_void_i.csh
$GTM <<xcall_i
Write "Do ^xcvoidi",!  Do ^xcvoidi
Halt
xcall_i
unsetenv GTMXC
#
#	Test input argument passing.
#	Use old type names for backward compatibility for SCA.
source $gtm_tst/$tst/u_inref/make_void_i_old.csh
$GTM <<xcall_i_old
Write "Do ^xcvoidi (old type names)",!  Do ^xcvoidi
Halt
xcall_i_old
unsetenv GTMXC
#
#	Test input/output argument passing.
source $gtm_tst/$tst/u_inref/make_void_io.csh
$GTM <<xcall_io
Write "Do ^xcvoidio",!  Do ^xcvoidio
Halt
xcall_io
unsetenv GTMXC
#
#	Test input argument passing.
#	Use old type names for backward compatibility for SCA.
source $gtm_tst/$tst/u_inref/make_void_io_old.csh
$GTM <<xcall_io_old
Write "Do ^xcvoidio (old type names)",!  Do ^xcvoidio
Halt
xcall_io_old
unsetenv GTMXC
#
#	Test output argument passing.
source $gtm_tst/$tst/u_inref/make_void_o.csh
$GTM <<xcall_o
Write "Do ^xcvoido",!  Do ^xcvoido
Halt
xcall_o
unsetenv GTMXC
#
#	Test output argument passing.
#	Use old type names for backward compatibility for SCA.
source $gtm_tst/$tst/u_inref/make_void_o_old.csh
$GTM <<xcall_o_old
Write "Do ^xcvoido (old type names)",!  Do ^xcvoido
Halt
xcall_o_old
unsetenv GTMXC
#
#	Test package notation.
source $gtm_tst/$tst/u_inref/make_void_pk_i.csh
$GTM <<xcall_pk_i
Write "Do ^xcvpki",!  Do ^xcvpki
Halt
xcall_pk_i
unsetenv GTMXC_pk
#
#	Test package notation.
#	Use old type names for backward compatibility for SCA.
source $gtm_tst/$tst/u_inref/make_void_pk_i_old.csh
$GTM <<xcall_pk_i_old
Write "Do ^xcvpki (old type names)",!  Do ^xcvpki
Halt
xcall_pk_i_old
unsetenv GTMXC_pk
#
#	Test multiple arguments (S9703-000413).
source $gtm_tst/$tst/u_inref/make_S000413.csh
$GTM <<xcall_S000413
Write "Do ^S000413 (multiple arguments)",!  Do ^S000413
Halt
xcall_S000413
unsetenv GTMXC
#
#       Test pre-allocation
source $gtm_tst/$tst/u_inref/make_prealloca.csh
$GTM <<xcall_prealloca
Write "Do ^prealloc",!  Do ^prealloc
Halt
xcall_prealloca
#
#       Test maxpre-allocation char *
source $gtm_tst/$tst/u_inref/make_maxprealloc.csh
$GTM <<xcall_prealloca
Write "Do ^maxpreal",!  Do ^maxpreal
Halt
xcall_prealloca
#
#       Test maxpre-allocation string *
source $gtm_tst/$tst/u_inref/make_maxpreallocstr.csh
$GTM <<xcall_prealloca
Write "Do ^maxprealstr",!  Do ^maxprealstr
Halt
xcall_prealloca
#
#       Test timers and other called in functions.
source $gtm_tst/$tst/u_inref/make_callin.csh
$GTM <<xcall_callin
Write "Do ^xccallin",!  Do ^xccallin
Halt
xcall_callin
#
#	Test function calls starting with the '%' character
source $gtm_tst/$tst/u_inref/make_fcn_percent.csh
$GTM <<xcall_fcn_percent
Write "Do ^xcfcnper",!  Do ^xcfcnper
Halt
xcall_fcn_percent
unsetenv GTMXC

source $gtm_tst/$tst/u_inref/make_gtmshlib.csh
$GTM <<xcall_shlib
Write "Do ^xcshlib",!  Do ^xcshlib
Halt
xcall_shlib
unsetenv GTMXC

source $gtm_tst/$tst/u_inref/make_gtmshlib_rtn.csh
$GTM <<xcall_shlib
Write "Do ^xcshlib",!  Do ^xcshlib
Halt
xcall_shlib
unsetenv GTMXC

source $gtm_tst/$tst/u_inref/make_gtmshlib_keyword.csh
$GTM <<xcall_shlib
Write "Do ^xcshlib",!  Do ^xcshlib
Halt
xcall_shlib
unsetenv GTMXC

# Create a database (for incretrap).
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate_skip_args.out
source $gtm_tst/$tst/u_inref/skip_args.csh
# We are skipping the last argument(s) to external routines in this test, so make sure to
# allocate extra backfill full of dead beef :)
if ($?gtmdbglvl) then
	set save_gtmdbglvl=$gtmdbglvl
endif
setenv gtmdbglvl 576
$GTM <<xcall_skip_args
Write "Do ^skipargs",!  Do ^skipargs
Halt
xcall_skip_args
unsetenv GTMXC
unsetenv gtmdbglvl
if ($?save_gtmdbglvl) then
	setenv gtmdbglvl $save_gtmdbglvl
endif
# Verify that the database is OK.
$gtm_tst/com/dbcheck.csh >&! dbcheck_skip_args.out

## TEST FOR UNICODE ENABLED ##
set hostn = $HOST:r:r:r
# Disable unicode_tests.csh on platforms that don't support unicode 5.0 (4 byte unicode chars)
if (("TRUE" == $gtm_test_unicode_support) && ("0" == "$gtm_platform_no_4byte_utf8") && ("aix" != $gtm_test_osname)) then
	source $gtm_tst/$tst/u_inref/unicode_tests.csh >&! unicode_tests.log
	diff $gtm_tst/$tst/outref/unicode_tests.txt unicode_tests.log >&! unicode_tests.diff
	if ($status) then
		echo "TEST-E-UNICODE section of the tests failed"
		echo "Check the output of the section in unicode_tests.log and compare it with $gtm_tst/$tst/outref/unicode_tests.txt"
	else
		echo "TEST-I-PASSED Unicode section of the xcall test"
		mv unicode_tests.log unicode_tests.logx
		$grep -v YDB-E-ZCPREALLVALINV unicode_tests.logx >&! unicode_tests.log
	endif
else
	echo "TEST-I-NOTRUN Unicode section of the xcall test"
endif
##
