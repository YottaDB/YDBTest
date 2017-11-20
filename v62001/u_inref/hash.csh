#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
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

# Do sanity checks on hash algorithms

# Since we link against the dbg/pro libmumps.a, compile hash.c with the same options.
set opts=()
if ($tst_image == "dbg") set opts=($gt_cc_option_debug $gt_cc_option_DDEBUG)

echo "Compiling Hash Test"
$gt_cc_compiler -o ./hash.o $gtt_cc_shl_options $gt_cc_option_I $opts $gtm_tst/$tst/inref/hash.c
echo "Linking Hash Test"
$gt_ld_linker $gt_ld_option_output ./hash $gt_ld_options_common ./hash.o -L$gtm_dist/obj -lmumps $gt_ld_sysrtns $gt_ld_syslibs >& makeexe.out

echo "Starting Hash Test"
./hash
echo "Done"
