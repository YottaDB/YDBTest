#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
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
#
# test long names in GDE
echo "#################################################################################"
echo "STEP0. test too-long names for various commands"
setenv gtmgbldir toolong.gld
# every one of the following should fail
$GDE << GDE_END
add -name F* -region=Ff345678901234567890123456789012
add -region Ff34567890123456789012345678901 -dyn=Ff345678901234567890123456789012
add -region Ff345678901234567890123456789012 -dyn=Ff34567890123456789012345678901
add -segment Ff345678901234567890123456789012 -file=f.dat
add -name Ff345678901234567890123456789012 -region=Fref
add -region Freg -dyn=Ff345678901234567890123456789012
show -name De34567890123456789012345678901*
verify -name De34567890123456789012345678901*
show -map
exit
GDE_END

setenv gtmgbldir mumps.gld
echo "#################################################################################"
echo "STEP1. test long name name-space (gde_long1.csh)"
# create a gld using the pre-defined command file
source $gtm_tst/$tst/u_inref/gde_long1.csh >&! dbcreate1.out
$grep -v "mumps.gld" dbcreate1.out >! dbcreate1.out1
$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk dbcreate1.out1 $gtm_tst/$tst/outref/dbcreate1.txt >&! dbcreate1.cmp
\diff dbcreate1.cmp dbcreate1.out1 >& dbcreate1.dif
if ($status) then
	echo "#######################################"
	echo "TEST-E-FAIL, dbcreate error"
	echo "Please check dbcreate1.dif"
	echo "test will stop now..."
	exit
endif
$GDE show -map
$GDE show -template
# create the database
echo "create the database and fill the database with gdefill.m"
if ("ENCRYPT" == "$test_encryption" ) then
        $gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
	setenv gtmcrypt_config `pwd`/gtmcrypt.cfg
endif
$MUPIP create >& mupip_create1.out
$GTM << EOF
do ^gdefill
write "set globals of 31-char length (to test name-level \$ORDER)",!
for step=0:1:61 do set3^gdefill(31,step)
do order3^gdefill
halt
EOF
#
echo "Verify the globals have gone to the correct database"
#
foreach fname (a b d mumps temp)
	$gtm_tst/com/extract_database.csh $fname.dat
	#
	$grep -v ZWR ${fname}_extract.glo >! gde_long1_${fname}.out
	echo "### gde_long1_$fname.out ###" >>&! gde_long1_combined.out
	sed 's/GT.M MUPIP EXTRACT.*/GT.M MUPIP EXTRACT/g' gde_long1_$fname.out >>&! gde_long1_combined.out
end #end of foreach
\diff $gtm_tst/$tst/u_inref/gde_long1.txt gde_long1_combined.out >& gde_long1_combined.dif
if ($status) then
	echo "#######################################"
	echo "TEST-E-FAIL, gde_long1 FAILURE: some globals are not in the correct database."
	echo "Please check the diff at: gde_long1_combined.dif"
	echo "#######################################"
else
	echo "gde_long1 SUCCESS"
endif
#
# save the database files
$gtm_tst/com/backup_dbjnl.csh long1 "*.dat *.gld *.glo* *.out mupip_extract*.ext" mv nozip
#
echo "#################################################################################"
echo "STEP2. test long global directory names"
@ overlen = $maxlen + 1
@ i = 2
set gbldir = "g"
while ($i <= $overlen)
	@ num = $i % 10
	set gbldir = "$gbldir""$num"
	setenv gtmgbldir "$gbldir"".gld"
	$GDE exit
	@ i = $i + 1
end
$GDE show -map
$MUPIP create
$GTM << gtm_end
set ^a=1,^b=2,^c=3
zwrite ^?.E
gtm_end
#	save the global directory files
$gtm_tst/com/backup_dbjnl.csh step2 "*.dat *.gld" mv nozip
#
#
echo "#################################################################################"
echo "STEP3. test GDE boundary conditions with long region/segment names (gde_long2.csh)"
setenv gtmgbldir mumps.gld
$GDE << GDE_END >>&! dbcreate2.out
@$gtm_tst/$tst/u_inref/gde_long2.csh
GDE_END
$grep -v "mumps.gld" dbcreate2.out >! dbcreate2.out1
$GDE show -map
if ("ENCRYPT" == "$test_encryption" ) then
        $gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create >&! mupip_create2.out
$gtm_exe/mumps -run %XCMD "for substep=0:1:31 do set2^gdefill($maxlen,substep)"

