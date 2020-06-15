#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test that buffered IO writes inside external call are flushed when YottaDB process output is piped."
echo "# Invoking command --> yottadb -run ydb589 | tee"
echo '# We expect "Hello, world!" written in external call (in ydb589) to be flushed and seen in output.'
echo "# Without the fix to YDB#589, this output would not be seen."
#
# external call to C from M
#
set file = "ydb589"
setenv ydb_xc_c ${file}.xc
echo "`pwd`/lib${file}${gt_ld_shl_suffix}" > $ydb_xc_c
cat >> $ydb_xc_c << xxx
helloworld: void hello_world()
xxx

# Compile C file and make it a .so file
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/${file}.c
$gt_ld_shl_linker ${gt_ld_option_output}lib${file}${gt_ld_shl_suffix} $gt_ld_shl_options $file.o $gt_ld_syslibs

# Call the M code
cp $gtm_tst/$tst/inref/${file}.m .
$ydb_dist/yottadb ${file}.m	# needed since both .m and .c files write to the same .o file
$ydb_dist/yottadb -run ${file} | tee duplicate.out

