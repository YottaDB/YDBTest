#################################################################
#								#
# Copyright 2013, 2014 Fidelity Information Services, Inc	#
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
#       gtm6548c.csh - setup for testing job command through callins

$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/jobcmd.c -I$gtm_dist
$gt_ld_linker $gt_ld_option_output jobcmd $gt_ld_options_common jobcmd.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map

if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map

setenv  GTMCI  jobcmd.tab
cat >> $GTMCI << EOF
jobmumps:	void jobmumps^jobmumps()
EOF

mkdir case1 case2 case3 case4
touch input.mji
touch case2/input.mji
touch case3/input.mji
touch case4/input.mji
jobcmd
unsetenv $GTMCI
echo
if ((-f \*.mjo\*) || (-f \*.mje\*)) then
	echo "TEST-E-FAIL: Job command has created Std Output/Error files in working diretory of parent process."
else
	echo "TEST-E-SUCCESS: Standard Output and Error files are created at proper location in all test cases."
endif
