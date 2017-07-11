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

###########################################################################

set JNL_EXT_MAX=1073741823
set JNL_EXT_MAX_PLUS_ONE=1073741824

setenv gtm_test_mupip_set_version "V5"
setenv gtm_test_jnl NON_SETJNL

###########################################################################
if ($gtm_test_jnl_nobefore) then
	# nobefore image randomly chosen
	set b4nob4image = "nobefore"
else
	# before image randomly chosen
	set b4nob4image = "before"
endif


echo ""
echo "Test GLD upgrade"
echo "================"

mkdir upgradegld
cd upgradegld

set prior_ver = `$gtm_tst/com/random_ver.csh -type "gld_mismatch"`
if ("$prior_ver" =~ "*-E-*") then
        echo "No prior versions available: $prior_ver"
        exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
echo "$prior_ver" > priorver.txt
\rm -f *.o >& rm1.out	# remove .o files created by current version (in case the format is different)

echo "Randomly chosen prior V5 version is : GTM_TEST_DEBUGINFO [$prior_ver]"
echo "----------------------------------------------------------------------"
echo "# Switch to prior version"
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image

echo "# Create database using prior V5 version"

setenv gtm_test_jnl "SETJNL"
setenv tst_jnl_str "-journal=enable,$b4nob4image,alloc=2048,ext=2048"

$gtm_tst/com/dbcreate.csh mumps 1

\rm -f *.o >& rm2.out	# remove .o files created by prior version (in case the format is different)

echo ""
echo "# Switch to current version"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

echo ""
echo "# Upgrade global directory to current version"
$GDE exit

echo ""
echo -n "Journal Extension: "
$DSE dump -f |& sed -n 's/^.*Journal Extension[ 	]*\([0-9][0-9]*\)$/\1/p'
echo ""

cd ..

###########################################################################

echo ""
echo "Test setting journal extension to maximum with mupip"
echo "===================================================="

mkdir jnlextmax
cd jnlextmax

setenv gtm_test_jnl "SETJNL"
setenv tst_jnl_str "-journal=enable,$b4nob4image,alloc=2048,ext=${JNL_EXT_MAX}"

$gtm_tst/com/dbcreate.csh mumps 1

$gtm_tst/com/dbcheck.csh

echo ""
echo -n "Journal Extension: "
$DSE dump -f |& sed -n 's/^.*Journal Extension[ 	]*\([0-9][0-9]*\)$/\1/p'
echo ""

cd ..

###########################################################################

echo ""
echo "Test setting journal extension to maximum with gde"
echo "=================================================="

mkdir jnlextmaxgde
cd jnlextmaxgde

setenv gtm_test_jnl NON_SETJNL
unsetenv tst_jnl_str

cat > custom.gde << END_CAT
change -region DEFAULT -journal=(${b4nob4image}_image,allocation=2048,extension=${JNL_EXT_MAX})
END_CAT

setenv test_specific_gde custom.gde
$gtm_tst/com/dbcreate.csh mumps 1
unsetenv test_specific_gde

$MUPIP set -region -journal="enable,$b4nob4image" DEFAULT

$gtm_tst/com/dbcheck.csh

echo ""
echo -n "Journal Extension: "
$DSE dump -f |& sed -n 's/^.*Journal Extension[ 	]*\([0-9][0-9]*\)$/\1/p'
echo ""

cd ..

###########################################################################

echo ""
echo "Test setting journal extension beyond maximum with mupip"
echo "========================================================"

mkdir jnlexttoobig
cd jnlexttoobig

setenv gtm_test_jnl "SETJNL"
#setenv tst_jnl_str "-journal=enable,before,alloc=2048,ext=${JNL_EXT_MAX_PLUS_ONE}"
setenv tst_jnl_str "-journal=enable,$b4nob4image"

$gtm_tst/com/dbcreate.csh mumps 1

$MUPIP set -region -journal=enable,$b4nob4image,alloc=2048,ext=${JNL_EXT_MAX_PLUS_ONE} "*"

echo ""

cd ..

###########################################################################

echo ""
echo "Test setting journal extension beyond maximum with gde"
echo "======================================================"

mkdir jnlexttoobiggde
cd jnlexttoobiggde

setenv gtm_test_jnl NON_SETJNL
unsetenv tst_jnl_str

cat > custom.gde << END_CAT
change -region DEFAULT -journal=(${b4nob4image}_image,allocation=2048,extension=${JNL_EXT_MAX_PLUS_ONE})
END_CAT

setenv test_specific_gde custom.gde
$gtm_tst/com/dbcreate.csh mumps 1
unsetenv test_specific_gde

# dbcreate.out should have GDE-I-VALTOOBIG and hence %GDE-E-OBJNOTCHG
$gtm_tst/com/check_error_exist.csh dbcreate.out GDE-I-VALTOOBIG GDE-E-OBJNOTCHG

echo ""

cd ..

###########################################################################

echo ""
echo "Test setting allocation adjustment with gde"
echo "==========================================="

mkdir allocadjust
cd allocadjust

echo ""
echo "# Set allocation with no adjustment required"
echo ""

$GDE change -region DEFAULT -journal="(${b4nob4image}_image,allocation=7340025,extension=1048575,autoswitchlimit=8388600)"
$GDE show -command |& $grep -E "REGION DEFAULT|TEMPLATE.*JOURNAL"
echo ""
$GDE change -region DEFAULT -journal="(${b4nob4image}_image,allocation=7340026,extension=1048575,autoswitchlimit=7340026)"
$GDE show -command |& $grep -E "REGION DEFAULT|TEMPLATE.*JOURNAL"

