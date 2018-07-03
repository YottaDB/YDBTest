#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#
source $gtm_tst/com/copy_ydb_dist_dir.csh ydb_temp_dist
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
cat > trigger.trg << EOF
+^A -command=Set -xecute="write 1,!"
EOF
cat > trigclear.trg << EOF
-^A -command=Set -xecute="write 1,!"
EOF

$MUPIP Trigger -triggerfile=trigger.trg >>& trigger.out
cat > $ydb_dist/restrict.txt<<EOF
BREAK
ZBREAK
ZCMDLINE
ZEDIT
ZSYSTEM
CENABLE
PIPE_OPEN
DIRECT_MODE
DSE
TRIGGER_MOD
EOF
chmod -w $ydb_dist/restrict.txt

cat > dummy.txt <<EOF
Dummy file
EOF

echo "# TESTING EACH FUNCTION RESTRICTED BY RESTRICT.TXT (with readonly permissions)"
echo ""

$gtm_tst/com/lsminusl.csh $ydb_dist/restrict.txt | $tst_awk '{print $1,$9}'
$ydb_dist/mumps -run breakfn^gtm8694
$ydb_dist/mumps -run zbreakfn^gtm8694
$ydb_dist/mumps -run zcmdlnefn^gtm8694 "ZCMDLNE was not ignored"
$ydb_dist/mumps -run zeditfn^gtm8694
$ydb_dist/mumps -run zsystemfn^gtm8694
$ydb_dist/mumps -run pipefn^gtm8694
$ydb_dist/mumps -run trigmodfn^gtm8694
echo "# TESTING DIRECTMODE"
$ydb_dist/mumps -dir
echo "# TESTING DSE"
$ydb_dist/dse
echo ""
rm $ydb_dist/restrict.txt
cat > $ydb_dist/restrict.txt << EOF
CENABLE
EOF
chmod -w  $ydb_dist/restrict.txt
(expect -d $gtm_tst/$tst/u_inref/gtm8694.exp > expect.outx) >& xpect.dbg
if ($status) then
	echo "EXPECT FAILED"
endif
echo "# TESTING CENABLE"
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
cat expect_sanitized.outx |& $grep CTRL
echo ""
echo "# -----------------------------------------------------------------------------"
echo ""
echo "# TESTING EACH FUNCTION WHEN RESTRICT.TXT HAS NO READ OR WRITE PERMISSIONS"
echo ""
# Not testing cenable, since this should restrict direct mode, which is necessary for testing cenable
mv $ydb_dist/restrict.txt $ydb_dist/restrict1.txt
cat > $ydb_dist/restrict.txt << EOF
DIRECT_MODE
EOF
chmod -r -w $ydb_dist/restrict.txt
$gtm_tst/com/lsminusl.csh $ydb_dist/restrict.txt | $tst_awk '{print $1,$9}'
$ydb_dist/mumps -run breakfn^gtm8694
$ydb_dist/mumps -run zbreakfn^gtm8694
$ydb_dist/mumps -run zcmdlnefn^gtm8694 "ZCMDLNE was not ignored"
$ydb_dist/mumps -run zeditfn^gtm8694
$ydb_dist/mumps -run zsystemfn^gtm8694
$ydb_dist/mumps -run pipefn^gtm8694
$ydb_dist/mumps -run trigmodfn^gtm8694
echo "# TESTING DIRECTMODE"
$ydb_dist/mumps -dir
echo "# TESTING DSE"
$ydb_dist/dse
echo ""
echo ""
echo "# ----------------------------------------------------------------------------"
echo ""
echo "# TESTING EACH FUNCTION WHEN RESTRICT.TXT LISTS OUR GROUP NAME (with readonly permissions)"
echo ""
rm $ydb_dist/restrict.txt
set groupname=`id -g -n -r`
echo ""
cat > $ydb_dist/restrict.txt << EOF
BREAK:$groupname
ZBREAK:$groupname
ZCMDLINE:$groupname
ZEDIT:$groupname
ZSYSTEM:$groupname
CENABLE:$groupname
PIPE_OPEN:$groupname
DIRECT_MODE:$groupname
DSE:$groupname
TRIGGER_MOD:$groupname
EOF
chmod -w $ydb_dist/restrict.txt
$gtm_tst/com/lsminusl.csh $ydb_dist/restrict.txt | $tst_awk '{print $1,$9}'
setenv EDITOR ""
$ydb_dist/mumps -run breakfn^gtm8694
$ydb_dist/mumps -run zbreakfn^gtm8694
$ydb_dist/mumps -run zcmdlnefn^gtm8694 "ZCMDLNE was not ignored"
$ydb_dist/mumps -run zeditfn^gtm8694
$ydb_dist/mumps -run zsystemfn^gtm8694
$ydb_dist/mumps -run pipefn^gtm8694
$ydb_dist/mumps -run trigmodfn^gtm8694
echo "# TESTING DIRECTMODE"
$ydb_dist/mumps -dir
echo "# TESTING DSE"
$ydb_dist/dse
echo ""
(expect -d $gtm_tst/$tst/u_inref/gtm8694.exp > expect.outx) >& xpect.dbg
if ($status) then
	echo "EXPECT FAILED"
endif
echo "# TESTING CENABLE"
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
cat expect_sanitized.outx |& $grep CTRL

echo ""
echo "# -------------------------------------------------------------------------"
echo ""
echo "TESTING EACH FUNCTION WHEN RESTRICT.TXT HAS WRITE PERMISSIONS"
echo ""

rm $ydb_dist/restrict.txt
mv $ydb_dist/restrict1.txt $ydb_dist/restrict.txt
chmod +w $ydb_dist/restrict.txt
$MUPIP trigger -triggerfile=trigger.trg >>& trigger.txt
$gtm_tst/com/lsminusl.csh $ydb_dist/restrict.txt | $tst_awk '{print $1,$9}'
$ydb_dist/mumps -run breakfn^gtm8694
$ydb_dist/mumps -run zbreakfn^gtm8694
$ydb_dist/mumps -run zcmdlnefn^gtm8694 "ZCMDLNE was not ignored"
$ydb_dist/mumps -run zeditfn^gtm8694
$ydb_dist/mumps -run zsystemfn^gtm8694
$ydb_dist/mumps -run pipefn^gtm8694
$ydb_dist/mumps -run trigmodfn^gtm8694
echo "# TESTING DIRECTMODE"
$ydb_dist/mumps -dir
echo "# TESTING DSE"
$ydb_dist/dse
echo ""
(expect -d $gtm_tst/$tst/u_inref/gtm8694.exp > expect.outx) >& xpect.dbg
if ($status) then
	echo "EXPECT FAILED"
endif
echo "# TESTING CENABLE"
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
cat expect_sanitized.outx |& $grep CTRL


$gtm_tst/com/dbcheck.csh >>& dbcheck.out
