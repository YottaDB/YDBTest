#!/usr/local/bin/tcsh -f
#################################################################
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
#
# Use SimpleThreadAPI to find the frequency of words in an input text file
#

$gtm_tst/com/dbcreate.csh mumps 1

set file = "wordfreq.c"
cp $gtm_tst/$tst/inref/$file .

echo " --> Running $file <---"
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
	echo "WORDFREQ-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	exit -1
endif
`pwd`/$exefile < $gtm_tst/$tst/outref/wordfreq_input.txt >& wordfreq.out
echo "# Running : diff $gtm_tst/$tst/outref/wordfreq_output.txt wordfreq.out"
diff $gtm_tst/$tst/outref/wordfreq_output.txt wordfreq.out
if ($status) then
	echo "WORDFREQ-E-FAIL : diff failed"
else
	echo "  --> PASS from wordfreq"
endif
echo ""

$gtm_tst/com/dbcheck.csh
