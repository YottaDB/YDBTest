#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018-2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since the first case would throw the expected error
# only when the collation header is set.
setenv gtm_dirtree_collhdr_always 1

if (! $?gtm_test_replay) then
	set actcollmismtch_rand1 = `$gtm_exe/mumps -run rand 2`
	echo "setenv actcollmismtch_rand1 $actcollmismtch_rand1"	>>&! settings.csh
endif

# setup collation 1
source $gtm_tst/com/cre_coll_sl_reverse.csh 1
setenv back_gtm_collate_1 $gtm_collate_1
source $gtm_tst/com/unset_ydb_env_var.csh ydb_collate_1 gtm_collate_1
source $gtm_tst/com/unset_ydb_env_var.csh ydb_local_collate gtm_local_collate
echo "# Test case 1 :"
$GDE exit
$MUPIP create
echo "# Create ^x entry in directory tree with collation of 0"
$gtm_exe/mumps -run %XCMD 'set ^x=1'

echo "# Switch to collation 1"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_collate_1 gtm_collate_1 $back_gtm_collate_1

echo "# Add a global with collation 1"
$GDE add -gblname x -coll=1

echo "# Now try to set ^x. This should throw ACTCOLLMISMTCH error"
$GTM << GTM_EOF
	set ^x="ERROR"	; this should issue ACTCOLLMISMTCH error
	set ^x="ERROR"	; this should issue ACTCOLLMISMTCH error as well
	if (^x'=1) write "^x : Expected=1, Actual=",^x,!	; ^x should still show value of 1
GTM_EOF

$gtm_tst/com/backup_dbjnl.csh testcase1 "*.dat *.gld" "mv"


echo "# Test case 2 :"
echo "# create a.gld with global x having collation 1"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_collate_1 gtm_collate_1 $back_gtm_collate_1
setenv gtmgbldir a.gld
$GDE add -gblname x -coll=1

echo "# create b.gld with global x having collation 0"
setenv gtmgbldir b.gld
$GDE add -gblname x -coll=0

$MUPIP create

echo "# Randomly change the fileheader collation to 2, but do not set any globals"
if ($actcollmismtch_rand1) then
	$DSE change -fi -def=2 >&! tc_2_dse_change_def.out
endif

echo '# Now try to do $get(^x) first with a.gld and then with b.gld'
echo "# expect ACTCOLLMISMTCH error whenever accessed via b.gld but not when accessed with a.gld again"
$GTM << gtm_eof
	write \$get(^|"a.gld"|x)
	write \$get(^x)
	write \$get(^|"a.gld"|x)
	write \$get(^x)
gtm_eof

$gtm_tst/com/backup_dbjnl.csh testcase2 "*.dat *.gld" "mv"


echo "# Test case 2B :"
echo "# Create a database with fileheader collation set to 2"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_collate_2 gtm_collate_2 $back_gtm_collate_1
setenv gtmgbldir mumps.gld
$GDE exit ; $MUPIP create
$DSE change -fi -def=2
echo "# Create ^x entry in directory tree with collation of 2"
$gtm_exe/mumps -run %XCMD 'set ^x=1'

echo "# create a.gld with global x having collation 1"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_collate_1 gtm_collate_1 $back_gtm_collate_1
setenv gtmgbldir a.gld
$GDE add -gblname x -coll=1

echo "# create b.gld with global x having collation 0"
setenv gtmgbldir b.gld
$GDE add -gblname x -coll=0

echo '# Now try to do $get(^x) first with a.gld and then with b.gld'
echo "# expect ACTCOLLMISMTCH error in both the cases (because the Directory Tree has set collation 2 for the global)"
$GTM << gtm_eof
	write \$get(^|"a.gld"|x)
	write \$get(^x)
	write \$get(^|"a.gld"|x)
	write \$get(^x)
gtm_eof

$gtm_tst/com/backup_dbjnl.csh testcase2B "*.dat *.gld" "mv"
echo "# Test case 3 :"
echo "# Create a.gld with ^x(1:10) -> AREG and ^x(11:) -> DEFAULT ; and gblname x with collation=1"
setenv gtmgbldir a.gld
$GDE << GDE_EOF >> agld.out
add -name x* -reg=AREG
add -name x(1:10) -reg=AREG
add -region AREG -dyn=ASEG -stdnullcoll
add -segment ASEG -file=a.dat
add -name x(11:) -reg=DEFAULT
add -gblname x -coll=1
change -region DEFAULT -stdnullcoll
GDE_EOF

echo "# Create b.gld with ^x(1:10) -> DEFAULT and ^x(11:) -> AREG ; and gblname x with collation=0"
setenv gtmgbldir b.gld
$GDE << GDE_EOF >> bgld.out
add -name x(11:) -reg=AREG
add -region AREG -dyn=ASEG -stdnullcoll
add -segment ASEG -file=a.dat
add -name x(1:10) -reg=DEFAULT
add -gblname x -coll=0
change -region DEFAULT -stdnullcoll
GDE_EOF

$MUPIP create
echo '# Within the same process try accessing |"a.gld"|^x(11), |"b.gld"|^x(11) -> expect ACTCOLLMISMTCH'
$GTM << GTM_EOF
	write \$get(^|"a.gld"|x(11))
	write \$get(^|"b.gld"|x(11))
GTM_EOF

echo '# Within the same process try accessing |"a.gld"|^x(1), |"b.gld"|^x(1)'
echo '# It should not error out, as they map to different regions'
$GTM << GTM_EOF
	write \$get(^|"a.gld"|x(1))
	write \$get(^|"b.gld"|x(1))
GTM_EOF

echo '# Within the same process try accessing |"a.gld"|^x(1), |"b.gld"|^x(11) -> expect ACTCOLLMISMTCH'
$GTM << GTM_EOF
	write \$get(^|"a.gld"|x(1))
	write \$get(^|"b.gld"|x(11))
GTM_EOF

echo '# Within the same process try accessing |"a.gld"|^x(11), |"b.gld"|^x(1) -> expect ACTCOLLMISMTCH'
$GTM << GTM_EOF
	write \$get(^|"a.gld"|x(11))
	write \$get(^|"b.gld"|x(1))
GTM_EOF

$gtm_tst/com/backup_dbjnl.csh testcase3 "*.dat *.gld" "mv"

echo "# Test case 4 :"
echo "# If collation characteristics are defined in gld for a global name, (only when) the first node of that global"
echo "# name which gets set in the database (i.e. one that creates the GVT) will create a tree with "
echo "# the collation characteristics inherited from the gld."

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_collate_2 gtm_collate_2 $back_gtm_collate_1

$GDE add -gblname a -coll=1
$MUPIP create

echo "# Without doing any global update (after creating the db), change the col of gblname a. It should work"
$GDE change -gblname a -coll=2

echo "# Now set ^a (so that the GVT will set the collation characteristics)"
$gtm_exe/mumps -run %XCMD 'set ^a=2'

echo "# Now try changhing the col of gblname a. It would not work when tried to access"
$GDE change -gblname a -coll=1
$gtm_exe/mumps -run %XCMD 'set ^a=1'

