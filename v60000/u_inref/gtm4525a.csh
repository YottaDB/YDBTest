#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
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

# The test does some checks with the gde before creating datbases, so not calling dbcreate.csh
setenv gtm_custom_errors "bogus.errs"

# Specific errors are already triggered in this test. We don't want ENOSPC error to interfere with
# the particular error we expect to happen.
unsetenv gtm_test_freeze_on_error
unsetenv gtm_test_fake_enospc

touch $gtm_custom_errors

echo "Test GLD Inst Freeze on Error Flag"
echo "=================================="

echo ""
echo "# Add Regions"
echo ""

echo "A - noinst (default)"
echo "B - noinst (set)"
echo "C - inst (set)"
echo "D - inst (template)"
echo ""
echo "Template - inst (set before D)"
echo ""

cat <<ENDGDE >! addregion.gde
add -region A -dynamic_segment=A
add -region B -dynamic_segment=B -noinst
add -region C -dynamic_segment=C -inst
template -region -inst
add -region D -dynamic_segment=D
add -segment A -file=a.dat
add -segment B -file=b.dat
add -segment C -file=c.dat
add -segment D -file=d.dat
add -name A -region=A
add -name B -region=B
add -name C -region=C
add -name D -region=D
ENDGDE

$GDE @addregion.gde >>&! addregion.log

cat <<ENDGDE >! rtcshow.gde
show -region
show -template
show -command
ENDGDE

$GDE @rtcshow.gde >>&! addregionshow.log

$gtm_exe/mumps -run %XCMD 'do rtcinstcheck^gtm4525a' < addregionshow.log

echo ""
echo "# Change Region"
echo ""

echo "A - inst (set)"
echo "B - noinst (unchanged)"
echo "C - noinst (set)"
echo "D - inst (unchanged)"
echo ""
echo "Template - noinst (set)"
echo ""

cat <<ENDGDE >! changeregion.gde
change -region A -inst
change -region C -noinst
template -region -noinst
ENDGDE

$GDE @changeregion.gde >>&! changeregion.log

$GDE @rtcshow.gde >>&! changeregionshow.log

$gtm_exe/mumps -run %XCMD 'do rtcinstcheck^gtm4525a' < changeregionshow.log


echo ""
echo "Test File Header Inst Freeze on Error Flag"
echo "=========================================="

echo ""
echo "# Create Files from GLD"
echo ""

echo "A - inst"
echo "B - noinst"
echo "C - noinst"
echo "D - inst"
echo "DEFAULT - noinst"
echo ""

$gtm_exe/mupip create -region=A >>&! createfile.log
$gtm_exe/mupip create -region=B >>&! createfile.log
$gtm_exe/mupip create -region=C >>&! createfile.log
$gtm_exe/mupip create -region=D >>&! createfile.log
$gtm_exe/mupip create -region=DEFAULT >>&! createfile.log
if ($gtm_test_qdbrundown) then
	$MUPIP set -region "*" -qdbrundown >>&! set_qdbrundown.out
endif

cat <<ENDDSE > dumpheaders.dse
find -region=A
dump -file
find -region=B
dump -file
find -region=C
dump -file
find -region=D
dump -file
find -region=DEFAULT
dump -file
ENDDSE

$DSE < dumpheaders.dse >>& createfilecheck.log

$gtm_exe/mumps -run %XCMD 'do dseinstcheck^gtm4525a("A B C D DEFAULT")' < createfilecheck.log

echo ""
echo "# Modify Header Flag"
echo ""

echo "A - inst (default)"
echo "B - inst (set)"
echo "C - noinst (default)"
echo "D - noinst (set)"
echo "DEFAULT - inst (set)"
echo ""

$gtm_exe/mupip set -region B -INST >>&! setfile.log
$gtm_exe/mupip set -region D -NOINST >>&! setfile.log
$gtm_exe/mupip set -region DEFAULT -INST >>&! setfile.log

$DSE < dumpheaders.dse >>& setfilecheck.log

