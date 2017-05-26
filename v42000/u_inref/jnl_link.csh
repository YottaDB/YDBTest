#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#! **** Light form of Journal test ***
#
unsetenv test_replic
# Journaling is turned on explicitly in this test. So let's not randomly enable it in dbcreate.csh
setenv gtm_test_jnl NON_SETJNL
$gtm_tst/com/dbcreate.csh mumps 2
$MUPIP set $tst_jnl_str -reg AREG >&! jnl_on_1.log
$MUPIP set $tst_jnl_str -reg DEFAULT >>&! jnl_on_1.log
$grep "GTM-I-JNLSTATE" jnl_on_1.log |& sort -f
echo "First Journal file names are:"
ls -1 *.mjl*
$GTM << EOF
f i=1:1:100 s ^a(i)=i
h
EOF
#
echo "Enable journaling for mumps.dat with : file=jnl1.mjl"
$MUPIP set -file $tst_jnl_str,file=jnl1.mjl mumps.dat >&! jnl_on_2.log
$grep "GTM-I-JNLSTATE" jnl_on_2.log
$GTM << EOF
f i=1:1:100 s ^b(i)=i
h
EOF
#
echo "Enable journaling for region DEFAULT with : file=jnl2.mjl"
$MUPIP set $tst_jnl_str,file=jnl2.mjl -REG DEFAULT >&! jnl_on_3.log
$grep "GTM-I-JNLSTATE" jnl_on_3.log
$GTM << EOF
f i=1:1:100 s ^c(i)=i
h
EOF
#
echo "Verify link jnl2.mjl -> jnl1.mjl -> mumps.mjl"
$MUPIP journal -show=header -forward jnl2.mjl |& grep "Prev journal"
$MUPIP journal -show=header -forward jnl1.mjl |& grep "Prev journal"
$MUPIP journal -show=header -forward mumps.mjl |& grep "Prev journal"
#
echo "Testing cutting previous link:"
\rm -f *.mjl*
echo "Enable journaling for region DEFAULT"
$MUPIP set $tst_jnl_str -REG DEFAULT >&! jnl_on_3.log
$grep -v "GTM-I-JNLCREATE" jnl_on_3.log
echo "Verify link jnl2.mjl -> NULL"
$MUPIP journal -show=header -forward jnl2.mjl |& grep "Prev journal"
$DSE d -f |& grep "Journal File" | cut -f 2 -d :
###
echo "TESTING AREG"
$MUPIP set -file $tst_jnl_str,file=a1.mjl a.dat >&! jnl_on_4.log
$MUPIP set -file $tst_jnl_str,file=a2.mjl a.dat >>&! jnl_on_4.log
$MUPIP set -file $tst_jnl_str,file=a3.mjl a.dat >>&! jnl_on_4.log
$grep -v "GTM-I-JNLCREATE" jnl_on_4.log
echo "Link a3.mjl - > a2.mjl -> a1.mjl"
$DSE d -f |& grep "Journal File" | cut -f 2 -d :
$MUPIP journal -show=header -forward a3.mjl |& grep "Prev journal"
$MUPIP journal -show=header -forward a2.mjl |& grep "Prev journal"
$MUPIP journal -show=header -forward a1.mjl |& grep "Prev journal"
#
echo ""
echo "================================================="
echo ""
$MUPIP set -jnlfile a3.mjl -prevjnlfile=a1.mjl
echo "Link a3.mjl - > a1.mjl "
$MUPIP journal -show=header -forward a3.mjl |& grep "Prev journal" >& tmp5.out
grep "a1.mjl" tmp5.out
if ($status) then
	echo "FAILED in jnlfile link test in prevjnl option"
	exit
endif
$DSE d -f |& grep "Journal File" | cut -f 2 -d :
#
$MUPIP set -jnlfile a3.mjl -prevjnlfile=noexists.mjl
echo "Link a3.mjl - > noexists.mjl"
$MUPIP journal -show=header -forward a3.mjl |& grep "Prev journal" >& tmp6.out
grep "noexists.mjl" tmp6.out
if ($status) then
	echo "FAILED in jnlfile link test in prevjnl option for noexists.mjl"
	exit
endif
$DSE d -f |& grep "Journal File" | cut -f 2 -d :
#
$gtm_tst/com/dbcheck.csh
