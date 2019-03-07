#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
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
# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv gtm_test_spanreg 0	# The test specifically sets a single global and does backup. Let it be deterministic
# Journaling is turned on explicitly in this test. So let's not randomly enable it in dbcreate.csh
setenv gtm_test_jnl NON_SETJNL
$gtm_tst/com/dbcreate.csh mumps 2
$MUPIP set $tst_jnl_str -reg AREG >&! jnl_on_1.log
$MUPIP set $tst_jnl_str -reg DEFAULT >>&! jnl_on_1.log
$grep "YDB-I-JNLSTATE" jnl_on_1.log |& sort -f
echo "First Journal file names are:"
ls -1 *.mjl*
$GTM << EOF
f i=1:1:100 s ^a(i)=i
h
EOF
#
echo ""
echo "backup_jnl_link: Backup without switching journals:"
echo ""
\mkdir ./bak1
echo "$MUPIP backup * -nonewjnlfiles ./bak1"
$MUPIP backup "*" -nonewjnlfiles ./bak1 |& sort -f
ls -1 *.mjl*
#
echo ""
echo "backup_jnl_link: Backup with switching journals. New ones are linked to previous ones. Default action."
echo ""
\mkdir ./bak2
echo "$MUPIP backup * ./bak2"
$MUPIP backup "*" ./bak2 >&! jnl_on_2.log
$grep -v "YDB-I-JNLCREATE" jnl_on_2.log |& sort -f
$MUPIP journal -show=header -forward mumps.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward a.mjl |& $grep "Prev journal"
#
echo ""
echo "backup_jnl_link: Backup with switching journals. Cut previous journal links:"
echo ""
\mkdir ./bak3
echo "$MUPIP backup * -journal=noprevjnlfile ./bak3"
$MUPIP backup "*" -journal=noprevjnlfile ./bak3 >&! jnl_on_3.log
$grep -v "YDB-I-JNLCREATE" jnl_on_3.log |& sort -f
$MUPIP journal -show=header -forward mumps.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward a.mjl |& $grep "Prev journal"
#

if ("ENCRYPT" == "$test_encryption" ) then
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed 's|dat: "'$cwd'/|dat: "|' ${gtmcrypt_config}.orig > $gtmcrypt_config
	setenv gtmcrypt_config $cwd/gtmcrypt.cfg
endif

echo ""
echo "backup_jnl_link: Backup with journal=off for destinition database"
echo ""
\mkdir ./bak4
$MUPIP backup AREG -journal=off ./bak4 >&! jnl_on_4.log
$grep -v "YDB-I-JNLCREATE" jnl_on_4.log
$MUPIP backup DEFAULT -journal=off ./bak4 >&! jnl_on_5.log
$grep -v "YDB-I-JNLCREATE" jnl_on_5.log
\cp mumps.gld ./bak4
cd ./bak4
$GTM << EOF
set ^a(1)=1
set ^a(2)=2
h
EOF
$DSE d -f |& $grep "Journal State" | sed 's/\(Journal Before imaging\)/\1GTM_TEST_DEBUGINFO/'
cd ..
#
echo ""
echo "backup_jnl_link: Backup with journal=disable -nonewjnlfiles for destinition database"
echo ""
\mkdir ./bak5
$MUPIP backup AREG -journal=disable -nonewjnlfiles ./bak5
$MUPIP backup DEFAULT -journal=disable -nonewjnlfiles ./bak5
\cp mumps.gld ./bak5
cd ./bak5
$GTM << EOF
set ^a(1)=1
set ^b(2)=2
h
EOF
$DSE d -f |& $grep "Journal State"
cd ..
$GTM << EOF
set ^a(1)=3
set ^b(2)=4
h
EOF
#
echo ""
echo "backup_jnl_link: Backup with journal=noprev,disable for destinition database"
echo ""
\mkdir ./bak6
$MUPIP backup AREG -journal=noprev,disable ./bak6 >&! jnl_on_6.log
$grep -v "YDB-I-JNLCREATE" jnl_on_6.log
$MUPIP backup DEFAULT -journal=noprev,disable ./bak6 >&! jnl_on_7.log
$grep -v "YDB-I-JNLCREATE" jnl_on_7.log
$MUPIP journal -show=header -forward mumps.mjl |& $grep "Prev journal"
$MUPIP journal -show=header -forward a.mjl |& $grep "Prev journal"
\cp mumps.gld ./bak6
cd ./bak6
$GTM << EOF
set ^a(1)=1
set ^b(2)=2
h
EOF
$DSE d -f |& $grep "Journal State"
cd ..
$GTM << EOF
set ^a(1)=3
set ^b(2)=4
h
EOF
$gtm_tst/com/dbcheck.csh