$gtm_exe/mumps -run %XCMD 'do dseinstcheck^gtm4525a("A B C D DEFAULT")' < setfilecheck.log

echo ""
echo "Test Instance Header Freeze Fields"
echo "=================================="

echo ""
echo "# Replication Setup"
echo ""

set instname=gtm4525a

$gtm_exe/mupip set -region "*" -journal=before -replic=on >&! journalcfg.log
setenv gtm_repl_instance ${instname}.inst
$gtm_exe/mupip replicate -instance_create -name=${instname} $gtm_test_qdbrundown_parms >&! replic.log
$gtm_exe/mupip replicate -source -start -passive -log=${instname}_SRC.logx -instsecondary=${instname}2 -rootprimary >>&! replic.log

echo ""
echo "# Manipulating Freeze Settings"
echo ""

echo "# 1"
$gtm_exe/mupip replicate -source -freeze
$gtm_exe/mupip repl -source -jnlpool -show >&! jnlpooldump1.log
$grep Freeze jnlpooldump1.log
$gtm_exe/mupip replicate -source -checkhealth
echo ""

echo "# 2"
$gtm_exe/mupip replicate -source -freeze=on -nocomment
$gtm_exe/mupip replicate -source -freeze
$gtm_exe/mupip repl -source -jnlpool -show >&! jnlpooldump2.log
$grep Freeze jnlpooldump2.log
$gtm_exe/mupip replicate -source -checkhealth
echo ""

echo "# 3"
$gtm_exe/mupip replicate -source -freeze=on -comment='"blah blah blah"'
$gtm_exe/mupip replicate -source -freeze
$gtm_exe/mupip repl -source -jnlpool -show >&! jnlpooldump3.log
$grep Freeze jnlpooldump3.log
$gtm_exe/mupip replicate -source -checkhealth
echo ""

echo "# 4"
$gtm_exe/mupip replicate -source -freeze=off
$gtm_exe/mupip replicate -source -freeze
$gtm_exe/mupip repl -source -jnlpool -show >&! jnlpooldump4.log
$grep Freeze jnlpooldump4.log
$gtm_exe/mupip replicate -source -checkhealth
echo ""

echo "# 5"
$gtm_exe/mupip replicate -source -freeze=on -comment='"All your database are belong to us. You are on the way to destruction."'
$gtm_exe/mupip replicate -source -freeze
$gtm_exe/mupip repl -source -jnlpool -show >&! jnlpooldump5.log
$grep Freeze jnlpooldump5.log
$gtm_exe/mupip replicate -source -checkhealth
echo ""

echo "# 6"
$gtm_exe/mupip replicate -source -freeze=on -nocomment
$gtm_exe/mupip replicate -source -freeze
$gtm_exe/mupip repl -source -jnlpool -show >&! jnlpooldump6.log
$grep Freeze jnlpooldump6.log
$gtm_exe/mupip replicate -source -checkhealth
echo ""

echo "# 7"
$gtm_exe/mupip replicate -source -freeze=off
$gtm_exe/mupip replicate -source -freeze
$gtm_exe/mupip repl -source -jnlpool -show >&! jnlpooldump7.log
$grep Freeze jnlpooldump7.log
$gtm_exe/mupip replicate -source -checkhealth

echo ""
echo "# Invalid Usage"
echo ""
$gtm_exe/mupip replicate -source -freeze=on
$gtm_exe/mupip replicate -source -freeze=off -comment="bad"

echo ""
echo "# Replication Shutdown"
echo ""

$gtm_exe/mupip replicate -source -freeze=off
$gtm_exe/mupip replicate -source -shutdown -timeout=0 >&! replicshutdown.log

# Render any REPLINSTFROZEN errors in the source log harmless, but put anything
# else in a log in case there are other errors.

sed 's/YDB-E-REPLINSTFROZEN/YDB-X-REPLINSTFROZEN/' < ${instname}_SRC.logx > ${instname}_SRC.log

$gtm_tst/com/dbcheck.csh
