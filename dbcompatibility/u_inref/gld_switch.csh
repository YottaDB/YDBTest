#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# switch to an old version
set old_ver = $1
source $gtm_tst/com/switch_gtm_version.csh $old_ver $tst_image
#
$gtm_tst/com/dbcreate.csh mumps 4 200
# Exact 8char name is mapped to a data file
# so as to check the same when we switch to version being tested down the line
cat > eightchar.gde << gde2_eof
add -name A234567A -region=REG1
add -region REG1 -d=SEG1
add -segment SEG1 -file=A234567A.dat
add -name A234567B -region=REG2
add -region REG2 -d=SEG2
add -segment SEG2 -file=A234567B.dat
exit
gde2_eof
$GDE_SAFE @eightchar.gde
cp mumps.gld mumps.gld.${old_ver}
$GDE_SAFE show -map >&! gde_show_map_${old_ver}.out
# A simple cheat to include the above 8 char database is to delete all databases and recreate after sourcing the new gld
\rm -f *.dat
$MUPIP create >&! mpcreate1.out
$gtm_tst/com/dbcheck.csh
#
# Now switch to version being tested
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
#
#  we now check for GTM to error out when using a old version GLD
$GTM << gtm_eof
write "Error expected here as GLD used is not the same version",!
set ^asample="I should not be set"
halt
gtm_eof
# Remove the datafiles except for "GLD"
rm -f *.dat

#GDE should write out the GLD file for the version being tested
$GDE show -map
# create database
$GDE show -command -file="gde_commands.cmd" >&! get_gde_commands.out
setenv test_specific_gde gde_commands.cmd
$gtm_tst/com/dbcreate.csh .
# set globals to databse
$GTM << gtm_eof
do set^lotsvar
halt
gtm_eof
# set 8char & 9char globals to databse
$GTM <<gtm8_eof
set ^A234567A="IamA8"
set ^A234567B="IamB8"
set ^A234567A9="IamA9"
set ^A234567ALongname18="Iam18"
set ^A234567A9MoreLongNameNow26="Iam26"
halt
gtm8_eof
# from here check whether globals resides in their appropriate datafiles(a.dat,b.dat,c.dat,etc.)

$gtm_tst/com/extract_database.csh a
set cnta=`$tst_awk 'NR>2 && /^\^[^aA]/ {count = count + 1} END {print count+0}' a_extract.glo`
if ($cnta != 0) then
	echo "TEST-E-INCORRECT GLOBAL-DATAFILE MAPPING for AREG"
else
	echo "CORRECT GLOBAL-DATAFILE MAPPING for AREG"
endif
# check whether 9char globals & >9har globals resides in a.dat.Value included for exact match
set cntlng=`$tst_awk 'NR>2 && (/^\^A234567A9="IamA9"/ || /^\^A234567ALongname18="Iam18"/ || /^\^A234567A9MoreLongNameNow26="Iam26"/) {count = count + 1 } END {print count+0}' a_extract.glo`
if ($cntlng != 3) then
	echo  "TEST-E-INCORRECT 9CHAR GLOBAL MAPPING"
else
	echo  "CORRECT 9CHAR GLOBAL-DATAFILE MAPPING"
endif

# check for 8char global-datafile mapping
$gtm_tst/com/extract_database.csh A234567A
set cnt8=`$tst_awk 'NR>2 && /^\^A234567A="IamA8"/ {count = count + 1} END {print count+0}' A234567A_extract.glo`
if ($cnt8 != 1) then
	echo "TEST-E-INCORRECT GLOBAL-DATAFILE MAPPING on 8CHAR global"
else
	echo "CORRECT 8CHAR GLOBAL-DATAFILE MAPPING"
endif

$gtm_tst/com/extract_database.csh b
set cntb=`$tst_awk 'NR>2 && /^\^[^bB]/ {count = count + 1} END {print count+0}' b_extract.glo`
if ($cntb != 0) then
	echo "TEST-E-INCORRECT GLOBAL DATAFILE MAPPING for BREG"
else
	echo "CORRECT GLOBAL-DATAFILE MAPPING for BREG"
endif
