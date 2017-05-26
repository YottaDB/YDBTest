#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# MUPIP JOURNAL -EXTRACT -GLOBAL works incorrectly if string subscript has embedded double-quotes and * is used

cat << cat_eof >&! gtm7769.m
        set ^GBL(1,"TMP")=2
        set ^GBL(1,"TMP",3)=3
        set ^GBL(1,"TMP""")=4
        set ^GBL(1,"TMP""",5)=5
        set ^GBL(1,"TMP""""")=6
        set ^GBL(1,"TMP""""",7)=7
        set ^GBL(1,"TMP""x")=8
        set ^GBL(1,"TMP""x",9)=9
cat_eof

$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set $tst_jnl_str -region "*" >&! jnlon.out

$gtm_exe/mumps -run gtm7769

echo '# journal exract -global=\"^GBL\(1,\"\"TMP\"\"\"\"\*\"\"\)\"'
$MUPIP journal -extract -global=\"^GBL\(1,\"\"TMP\"\"\"\"\*\"\"\)\" -forward mumps.mjl >&! jnlextract1.out
$grep JNLSUCCESS jnlextract1.out
echo '# expect globals with values 4, 6 and 8'
$tst_awk -F \\ '/GBL/ {print $NF}' mumps.mjf

echo 'journal -extract -global=\"^GBL\(1,\"\"TMP\"\"\"\"\*\"\",\*\)\"'
$MUPIP journal -extract -global=\"^GBL\(1,\"\"TMP\"\"\"\"\*\"\",\*\)\" -forward mumps.mjl >&! jnlextract2.out
$grep JNLSUCCESS jnlextract2.out
echo '# expect globals with values 5, 7 and 9'
$tst_awk -F \\ '/GBL/ {print $NF}' mumps.mjf

$gtm_tst/com/dbcheck.csh
