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
f i=1:1:5 s ^a(i)=i
f i=1:1:5 s ^b(i)=i
h
EOF
#
echo "Enable journaling for mumps.dat with : file=defjnl2.mjl"
$MUPIP set -file $tst_jnl_str,file=defjnl2.mjl mumps.dat >&! jnl_on_2.log
$grep "GTM-I-JNLSTATE" jnl_on_2.log
echo "Enable journaling for a.dat with : file=ajnl2.mjl"
$MUPIP set -file $tst_jnl_str,file=ajnl2.mjl a.dat >&! jnl_on_3.log
$grep "GTM-I-JNLSTATE" jnl_on_3.log
$GTM << EOF
f i=1:1:5 s ^aa(i)=i
f i=1:1:5 s ^bb(i)=i
h
EOF
#
echo "Enable journaling for region DEFAULT with : file=defjnl3.mjl"
$MUPIP set $tst_jnl_str,file=defjnl3.mjl -REG DEFAULT >&! jnl_on_4.log
$grep "GTM-I-JNLSTATE" jnl_on_4.log
echo "Enable journaling for region AREG with : file=ajnl3.mjl"
$MUPIP set $tst_jnl_str,file=ajnl3.mjl -REG AREG >&! jnl_on_5.log
$grep "GTM-I-JNLSTATE" jnl_on_5.log
$GTM << EOF
f i=1:1:5 s ^aaa(i)=i
f i=1:1:5 s ^bbb(i)=i
h
EOF
#
echo "Verify link:"
$MUPIP journal -show=header -forward defjnl3.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward ajnl3.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward defjnl2.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward ajnl2.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward mumps.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward a.mjl |& $grep "Prev journal"
#
$GTM << EOF
f i=1:1:100 s ^aaaa(i)=i
f i=1:1:100 s ^bbbb(i)=i
zsystem "$gtm_exe/mupip set -jnlfile defjnl3.mjl -noprevjnlfile -bypass"
zsystem "$gtm_exe/mupip set -jnlfile ajnl3.mjl -noprevjnlfile -bypass"
h
EOF
echo "Verify link:"
$MUPIP journal -show=header -forward defjnl3.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward ajnl3.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward defjnl2.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward ajnl2.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward mumps.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward a.mjl |& $grep "Prev journal"
$GTM << EOF
f i=1:1:100 s ^aaaaa(i)=i
f i=1:1:100 s ^abbbb(i)=i
zsystem "$gtm_exe/mupip set -jnlfile defjnl3.mjl -prevjnlfile=mumps.mjl -bypass"
zsystem "$gtm_exe/mupip set -jnlfile ajnl3.mjl -prevjnlfile=a.mjl -bypass"
h
EOF
echo "Verify link:"
$MUPIP journal -show=header -forward defjnl3.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward ajnl3.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward defjnl2.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward ajnl2.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward mumps.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward a.mjl |& $grep "Prev journal"
mkdir jnl1.jnl2
set pwd = `pwd`
echo "Enable journaling for mumps.dat with : file=./jnl1.jnl2/jnl1.jnl2"
$MUPIP set -file $tst_jnl_str,file=./jnl1.jnl2/jnl1.jnl2 mumps.dat >&! jnl_on_6.log
$grep -v "GTM-I-JNLCREATE" jnl_on_6.log
echo 'Check the "Prev journal" value in the  journal header'
$MUPIP journal -show=header -forward ./jnl1.jnl2/jnl1.jnl2 |& $grep "Prev journal"
echo "Enable journaling for mumps.dat with : file=./jnl1.jnl2/jnl1.mjl"
$MUPIP set -file $tst_jnl_str,file=./jnl1.jnl2/jnl1.mjl mumps.dat >&! jnl_on_7.log
$grep -v "GTM-I-JNLCREATE" jnl_on_7.log
echo 'Check the "Prev journal" value in the  journal header'
$MUPIP journal -show=header -forward ./jnl1.jnl2/jnl1.mjl |& $grep "Prev journal"
echo "Enable journaling for mumps.dat with : file=$pwd/jnl1.jnl2/jnl1.mjl"
$MUPIP set -file $tst_jnl_str,file=$pwd/jnl1.jnl2/jnl1.mjl mumps.dat >&! jnl_on_8.log
$grep -v "GTM-I-JNLCREATE" jnl_on_8.log
echo 'Check the "Prev journal" value in the  journal header'
$MUPIP journal -show=header -forward $pwd/jnl1.jnl2/jnl1.mjl >>&! jnl_on_9.log
$grep "Prev journal" jnl_on_9.log
$gtm_tst/com/dbcheck.csh