echo "Verify that the globals go to the correct databases"
# Do 15 extracts at a time in background because, with encryption db extract is slow
# This might not be required once GTM-8275 and GTM-8274 is fixed
@ iter = 0
while ($iter <= $maxlen)
	@ next = $iter + 15
	if ($next > $maxlen) then
		@ next = $maxlen
	endif
	$gtm_tst/$tst/u_inref/bg_extract_db.csh "a" $iter $next >&! bg_extract_a_${iter}_${next}.out
	@ iter = $next + 1
end

@ iter = 0
while ($iter <= $maxlen)
	set fname = "a$iter"
	if (0 == $iter) set fname = "mumps"
	#$gtm_tst/com/extract_database.csh $fname.dat
	#
	$grep -v ZWR ${fname}_extract.glo >! gde_long2_${fname}.out
	echo "### gde_long2_$fname.out ###" >>&! gde_long2_combined.out
	sed 's/GT.M MUPIP EXTRACT.*/GT.M MUPIP EXTRACT/g' gde_long2_$fname.out >>&! gde_long2_combined.out
	@ iter = $iter + 1
end
\diff $gtm_tst/$tst/u_inref/gde_long2.txt gde_long2_combined.out >& gde_long2.dif
if ($status) then
	echo "#######################################"
	echo "TEST-E-FAIL, gde_long2 FAILURE: some globals are not in the correct databases."
	echo "Please check the diff at: gde_long2.dif"
	echo "#######################################"
else
	echo "gde_long2 SUCCESS"
endif

# save the database files
$gtm_tst/com/backup_dbjnl.csh long2 "*.dat *.gld *.glo* *.out mupip_extract*.ext" mv nozip
#
echo "#################################################################################"
echo "STEP4. test GDE boundary conditions with mappings in form 2 (gde_long3.csh)"
setenv gtmgbldir mumps.gld
$GDE << GDE_END >> &! dbcreate3.out
@$gtm_tst/$tst/u_inref/gde_long3.csh
GDE_END
$grep -v "mumps.gld" dbcreate3.out >! dbcreate3.out1
$GDE show -map
if ("ENCRYPT" == "$test_encryption" ) then
        $gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create >& mupip_create3.out
echo "Set some globals..."
set step = 0
while ($step <= 61)
$GTM << gtm3 >>&! gtm3.out
set step=$step
for substep=step:1:step+31 quit:substep=62  do set3^gdefill($maxlen,substep)
halt
gtm3
@ step = $step + 32
end
#
echo "Verify that the globals go to the correct databases"
# enable the following while limit (<=62) whenever the following TR is fixed:
# C9E11-002658 GDE creates corrupt .gld file if a particular max-length global name is used
#while ($iter <= 62)
@ iter = 1
while ($iter <= 61)
	@ next = $iter + 15
	if ($next > 61) then
		@ next = 61
	endif
	$gtm_tst/$tst/u_inref/bg_extract_db.csh "ax" $iter $next >&! bg_extract_a_${iter}_${next}.out
	@ iter = $next + 1
end
@ iter = 1
while ($iter <= 61)
	set reg = "ax$iter"
	set fname = "$reg"
	#$gtm_tst/com/extract_database.csh $fname.dat
	#
	$grep -v ZWR ${fname}_extract.glo >! gde_long3_$fname.out
	echo "### gde_long3_$fname.out ###" >>&! gde_long3_combined.out
	sed 's/GT.M MUPIP EXTRACT.*/GT.M MUPIP EXTRACT/g' gde_long3_$fname.out >>&! gde_long3_combined.out
	@ iter = $iter + 1
end
\diff $gtm_tst/$tst/u_inref/gde_long3.txt gde_long3_combined.out >& gde_long3.dif
if ($status) then
	echo "#######################################"
	echo "TEST-E-FAIL, gde_long3 FAILURE: some globals are not in the correct database."
	echo "Please check the diff at: gde_long3.dif"
	echo "#######################################"
else
	echo "gde_long3 SUCCESS"
endif

# save the database files
$gtm_tst/com/backup_dbjnl.csh long3 "*.dat *.gld *.glo* *.out mupip_extract*.ext" mv nozip
#
echo "#################################################################################"
#
# the sub-test case for the environment variables in region/segment names working properly is added in longname/mupip test.
echo "some name does not exist errors (4 of them) are expected from dbcreate1.out"
