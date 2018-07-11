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
# Not including CENABLE in this list because of logistics reasons
echo "BREAK ZBREAK ZCMDLINE ZEDIT ZSYSTEM PIPE_OPEN DIRECT_MODE DSE TRIGGER_MOD">restrictlist.txt
chmod -w $ydb_dist/restrict.txt

cat > dummy.txt <<EOF
Dummy file
EOF

echo "# TESTING EACH FUNCTION RESTRICTED BY RESTRICT.TXT (with readonly permissions)"
echo ""

$gtm_tst/com/lsminusl.csh $ydb_dist/restrict.txt | $tst_awk '{print $1,$9}'
$ydb_dist/mumps -run breakfn^gtm8694 >& restrictedBREAK.txt
cat restrictedBREAK.txt
$ydb_dist/mumps -run zbreakfn^gtm8694 >& restrictedZBREAK.txt
cat restrictedZBREAK.txt
$ydb_dist/mumps -run zcmdlnefn^gtm8694 "ZCMDLNE was not ignored" >& restrictedZCMDLINE.txt
cat restrictedZCMDLINE.txt
$ydb_dist/mumps -run zeditfn^gtm8694 >& restrictedZEDIT.txt
cat restrictedZEDIT.txt
$ydb_dist/mumps -run zsystemfn^gtm8694 >& restrictedZSYSTEM.txt
cat restrictedZSYSTEM.txt
$ydb_dist/mumps -run pipefn^gtm8694 >& restrictedPIPE_OPEN.txt
cat restrictedPIPE_OPEN.txt
$ydb_dist/mumps -run trigmodfn^gtm8694 >& restrictedTRIGGER_MOD.txt
cat restrictedTRIGGER_MOD.txt
echo "# TESTING DIRECTMODE"
$ydb_dist/mumps -dir >& restrictedDIRECT_MODE.txt
cat restrictedDIRECT_MODE.txt
echo "# TESTING DSE"
$ydb_dist/dse >& restrictedDSE.txt
cat restrictedDSE.txt
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
cat expect_sanitized.outx |& $grep CTRL >& restrictedcenable.txt
cat restrictedcenable.txt
echo ""
echo "# -----------------------------------------------------------------------------"
echo ""
echo "# TESTING EACH FUNCTION WHEN RESTRICT.TXT HAS NO READ OR WRITE PERMISSIONS"
echo ""
echo "# Not testing cenable, since this should restrict direct mode, which is necessary for testing cenable"
echo "# Randomly choosing what is listed as restricted, since everything should get restricted regardless"
rm $ydb_dist/restrict.txt
$ydb_dist/mumps -run randrestrict^gtm8694
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
setenv groupname `id -g -n -r`
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
set sedpath=`which sed`
setenv EDITOR $sedpath
$ydb_dist/mumps -run breakfn^gtm8694 >& unrestrictedBREAK.txt
cat unrestrictedBREAK.txt
$ydb_dist/mumps -run zbreakfn^gtm8694 >& unrestrictedZBREAK.txt
cat unrestrictedZBREAK.txt
$ydb_dist/mumps -run zcmdlnefn^gtm8694 "ZCMDLNE was not ignored" >& unrestrictedZCMDLINE.txt
cat unrestrictedZCMDLINE.txt
echo "# TESTING ZEDIT"
$ydb_dist/mumps -run zeditfn^gtm8694 >& unrestrictedZEDIT.txt
if ("" == `$grep RESTRICTEDOP unrestrictedZEDIT.txt`) then
	echo "ZEDIT not ignored"
else
	$grep RESTRICTEDOP unrestrictedZEDIT.txt
