#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Disable use of V6 mode DBs by using random V6 versions to create DBs as that creates differences in MUPIP INTEG output
setenv gtm_test_use_V6_DBs 0
setenv test_reorg "NON_REORG"
$gtm_tst/com/dbcreate.csh mumps 1 255 1008
echo "Create some *-only blocks"
echo "-------------------------------------------------------------"
echo "                             root                            "
echo "      *              *               *               *       "
echo " reorgvar(77) : reorgvar(177) : reorgvar(266) : reorgvar(267)"
echo "-------------------------------------------------------------"
$GTM << EOF >& /dev/null
S start=0
S end=300
f i=start:1:end S ^reorgvar(i)=\$j(i,990)
f i=end:-1:268 K ^reorgvar(i)
f i=265:-1:178 K ^reorgvar(i)
f i=176:-1:78 K ^reorgvar(i)
f i=76:-1:0 K ^reorgvar(i)
h
EOF
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 63  # WBTEST_REORG_DEBUG
setenv gtm_white_box_test_case_count 1
$MUPIP reorg >& reorg_1.out
sed 's/\(GTMPOOLLIMIT used for mupip reorg :\) '$gtm_poollimit_value'/\1 ##FILTERED##/' reorg_1.out
$MUPIP integ -r "*"
$GTM << EOF
write \$DATA(^reorgvar(77)),\$DATA(^reorgvar(177)),\$DATA(^reorgvar(266)),\$DATA(^reorgvar(267))
halt
EOF
$gtm_tst/com/dbcheck.csh
\rm -rf *.dat
echo "--------------------------------------------------------------"
echo "                             root                             "
echo "   non-*              *               *               *       "
echo "reorgvar(1:77) : reorgvar(177) : reorgvar(266) : reorgvar(267)"
echo "--------------------------------------------------------------"
$gtm_tst/com/dbcreate.csh mumps 1 255 1008
$GTM << EOF >& /dev/null
S start=0
S end=300
f i=start:1:end S ^reorgvar(i)=\$j(i,990)
f i=end:-1:268 K ^reorgvar(i)
f i=265:-1:178 K ^reorgvar(i)
f i=176:-1:78 K ^reorgvar(i)
f i=76:-1:0 K ^reorgvar(i)
f i=76:-1:0 S ^reorgvar(i)=\$j(i,990)
h
EOF
$MUPIP reorg >& reorg_2.out
sed 's/\(GTMPOOLLIMIT used for mupip reorg :\) '$gtm_poollimit_value'/\1 ##FILTERED##/' reorg_2.out
$MUPIP integ -r "*"
$GTM << EOF
write \$DATA(^reorgvar(77)),\$DATA(^reorgvar(177)),\$DATA(^reorgvar(266)),\$DATA(^reorgvar(267))
halt
EOF
$gtm_tst/com/dbcheck.csh
echo "--------------------------------------------------------------"
echo "                             root                             "
echo "   *              non-*               *               *       "
echo "reorgvar(77) :reorgvar(110:177) : reorgvar(266) : reorgvar(267)"
echo "--------------------------------------------------------------"
\rm -rf *.dat
$gtm_tst/com/dbcreate.csh mumps 1 255 1008
$GTM << EOF >& /dev/null
S start=0
S end=300
f i=start:1:end S ^reorgvar(i)=\$j(i,990)
f i=end:-1:268 K ^reorgvar(i)
f i=265:-1:178 K ^reorgvar(i)
f i=176:-1:78 K ^reorgvar(i)
f i=76:-1:0 K ^reorgvar(i)
f i=176:-1:110 S ^reorgvar(i)=\$j(i,990)
h
EOF
$MUPIP reorg >& reorg_3.out
sed 's/\(GTMPOOLLIMIT used for mupip reorg :\) '$gtm_poollimit_value'/\1 ##FILTERED##/' reorg_3.out
$MUPIP integ -r "*"
$GTM << EOF
write \$DATA(^reorgvar(77)),\$DATA(^reorgvar(177)),\$DATA(^reorgvar(266)),\$DATA(^reorgvar(267))
halt
EOF
unsetenv gtm_white_box_test_case_enable
$gtm_tst/com/dbcheck.csh
