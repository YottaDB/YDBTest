#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#!/usr/local/bin/tchs -f

# This test heavily relies on blocks to upgrade and block transaction numbers.
# Disable gtm_gvdupsetnoop since if it is randomly enabled, the block TNs will not change as expected, if duplicate updates happen
unsetenv gtm_gvdupsetnoop
#switching to a random V4 version
$sv4
echo "GTM version is switched to $v4ver"
# priorver.txt is to filter the old version names in the reference file
echo $v4ver >& priorver.txt
cat > priorver.gde << gde_exit
change -segment DEFAULT -file=mumps.dat
change -region DEFAULT -record_size=496
change -segment DEFAULT -block_size=512
change -segment DEFAULT -exten=1
exit
gde_exit
$GDE_SAFE @priorver.gde
$MUPIP create
$gtm_exe/mumps -run setgood^upgrdtst

$MUPIP set -reserved_bytes=8 -region DEFAULT
$DBCERTIFY SCAN DEFAULT
echo "yes" | $DBCERTIFY CERTIFY mumps.dat.dbcertscan
echo "yes" | $MUPIPV5 upgrade mumps.dat
$sv5
echo "GTM version is switched to V6"
$GDE exit

source $gtm_tst/com/get_blks_to_upgrade.csh
set btu1="$blkstoupgrade_dec"
echo "Blocks to upgrade $blkstoupgrade_hex"
if($btu1<5) then
        echo "TEST-E-ERROR Blocks to upgrade should be greater than 5. But it is $btu1"
else
	echo "PASS Blocks to upgrade is $btu1, which is greater than 5."
endif

$gtm_exe/mumps -run vrfybig^upgrdtst
source $gtm_tst/com/get_blks_to_upgrade.csh
set btu2="$blkstoupgrade_dec"
echo "Blocks to upgrade $blkstoupgrade_hex"
if($btu1 != $btu2) then
        echo "TEST-E-ERROR. Blocks to upgrade value should stay the same. It has changed fro, $btu1 to $btu2"
else
	echo "PASS. Blocks to upgrade value stayed the same as $btu2"
endif

# Disable gvdupsetnoop as we want the block TNs to change even for duplicate updates
$GTM << gtm_end
view "GVDUPSETNOOP":0  set ^biggbl(1)=\$justify(1,480+((1-1)#10))
halt
gtm_end
source $gtm_tst/com/get_blks_to_upgrade.csh
set btu3="$blkstoupgrade_dec"
echo "Blocks to upgrade $blkstoupgrade_hex"
if($btu3 != `expr $btu2 - 1`) then
        echo "TEST-E-ERROR. Blocks to upgrade is not reduced exactly by one $btu2 -1 != $btu3"
else
	echo "PASS. Blocks to upgrade is reduced exactly by one from $btu2 to $btu3"
endif

#-   Run setgood^upgrdtst.m to update all keys in the database
#-        --> check that "blks_to_upgrade" counter in file-header has reduced by EXACTLY 3
# Disable gvdupsetnoop as we want the block TNs to change even for duplicate updates
$GTM << GTM_EOF
	view "GVDUPSETNOOP":0  do setgood^upgrdtst
GTM_EOF
source $gtm_tst/com/get_blks_to_upgrade.csh
set btu4="$blkstoupgrade_dec"
echo "Blocks to upgrade $blkstoupgrade_hex"
if($btu4 != `expr $btu3 - 3`) then
        echo "TEST-E-ERROR. Blocks to upgrade is not reduced exactly by three $btu3 -3 != $btu4"
else
	echo "PASS. Blocks to upgrade is reduced exactly by three, from $btu3 to $btu4"
endif

$MUPIP reorg -upgrade -region DEFAULT
source $gtm_tst/com/get_blks_to_upgrade.csh "check" "0"
$MUPIP reorg -downgrade -region DEFAULT
source $gtm_tst/com/get_blks_to_upgrade.csh "check" "default"

$DSE find -key="^biggbl(1)" >&! dsefindkey_biggbl_1
set level0=`$tst_awk '/Key found in block/ {print $5}' dsefindkey_biggbl_1 | $tst_awk -F"." '{print $1}'`
$DSE dump -block="$level0" -header

$MUPIP set -version=V6 -region DEFAULT
# Disable gvdupsetnoop as we want the block TNs to change even for duplicate updates
$GTM << gtm_eof
view "GVDUPSETNOOP":0  set ^biggbl(1)=\$justify(1,480+((1-1)#10))
halt
gtm_eof

$DSE find -key="^biggbl(1)" >&! dsefindkey_biggbl_1a
set level0=`$tst_awk '/Key found in block/ {print $5}' dsefindkey_biggbl_1a | $tst_awk -F"." '{print $1}'`
$DSE dump -block="$level0" -header

source $gtm_tst/com/get_blks_to_upgrade.csh "check" "-1"
