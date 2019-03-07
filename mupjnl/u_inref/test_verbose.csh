#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information		#
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
#Test Case # 35:  (new   qualifiers: verbose and output for VMS)
# WHAT IS EXPECTED OF VERBOSE OUTPUT???
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh

$gtm_tst/com/dbcreate.csh . 1
# set flush_time to high value to avoid flush timer from being invoked.
# this way periodic epochs (written when flush timer sees no dirty buffers) are not written
# and hence will produce deterministic output
# since jnlrecm runs for around 10 seconds, keep flush timer of 15 seconds.
$DSE << EOF >&! dse_change_flush_time.out
	change -file -flush=1500
EOF
$gtm_tst/com/jnl_on.csh
sleep 2
# Since we require at least one EPOCH record (one is always there after journal create) which has timestamp strictly less than "time1" , we need a wait a of 2 secs after journal creation.
# Otherwise recover will try to find an EPOCH less than "time1" and will try to go to previous journal file and follow different code path.
sleep 2
$gtm_tst/com/abs_time.csh time1
set time1 = `cat time1_abs`

$gtm_exe/mumps -run jnlrecm
$GTM << EOF
d ^%G

*

d verify^jnlrecm
h
EOF
mkdir ./save
cp mumps.dat mumps.mjl ./save

set echo
################################################################################
$MUPIP journal -recov -back mumps.mjl -since=\"$time1\" -verbose
$GTM << EOF
d ^%G

*

d verify^jnlrecm
h
EOF
#Expected result: (database is recovered and list more information about the backward recover)
#Return status: success
################################################################################
rm mumps.dat
unset echo
# JOURNAL EXTRACT is issued when there are no database files in the current directory.
# JOURNAL EXTRACT might need to read the database file to get the collation information.
# To skip the JOURNAL EXTRACT from reading the database file, set the env variable
# ydb_extract_nocol/gtm_extract_nocol to non-zero value.
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_extract_nocol gtm_extract_nocol 1
set echo
$MUPIP journal -extract=forward_nv.mjf -for mumps.mjl
$MUPIP journal -extract=forward.mjf -for mumps.mjl -verbose
unset echo
echo $MUPIP journal -extract=backward.mjf -back mumps.mjl -since=\"$time1\" -verbose
$MUPIP journal -extract=backward.mjf -back mumps.mjl -since=\"$time1\" -verbose |& $grep -v MUJNLPREVGEN
source $gtm_tst/com/unset_ydb_env_var.csh ydb_extract_nocol gtm_extract_nocol
$grep '\^' forward_nv.mjf > forward_nv.mjf_data
$grep '\^' forward.mjf > forward.mjf_data
$grep '\^' backward.mjf > backward.mjf_data
diff forward_nv.mjf_data forward.mjf_data > /dev/null
if ($status) then
	echo "TEST-E-EXTRACT verbose and no verbose extracts are different (forward.mjf_data)"
	diff forward_nv.mjf_data forward.mjf_data
endif
diff forward_nv.mjf_data backward.mjf_data > /dev/null
if ($status) then
	echo "TEST-E-EXTRACT verbose and no verbose extracts are different (backward.mjf_data)"
	diff forward_nv.mjf_data backward.mjf_data
endif
set echo
#Expected result: Extraction successful
#                        (list more information about the extraction)
#Return status: success
################################################################################
$MUPIP journal -show=all -back mumps.mjl -verbose
#Expected result: Verification successful
#                        (list more information about the show)
#Return status: success
################################################################################
$MUPIP create
$MUPIP journal -recov -for mumps.mjl -verbose -verify
$GTM << EOF
d ^%G

*

d verify^jnlrecm
h
EOF
#Expected result: (database is recovered and list more information about the forward recover)
#Return status: success
################################################################################
rm mumps.dat
unset echo
# JOURNAL EXTRACT is issued when there are no database files in the current directory.
# JOURNAL EXTRACT might need to read the database file to get the collation information.
# To skip the JOURNAL EXTRACT from reading the database file, set the env variable
# ydb_extract_nocol/gtm_extract_nocol to non-zero value.
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_extract_nocol gtm_extract_nocol 1
set echo
$MUPIP journal -extract=forward2_nv.mjf -for mumps.mjl
$MUPIP journal -extract=forward2.mjf -for mumps.mjl -verbose
unset echo
source $gtm_tst/com/unset_ydb_env_var.csh ydb_extract_nocol gtm_extract_nocol
$grep '\^' forward2_nv.mjf > forward2_nv.mjf_data
$grep '\^' forward2.mjf > forward2.mjf_data
diff forward2_nv.mjf_data forward2.mjf_data > /dev/null
if ($status) then
	echo "TEST-E-EXTRACT verbose and no verbose extracts are different (forward2.mjf_data)"
	diff forward2_nv.mjf_data forward2.mjf_data
endif
#Expected result: Extraction successful
#                        (list more information about the extraction)
#Return status: success
################################################################################
set echo
$MUPIP journal -show=all -for mumps.mjl -verbose
#Expected result: Verification successful
#                        (list more information about the show)
#Return status: success
################################################################################
# For VMS, test /OUTPUT as well.
################################################################################
unset echo
cp ./save/mumps.dat .
$gtm_tst/com/dbcheck.csh
