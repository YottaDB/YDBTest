#!/usr/local/bin/tcsh -f
#################################################################
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

unsetenv gtmdbglvl # or else test runs for too long

echo "Create database using maximum keysize of ~1K and record size = 4K"
$gtm_tst/com/dbcreate.csh mumps -key_size=1019 -record_size=4096
echo "Allow null subscripts in database since randomly generated subscripts could be null"
$gtm_dist/dse change -file -null=TRUE >& dse_change.out

#
# Stress test of ALL ydb_*_s() functions in the simpleAPI
#
cat > stresstest.xc << CAT_EOF
driveZWRITE: void ^driveZWRITE(I:ydb_string_t *)
gvnZWRITE: void ^gvnZWRITE()
CAT_EOF

setenv GTMCI stresstest.xc	# needed to invoke driveZWRITE.m from stresstest.c below

echo "Prepare stresstest executable from stresstest.c"
set file = "stresstest.c"
cp $gtm_tst/$tst/inref/$file .
echo " --> Running $file <---"
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
	echo "LVNSET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	continue
endif
mv $exefile.o $exefile.c.o	# move it away for the M program (of the same name) to be compiled and a .o created
				# or else an INVOBJFILE error would be issued (due to unexpected format)

echo "Run stresstest.m (will talk to stresstest.c and generate genstresstest.m and genstresstest.cmp)"
$gtm_dist/mumps -run stresstest

echo "Run genstresstest.m to generate genstresstest.log"
$gtm_dist/mumps -run genstresstest >& genstresstest.cmp

set exefile=genstresstest
mv $exefile.log $exefile.log_unfiltered
grep -v zwrarg $exefile.log_unfiltered > $exefile.log
diff $exefile.{cmp,log} >& $exefile.diff
echo "Verify operations done through the simpleAPI by the C program against the same operations done by an M program"
if ($status) then
	echo "STRESSTEST-E-FAIL : diff $exefile.cmp $exefile.log returned non-zero status. See $exefile.diff for details"
else
	echo "PASS from stresstest"
endif

$gtm_tst/com/dbcheck.csh
