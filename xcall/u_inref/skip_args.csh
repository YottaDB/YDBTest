#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
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

# This test verifies that arguments skipped in external calls are nullified.

$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/skip_args.c -g
$gt_ld_shl_linker ${gt_ld_option_output}libskipargs${gt_ld_shl_suffix} $gt_ld_shl_options skip_args.o $gt_ld_syslibs

setenv GTMXC skip_args.tab
echo "`pwd`/libskipargs${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
testInt:	void testInt(I:gtm_int_t,IO:gtm_int_t,I:gtm_int_t)
testLong:	void testLong(I:gtm_int_t,O:gtm_long_t)
testIntStar:	void testIntStar(I:gtm_double_t *,IO:gtm_int_t *)
testLongStar:	void testLongStar(I:gtm_int_t,O:gtm_int_t,O:gtm_long_t *)
testFloatStar:	void testFloatStar(I:gtm_int_t,I:gtm_char_t *,I:gtm_float_t *,O:gtm_float_t *,IO:gtm_float_t *)
testDoubleStar:	void testDoubleStar(I:gtm_int_t,IO:gtm_double_t *)
testCharStar:	void testCharStar(I:gtm_int_t,IO:gtm_char_t **,I:gtm_int_t,IO:gtm_char_t *)
testString:	void testString(I:gtm_string_t *,IO:gtm_string_t *,O:gtm_string_t * [8])
xx
