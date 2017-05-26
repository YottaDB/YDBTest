#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_test_eotf_keys 2	# Randomly do re-encryption
setenv gtm_test_spanreg     0	# Test requires traditional global mappings, so disable spanning regions
setenv gtm_test_jnl NON_SETJNL	# since we are "adjusting" the database files don't try journaling

if !($?gtm_test_replay) then
	set rand = `$gtm_exe/mumps -run rand 2 2 0`
	if ($rand[1]) then
		set do_reencrypt = 1
		echo "setenv do_reencrypt $do_reencrypt"	>> settings.csh
		if ( ("dbg" == "$tst_image") && ($rand[2]) ) then
			set do_partial = 1
			echo "setenv do_partial $do_partial"		>> settings.csh
		endif
	endif
endif

echo "Scenario 1: Two regions both pointing to the second region's database file"
echo ""
echo "Create a database with two regions"
$gtm_tst/com/dbcreate.csh mumps 2	# creates a.dat and mumps.dat

echo ""
echo "Use gde change -segment for each region to use envvar to specify the database file"
$GDE change -segment ASEG -file_name=\$SCAU_ACN >& gde_changes.out
$GDE change -segment DEFAULT -file_name=\$SCAU_TBLS >>& gde_changes.out

echo ""
echo "Point the regions to their corresponding database files"
setenv SCAU_ACN a.dat
setenv SCAU_TBLS mumps.dat

echo ""
echo "Fill in data in the regions"
$gtm_dist/mumps -run ^%XCMD 'for i=1:1:100 set ^A(i)=$justify(1,100)'
$gtm_dist/mumps -run ^%XCMD 'for i=1:1:100 set ^z(i)=$justify(2,100)'

set reencrypt_out = "reencrypt1.out"
if ($?do_partial) then
	setenv gtm_white_box_test_case_number 122
	setenv gtm_white_box_test_case_enable 1
	setenv gtm_white_box_test_case_count 5
	set reencrypt_out = "reencrypt1.outx"
endif

if ($?do_reencrypt) then
	$MUPIP reorg -encrypt=mumps_dat_key_2 -reg DEFAULT	>>&! $reencrypt_out
	$MUPIP set -encryptioncomplete -reg DEFAULT		>>&! $reencrypt_out
	$MUPIP reorg -encrypt=a_dat_key_2 -reg AREG		>>&! $reencrypt_out
	$MUPIP set -encryptioncomplete -reg AREG		>>&! $reencrypt_out
	unsetenv gtm_white_box_test_case_enable
	if ($?do_partial) then
		$grep -v "MUNOFINISH" $reencrypt_out >&! reencrypt1.out
	endif
endif

echo ""
echo "Point the first region to the second region's database"
setenv SCAU_ACN mumps.dat

echo ""
echo "Do an extract"
$MUPIP extract -fo=bin my.ext -override

echo ""
echo "Point the first region back to its database"
setenv SCAU_ACN a.dat

echo ""
echo "Do a load"
$gtm_exe/mupip load -fo=bin my.ext

echo ""
echo "Do a dbcheck to ensure db integs clean"
$gtm_tst/com/dbcheck.csh

echo ""
echo "Tuck away first scenario"
$gtm_tst/com/backup_dbjnl.csh dbbkup1 "*.gld *.dat *.ext" mv

echo ""
echo "Scenario 2: Two regions pointing to each other's database files"

echo ""
echo "Create a database with two regions"
$gtm_tst/com/dbcreate.csh mumps 2	# creates a.dat and mumps.dat

echo ""
echo "Use gde change -segment for each region to use envvar to specify the database file"
$GDE change -segment ASEG -file_name=\$SCAU_ACN >& gde_changes.out
$GDE change -segment DEFAULT -file_name=\$SCAU_TBLS >>& gde_changes.out

echo ""
echo "Point the regions to the other region's database files"
setenv SCAU_ACN mumps.dat
setenv SCAU_TBLS a.dat

echo ""
echo "Fill in data in the regions"
$gtm_dist/mumps -run ^%XCMD 'for i=1:1:100 set ^A(i)=$justify(3,100)'
$gtm_dist/mumps -run ^%XCMD 'for i=1:1:100 set ^z(i)=$justify(4,100)'

set reencrypt_out = "reencrypt2.out"
if ($?do_partial) then
	setenv gtm_white_box_test_case_number 122
	setenv gtm_white_box_test_case_enable 1
	setenv gtm_white_box_test_case_count 5
	set reencrypt_out = "reencrypt2.outx"
endif