endif
$ydb_dist/mumps -run zsystemfn^gtm8694 >& unrestrictedZSYSTEM.txt
cat unrestrictedZSYSTEM.txt
$ydb_dist/mumps -run pipefn^gtm8694 >& unrestrictedPIPE_OPEN.txt
cat unrestrictedPIPE_OPEN.txt
$ydb_dist/mumps -run trigmodfn^gtm8694 >& unrestrictedTRIGGER_MOD.txt
cat unrestrictedTRIGGER_MOD.txt
echo "# TESTING DIRECTMODE"
$ydb_dist/mumps -dir >& unrestrictedDIRECT_MODE.txt
cat unrestrictedDIRECT_MODE.txt
echo "# TESTING DSE"
$ydb_dist/dse >& unrestrictedDSE.txt
cat unrestrictedDSE.txt
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
echo "# TESTING EACH FUNCTION WHEN RESTRICT.TXT HAS WRITE PERMISSIONS"
echo "# Randomly choosing what gets restricted, since nothing should end up restricted"
echo ""

rm $ydb_dist/restrict.txt
$ydb_dist/mumps -run randrestrict^gtm8694
chmod +w $ydb_dist/restrict.txt
$MUPIP trigger -triggerfile=trigger.trg >>& trigger.txt
$gtm_tst/com/lsminusl.csh $ydb_dist/restrict.txt | $tst_awk '{print $1,$9}'
$ydb_dist/mumps -run breakfn^gtm8694
$ydb_dist/mumps -run zbreakfn^gtm8694
$ydb_dist/mumps -run zcmdlnefn^gtm8694 "ZCMDLNE was not ignored"
$ydb_dist/mumps -run zeditfn^gtm8694 >>& zeditoutput.out
echo "# TESTING ZEDIT"
if ("" == `$grep RESTRICTEDOP zeditoutput.out`) then
	echo "ZEDIT not ignored"
else
	$grep RESTRICTEDOP zeditoutput.out
endif
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
echo "# -----------------------------------------------------------------------"
echo ""
echo "TESTING EACH FUNCTION WHEN ALL ARE INCLUDED IN RESTRICT.TXT AND SOME ARE RANDOMLY ASSIGNED TO OUR GROUP (with read only permissions)"
echo ""
rm $ydb_dist/restrict.txt
$ydb_dist/mumps -run randrestrictgroup^gtm8694
chmod -w $ydb_dist/restrict.txt
$MUPIP trigger -triggerfile=trigger.trg >>& trigger.txt
$gtm_tst/com/lsminusl.csh $ydb_dist/restrict.txt | $tst_awk '{print $1,$9}'
$ydb_dist/mumps -run breakfn^gtm8694 >& BREAK.outx
$ydb_dist/mumps -run zbreakfn^gtm8694 >& ZBREAK.outx
$ydb_dist/mumps -run zcmdlnefn^gtm8694 "ZCMDLNE was not ignored" >& ZCMDLINE.outx
$ydb_dist/mumps -run zeditfn^gtm8694 >& ZEDIT.outx
$ydb_dist/mumps -run zsystemfn^gtm8694 >& ZSYSTEM.outx
$ydb_dist/mumps -run pipefn^gtm8694 >& PIPE_OPEN.outx
$ydb_dist/mumps -run trigmodfn^gtm8694 >& TRIGGER_MOD.outx
$ydb_dist/mumps -dir >& DIRECT_MODE.outx
$ydb_dist/dse >& DSE.outx
foreach restrict (`cat restrictlist.txt`)
	if ("" == `$grep -w $restrict $ydb_dist/restrict.txt |& $grep $groupname`) then
		if ("" != `diff $restrict.outx restricted$restrict.txt`) then
			echo "RESTRICTED"
			echo $restrict
			echo "FAILED"
			diff $restrict.outx restricted$restrict.txt
		else
			echo "$restrict acted as expected"
		endif
	else
		if ("" != `diff $restrict.outx unrestricted$restrict.txt`) then
			echo "UNRESTRICTED"
			echo $restrict
			echo "FAILED"
			diff $restrict.outx unrestricted$restrict.txt
		else
			echo "$restrict acted as expected"
		endif
	endif
end

$gtm_tst/com/dbcheck.csh >>& dbcheck.out
