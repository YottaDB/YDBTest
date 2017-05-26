#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# view "TRACE" is done in test mprof/instream.csh/com
# view "NOISOLATOIN" is tested in imptp.m
# view "GVDUPSETNOOP" is tested in v44004/C9D12002472_1
# view "JOBPID" does not work for now, should be added later
# view "GDSCERT" is tested in met/inref/mettest.m, tp/inref/tpset*.m and resil, which uses dbfill.m
#
# test VIEW commands
#
$gtm_tst/com/dbcreate.csh .
echo "*********************************"
echo "test view LVNULLSUBS"
echo "----------------------------------"
$GTM << EOF
do lvnull^viewnull
do nolvnull^viewnull
halt
EOF
#
echo "*********************************"
echo "test view LABELS"
echo "----------------------------------"
echo "DEFAULT"
rm *.o
$GTM << EOF
do ^viewlab
halt
EOF
echo "----------------------------------"
echo "UPPER - i.e. disable case sensitivity"
rm *.o
$GTM << EOF
view "LABELS":"UPPER"
do ^viewlab
halt
EOF
echo "----------------------------------"
echo "LOWER - i.e. enable case sensitivity"
rm *.o
$GTM << EOF
view "LABELS":"LOWER"
do ^viewlab
halt
EOF
echo "*********************************"
echo "test view JNLERROR"
echo "----------------------------------"
echo "DEFAULT"
rm *.o
$GTM << EOF
view "JNLERROR":0
write \$VIEW("JNLERROR")
EOF
echo "----------------------------------"
echo "RTSERROR"
$GTM << EOF
view "JNLERROR":1
write \$VIEW("JNLERROR")
EOF
#
# turn on NULLSUBS as the following UNDEF test case sets globals with nullsubs
#
$DSE << EOF
change -file -null=TRUE
EOF

echo "*********************************"
echo "test view UNDEF"
echo "----------------------------------"
$GTM << EOF
 do ^viewunde
 halt
EOF

echo "*********************************"
echo "test view NOISOLATION:^"
echo "----------------------------------"
$GTM << EOF
set a="+"
view "NOISOLATION":a
set a="-"
view "NOISOLATION":a
halt
EOF
$gtm_tst/com/dbcheck.csh
