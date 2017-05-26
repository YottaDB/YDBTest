#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# The databases are created only once, but different gtmgbldir settings are used.
# It is not easy to use dbcreate.csh to achieve the same

echo "! address gtm_test_qdbrundown randomness"		>> randomness.gde
if ($gtm_test_qdbrundown) then
	echo "template -region -qdbrundown"		>> randomness.gde
	echo "change -region DEFAULT -qdbrundown"	>> randomness.gde
endif
setenv gtmgbldir mixgld1.gld
$GDE << GDE_EOF >&! gde_mixgld1.out
@randomness.gde
@$gtm_tst/$tst/inref/mixgld1.gde
@$gtm_tst/$tst/inref/mixgldregs.gde
GDE_EOF


setenv gtmgbldir mixgld2.gld
$GDE << GDE_EOF >&! gde_mixgld2.out
@randomness.gde
@$gtm_tst/$tst/inref/mixgld2.gde
@$gtm_tst/$tst/inref/mixgldregs.gde
GDE_EOF

setenv gtmgbldir mixgld3.gld
$GDE << GDE_EOF >&! gde_mixgld3.out
@randomness.gde
@$gtm_tst/$tst/inref/mixgld3.gde
@$gtm_tst/$tst/inref/mixgldregs.gde
GDE_EOF

$MUPIP create

$gtm_exe/mumps -run mixgld

echo "# Two M programs each updating globals spanning two different regions should not restart due to each other"
cat >> dse_crit.csh << dsecrit
#!/usr/local/bin/tcsh -f
$DSE << DSE_EOF
find -region=REG5
crit -seize
spawn "$gtm_tst/com/wait_for_log.csh -log releasecrit.txt -waitcreation"
crit -release
dsecrit

echo "# Hold crit on region REG5, where the unsubscripted global is mapped to"
chmod +x dse_crit.csh
(./dse_crit.csh & ; echo $! >&! dse_crit.pid) >&! bg_dse_crit.out

$gtm_exe/mumps -run mixgldtp^mixgld
if (! $?gtm_poollimit) then
	$grep 'TRESTART:' tp_mixgld.mjo*
endif
touch releasecrit.txt
set dsecrit_pid = `cat dse_crit.pid`
$gtm_tst/com/wait_for_proc_to_die.csh $dsecrit_pid

echo "# Two glds spanning the same global intersect in terms of actual db files a global maps to but not completely"
echo "# Referencing subscripted globals through both glds in the same process such that they open only a subset"
echo "#  of regions that are mapped to by the globals should work fine"
$gtm_exe/mumps -run subset^mixgld
echo "# Do the same using extended references"
$gtm_exe/mumps -run subsetextended^mixgld
echo "# Do the same using naked references"
$gtm_exe/mumps -run subsetnaked^mixgld
$gtm_tst/com/dbcheck.csh