if ($?do_reencrypt) then
	$MUPIP reorg -encrypt=a_dat_key_2 -reg DEFAULT		>>&! $reencrypt_out
	$MUPIP set -encryptioncomplete -reg DEFAULT		>>&! $reencrypt_out
	$MUPIP reorg -encrypt=mumps_dat_key_2 -reg AREG		>>&! $reencrypt_out
	$MUPIP set -encryptioncomplete -reg AREG		>>&! $reencrypt_out
	unsetenv gtm_white_box_test_case_enable
	if ($?do_partial) then
		$grep -v "MUNOFINISH" $reencrypt_out >&! reencrypt2.out
	endif
endif

echo ""
echo "Do an extract"
$MUPIP extract -fo=bin my.ext -override

echo ""
echo "Do a load"
$gtm_exe/mupip load -fo=bin my.ext

echo ""
echo "Do a dbcheck to ensure db integs clean"
$gtm_tst/com/dbcheck.csh

echo ""
echo "Tuck away second scenario"
$gtm_tst/com/backup_dbjnl.csh dbbkup2 "*.gld *.dat *.ext" mv

echo ""
echo "Scenario 3: Random number of regions with a random region to database file mapping"

echo ""
echo "Randomly pick the number of regions"
setenv num_regions `$gtm_exe/mumps -run rand 12 1 2` # ensure at least two regions
echo "num_regions=$num_regions" >numregs.txt

cat << EOF > gengbldirspec.m
gengbldirspec
	set numregs=\$PIECE(\$ZCMDLINE," ",1)-1
	write "change -segment DEFAULT -file_name=\$SCAU_DEFAULT",!
	for i=\$ascii("A"):1:\$ascii("A")+numregs do
	.  write "add -name "_\$char(i)_" -region="_\$char(i)_"REG",!
	.  write "add -region "_\$char(i)_"REG -dyn="_\$char(i)_"SEG",!
	.  write "add -segment "_\$char(i)_"SEG -file_name=\$SCAU_"_\$char(i),!
	quit
EOF

echo ""
echo "Generate a gbldir spec so each region uses an envvar to specify the database file"
$gtm_dist/mumps -r ^gengbldirspec $num_regions > map.gde

cat << EOF > gendefaultregmap.m
gendefaultregmap
	set numregs=\$PIECE(\$ZCMDLINE," ",1)-1
	write "setenv SCAU_DEFAULT mumps.dat",!
	for i=\$ascii("A"):1:\$ascii("A")+numregs do
	.  write "setenv SCAU_"_\$char(i)_" "_\$char(i)_".dat",!
	quit
EOF

echo ""
echo "Set default region to file mapping"
$gtm_dist/mumps -r ^gendefaultregmap $num_regions > defaultmapreg.csh
source defaultmapreg.csh

echo ""
echo "Create the global directory"
$GDE << EOF >& gdelog.out
@map.gde
exit
EOF

echo ""
echo "Create the database files"
$gtm_dist/mupip create >& mucrelog.out

echo ""
echo "Fill in data across the regions (ensure that all regions have some data)"
$gtm_dist/mumps -run ^%XCMD 'for i=$ascii("A"):1:$ascii("A")+25 set key="^"_$char(i) set @key@(i)=$j(i,100)'

cat << EOF > genrandregmap.m
genrandregmap
	set numregs=\$PIECE(\$ZCMDLINE," ",1)-1
	; Pick one region that will not change its mapping.
	; This will ensure that we have at least one global for the extract.
	if \$r(numregs+2)=0 do
	. write "setenv SCAU_DEFAULT mumps.dat",! ; pick SCAU_DEFAULT
	. set toitself="DON'T PICK ME"
	else  do
	. write "setenv SCAU_DEFAULT "_\$\$pickdbfile(numregs+1),!
	. set toitself=\$ascii("A")+\$r(numregs+1) ; pick a random enumerated region
	for i=\$ascii("A"):1:\$ascii("A")+numregs do
	. if i=toitself write "setenv SCAU_"_\$char(i)_" "_\$char(i)_".dat",!
	. else  write "setenv SCAU_"_\$char(i)_" "_\$\$pickdbfile(numregs+1),!
	quit

pickdbfile(range)
	new dbfile
	if \$r(range+1)'=0 quit \$char(\$ascii("A")+\$r(range))_".dat"
	else  quit "mumps.dat"
EOF

echo ""
echo "Randomly assign regions to database files"
$gtm_dist/mumps -r ^genrandregmap $num_regions > randmapreg.csh
source randmapreg.csh

echo ""
echo "Do an extract"
$gtm_exe/mupip extract -fo=bin my.ext >& muextrlog.out

echo ""
echo "Restore the original region to database file mapping"
source defaultmapreg.csh

echo ""
echo "Do a load"
$gtm_exe/mupip load -fo=bin my.ext >& muloadlog.out

echo ""
echo "Do a dbcheck to ensure db integs clean"
$gtm_tst/com/dbcheck.csh
