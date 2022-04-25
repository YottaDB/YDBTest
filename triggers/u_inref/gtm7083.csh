#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# trigger select OR load or ZPRINT, ZBREAK or $TEXT on an upgraded db (without a trigger upgrade) should throw "NEEDTRIGUPGRD"
# DSE and LKE does not require a trigger access and should work fine
# trigger -upgrade on a read-only db should error out
# trying to update with prior versions on a "trigger -upgrade"ed db should fail with "TRIGDEFBAD"

# encryption needs to be disabled when using MSR framework + prior versions
setenv test_encryption "NON_ENCRYPT"
# The below needs to be disabled when using prior versions
setenv test_no_ipv6_ver 1
unsetenv gtmcompile
setenv test_replic_suppl_type 0
setenv gtm_test_plaintext_fallback
##
if ($?gtm_test_replay) then
	set prior_ver = $gtm7083_priorver
else
	$gtm_tst/com/random_ver.csh -gte V54002 -lte V62000 >&! prior_ver.txt
	if ($status) then
		echo "TEST-E-PRIORVER. Error obtaining random prior version. Check prior_ver.txt"
		cat prior_ver.txt
		exit
	else
		set prior_ver = `cat prior_ver.txt`
	endif
	echo "setenv gtm7083_priorver $prior_ver"	>>&! settings.csh
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver

cat > a.trg << CAT_EOF
+^a -commands=set -xecute="write ""trigger executed"",!" -name=x
CAT_EOF

cat > b.trg << CAT_EOF
+^b -commands=set -xecute="write ""trigger executed"",!" -name=x
CAT_EOF

echo "# switch to prior ver, create db and install a simple trigger"
source $gtm_tst/com/switch_gtm_version.csh $prior_ver pro
$gtm_tst/com/dbcreate.csh mumps >&! prior_ver_dbcreate.out
cp mumps.gld prior_ver_mumps.gld

$MUPIP trigger -triggerfile=a.trg
$gtm_exe/mumps -run %XCMD 'for i=1:1:5 set ^a(i)=1'

echo "# switch to current ver and try setting ^a"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$GDE exit >&! tst_ver_gdeexit.out
cp mumps.gld tst_ver_mumps.gld


echo '# Expect YDB-E-NEEDTRIGUPGRD for all the below attempts (GTM-8116 : $text should silently exit)'
set verbose
$gtm_exe/mumps -run %XCMD 'set ^a=1'
$gtm_exe/mumps -run %XCMD 'set ^notrigger=1'
echo "" | $MUPIP trigger -select
$MUPIP trigger -triggerfile=a.trg
$gtm_exe/mumps -run %XCMD 'zbreak ^x#'
$gtm_exe/mumps -run %XCMD 'write $text(^x#)'
$gtm_exe/mumps -run %XCMD 'zprint ^x#'
unset verbose
echo "# The below that does not require trigger access should work fine"
set verbose
$LKE show -all
$DSE dump -block=3 >&! dsedumpbl3.out
$grep '.-E-.' dsedumpbl3.out
$gtm_exe/mumps -run %XCMD 'write ^a(1)'
$gtm_exe/mumps -run %XCMD 'write ^notrigger'
unset verbose
echo "# Try trigger -upgrade on a read-only database. Expect it to fail"
chmod u-w mumps.dat
$MUPIP trigger -upgrade
echo "# trigger -upgrade on a read-write database should work"
chmod u+w mumps.dat
$MUPIP trigger -upgrade
$gtm_exe/mumps -run %XCMD 'set ^a=1'
echo "# Adding a trigger with an exising trigger name should not work, though the existing trigger was with old ver"
$MUPIP trigger -triggerfile=a.trg
$MUPIP trigger -select tst_ver_triggerselect.trg

echo "# switch to prior ver and try setting ^a"
source $gtm_tst/com/switch_gtm_version.csh $prior_ver pro
cp prior_ver_mumps.gld mumps.gld
# We have seen that using 'mumps -run %XCMD' causes a SIG-11 when using V62000 pro (built on a Ubuntu 18.04 system or so) on a
# Ubuntu 22.04 system. Not sure why. But we work around that by using 'mumps -direct' instead which does not suffer from that issue.
$gtm_exe/mumps -direct >&! prior_ver_upgraded_trig.out << GTM_EOF
set ^a=1
GTM_EOF
# Check for GTM-E-TRIGDEFBAD (not YDB-E-TRIGDEFBAD) since the version issuing this is < r1.20 (prior random version chosen above)
$gtm_tst/com/check_error_exist.csh prior_ver_upgraded_trig.out GTM-E-TRIGDEFBAD

echo "# switch to current ver and delete all triggers"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
cp tst_ver_mumps.gld mumps.gld
$gtm_exe/mumps -run %XCMD 'write $ztrigger("item","-*"),!'

# Database files starting V63001 have a 4Kb 0-filled block at the end of the file (assuming default block size of 4K).
# Whereas pre-V63001 database files had a 512-byte 0-filled block at the end.
# Before switching to an older version (which is clearly pre-V63001) to use a post-V63001 created database file, truncate
# the 4Kb block to 512 bytes. The MUPIP DOWNGRADE command has a special -version=V63000A qualifier to achieve this.
yes | $MUPIP downgrade -version=V63000A mumps.dat >& mupip_downgrade.out

echo "# switch to prior ver and load the trigger extract"
source $gtm_tst/com/switch_gtm_version.csh $prior_ver pro
cp prior_ver_mumps.gld mumps.gld
$MUPIP trigger -triggerfile=tst_ver_triggerselect.trg
$gtm_exe/mumps -run %XCMD 'set ^a=2'

$gtm_tst/com/dbcheck.csh >&! ${prior_ver}_dbcheck.out
