#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#!/usr/local/bin/tcsh -f
#
# GTM-7430: MUPIP REORG -select hitting GTMASSERT in COPY_CURRKEY_TO_GVTARGET_CLUE macro.
#

setenv test_reorg NON_REORG
$gtm_tst/com/dbcreate.csh mumps 1

$GTM << EOF
	set ^a=1
	set ^xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx="Mr. X"
	set ^yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy="Mr. Y"
	write \$l("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"),!
EOF

echo "SELECT and EXCLUDE for ^a is fine"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 63  # WBTEST_REORG_DEBUG
setenv gtm_white_box_test_case_count 1
$gtm_exe/mupip reorg -exclude="^a" >& reorg_1.outx
sed 's/\(GTMPOOLLIMIT used for mupip reorg :\) '$gtm_poollimit_value'/\1 ##FILTERED##/' reorg_1.outx
$gtm_exe/mupip reorg -select="^a" >& reorg_2.outx
sed 's/\(GTMPOOLLIMIT used for mupip reorg :\) '$gtm_poollimit_value'/\1 ##FILTERED##/' reorg_2.outx

echo "EXCLUDE is fine... and so is SELECT"
$gtm_exe/mupip reorg -exclude="^xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" >& reorg_3.outx
sed 's/\(GTMPOOLLIMIT used for mupip reorg :\) '$gtm_poollimit_value'/\1 ##FILTERED##/' reorg_3.outx
$gtm_exe/mupip reorg -select ="^xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" >& reorg_4.outx
sed 's/\(GTMPOOLLIMIT used for mupip reorg :\) '$gtm_poollimit_value'/\1 ##FILTERED##/' reorg_4.outx
unsetenv gtm_white_box_test_case_enable
$gtm_tst/com/dbcheck.csh