echo ""
echo "# Set allocation with adjustment"
echo ""

$GDE change -region DEFAULT -journal="(${b4nob4image}_image,allocation=7340026,extension=1048575,autoswitchlimit=8388600)"
$GDE show -command |& $grep -E "REGION DEFAULT|TEMPLATE.*JOURNAL"

echo ""
echo "# Set allocation beyond autoswitchlimit"
echo ""

$GDE change -region DEFAULT -journal="(${b4nob4image}_image,allocation=7340026,extension=1048575,autoswitchlimit=7340025)"

echo ""
echo "# Add new regions"
echo ""

cat <<ENDGDE > a.gde
add -region A -dynamic_segment=A -journal=(${b4nob4image}_image,allocation=7340025,extension=1048575,autoswitchlimit=8388600)
add -segment A -file=a.dat
add -name A -region=A
ENDGDE

$GDE @a.gde
$GDE show -command |& $grep -E "REGION A|TEMPLATE.*JOURNAL"

echo ""

cat <<ENDGDE > b.gde
add -region B -dynamic_segment=B -journal=(${b4nob4image}_image,allocation=7340026,extension=1048575,autoswitchlimit=8388600)
add -segment B -file=b.dat
add -name B -region=B
ENDGDE

$GDE @b.gde
$GDE show -command |& $grep -E "REGION B|TEMPLATE.*JOURNAL"

echo ""

cat <<ENDGDE > c.gde
add -region C -dynamic_segment=C -journal=(${b4nob4image}_image,allocation=7340026,extension=1048575,autoswitchlimit=7340025)
add -segment C -file=c.dat
add -name C -region=C
ENDGDE

$GDE @c.gde

echo ""

cd ..

###########################################################################

echo ""
echo "Test autoswitchlimit set in gde used by mupip"
echo "============================================="

mkdir aslgdemupip
cd aslgdemupip

$GDE change -region DEFAULT -journal="(${b4nob4image}_image,autoswitchlimit=4192256)"
$MUPIP create

echo ""
echo -n "Journal AutoSwitchLimit: "
$DSE dump -f |& sed -n 's/^.*Journal AutoSwitchLimit[ 	]*\([0-9][0-9]*\).*$/\1/p'
echo ""

cd ..


###########################################################################

echo ""
echo "Test setting allocation adjustment with mupip"
echo "============================================="

mkdir allocadjustmupip
cd allocadjustmupip

setenv gtm_test_jnl "SETJNL"
setenv tst_jnl_str "-journal=enable,$b4nob4image,allocation=7340026,extension=1048575,autoswitchlimit=8388600"

$gtm_tst/com/dbcreate.csh mumps 1

echo ""
echo -n "Journal Allocation: "
$DSE dump -f |& sed -n 's/^.*Journal Allocation[ 	]*\([0-9][0-9]*\).*$/\1/p'
echo ""

cd ..

###########################################################################

echo "###"
echo "### END OF TEST"
echo "###"

###########################################################################
###  Skip the following until we get a portable low-space test tool
###########################################################################

exit 0

echo ""
echo "Test low disk space warning with large journal extension"
echo "========================================================"

mkdir jnlextlowspace
sudo /bin/mount -t tmpfs -o size=53248m tmpfs jnlextlowspace
cd jnlextlowspace

cp $gtm_tst/$tst/inref/filljnl.m .

echo ""
echo "# create database"
echo ""

$GDE change -segment DEFAULT -bl=16384
$GDE change -region DEFAULT -r=16352
$MUPIP create
$MUPIP set -journal=enable,$b4nob4image,allocation=2048,extension=33553408,autoswitchlimit=8388600 -reg DEFAULT

echo ""
echo "# fill journal"
echo ""

echo "# pass 1"
$gtm_exe/mumps -run filljnl &
set pid1=$!
wait
echo ""
$grep "GTM\[${pid1}\]" /var/log/messages
echo ""
ls -l mumps*

echo ""
echo "# pass 2"
$gtm_exe/mumps -run filljnl &
set pid2=$!
wait
echo ""
$grep "GTM\[${pid2}\]" /var/log/messages
echo ""
ls -l mumps*

echo ""
echo "# pass 3"
$gtm_exe/mumps -run filljnl &
set pid3=$!
wait
echo ""
$grep "GTM\[${pid3}\]" /var/log/messages
echo ""
ls -l mumps*

#$grep -w $PWD /var/log/messages

echo ""
echo "# file system state"
echo ""

df .

echo ""

$grep "GTM\[${pid1}\]: %%GTM-I-DSKSPACEFLOW" /var/log/messages > /dev/null && echo -n "Found Warning Message" || echo -n "Did Not Find Warning Message"
echo " for pass 1"
$grep "GTM\[${pid2}\]: %%GTM-I-DSKSPACEFLOW" /var/log/messages > /dev/null && echo -n "Found Warning Message" || echo -n "Did Not Find Warning Message"
echo " for pass 2"
$grep "GTM\[${pid3}\]: %%GTM-I-DSKSPACEFLOW" /var/log/messages > /dev/null && echo -n "Found Warning Message" || echo -n "Did Not Find Warning Message"
echo " for pass 3"

cd ..

sudo /bin/umount jnlextlowspace

###########################################################################
###  Skip the previous until we get a portable low-space test tool
###########################################################################

###########################################################################
