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

#####################
#Collation setup
if ($test_collation == "COLLATION") then
	if ($test_collation_value == "default") then
		# means use default collation
		setenv test_collation_no 1
		setenv test_collation_def_file $gtm_tst/com/polish.c
	endif
endif
if ($test_collation_value != "default") then
	setenv test_collation "COLLATION"
	setenv test_collation_no `echo $test_collation_value | sed 's/,.*//g'`
	setenv test_collation_def_file `echo $test_collation_value | sed 's/.*,//g'`
endif

if ($test_collation == "COLLATION") then
	if (! -f $test_collation_def_file) then
		if (! $?test_collation_submit_dir) setenv test_collation_submit_dir "/"
		if (-f $test_collation_submit_dir/$test_collation_def_file) then
			# was not given as absolute path
			setenv test_collation_def_file  $test_collation_submit_dir/$test_collation_def_file
		else
			echo "TEST-E-COLLATION Collation routines not found. Make sure the file $test_collation_def_file exists (or $test_collation_submit_dir/$test_collation_def_file)." >! $tst_working_dir/collation.log
			echo "TEST-W-COLLATIONUNDEF Continuing test with DEFAULT collation " >> $tst_working_dir/collation.log
			setenv test_collation_no 0
			setenv test_collation_def_file "NON_COLL_no_such_file"
		endif
	endif
	if (-f $test_collation_def_file) then
		setenv test_collation_def_c `basename $test_collation_def_file`
		setenv test_collation_def_base `echo  $test_collation_def_c | sed  's/\..*//g'`
		cp $test_collation_def_file `pwd`
                $gt_cc_compiler $gtt_cc_shl_options -I$gtm_inc $test_collation_def_c >>&! collation.log
		if ($status) echo "TEST-E-COLL_CC Error from Compiler ($gt_cc_compiler)" >>&! collation.log
		\rm -f lib${test_collation_def_base}${gt_ld_shl_suffix}
                $gt_ld_shl_linker ${gt_ld_option_output}lib${test_collation_def_base}${gt_ld_shl_suffix} $gt_ld_shl_options $test_collation_def_base.o -lc >>&! collation.log
		if ($status) echo "TEST-E-COLL_CC Error from Linker ($gt_ld_shl_linker)" >>&! collation.log
		setenv gtm_collate_$test_collation_no  "`pwd`/lib${test_collation_def_base}${gt_ld_shl_suffix}"
		setenv gtm_local_collate $test_collation_no
	endif
endif

