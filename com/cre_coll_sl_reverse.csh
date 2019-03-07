#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#create collation shared libraries for a "reverse" sequence ([1-255] -> [255-1])
setenv cur_dir `pwd`
set machine_type = `uname -m`
if ("$gtm_test_osname" == "hp-ux") then
	set is64bit_gtm=`file $gtm_exe/mumps | $grep -c "IA64"`
else if ("$gtm_test_osname" == "os390") then
		set is64bit_gtm = 1
	else
		set is64bit_gtm = `file $gtm_exe/mumps | $grep -c "64-bit"`
	endif
endif

if (("$machine_type" == "x86_64") && ($is64bit_gtm == 0)) then
	setenv  gtt_cc_shl_options      "$gtt_cc_shl_options -m32"
	setenv  gt_ld_options_yottadb   "$gt_ld_options_yottadb -m32"
	setenv  gtt_cc_shl_options      "$gtt_cc_shl_options -m32"
	setenv  gt_ld_shl_options       "$gt_ld_shl_options -m32"
	setenv  gt_ld_options_common    "$gt_ld_options_common -m32"
endif
if (-e $cur_dir/libreverse${gt_ld_shl_suffix}) \rm $cur_dir/libreverse${gt_ld_shl_suffix}
cp $gtm_tst/com/col_reverse.c $cur_dir
# Non-gg setup will have *.h files in $gtm_exe. If so, include it to -I
set incdir = "-I$gtm_inc"
set nonomatch ; set headerfiles = $gtm_exe/*.h ; unset nonomatch
if ("$headerfiles" != "$gtm_exe/*.h") then
	set incdir = "$incdir -I$gtm_exe"
endif
$gt_cc_compiler $gtt_cc_shl_options $incdir $cur_dir/col_reverse.c
$gt_ld_shl_linker ${gt_ld_option_output}$cur_dir/libreverse${gt_ld_shl_suffix} $gt_ld_shl_options $cur_dir/col_reverse.o -lc

set col_n = "gtm_collate_$1"
setenv $col_n "$cur_dir/libreverse${gt_ld_shl_suffix}"
setenv gtm_local_collate $1
