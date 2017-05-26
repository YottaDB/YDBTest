#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2009, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Verify that the configuration file can be found (via gtmcrypt_config) in all valid locations.
# gtmcrypt_config SET TO POINT TO CORRECT FILE
# gtmcrypt_config SET TO INVALID PATH
# gtmcrypt_config NOT SET AND .gtm_dbkeys IS NOT FOUND
# gtmcrypt_config NOT SET AND .gtm_dbkeys IS FOUND
# gtmcrypt_config SET TO POINT TO DIRECTORY AND FILE .gtm_dbkeys IS NOT FOUND
# gtmcrypt_config SET TO POINT TO DIRECTORY AND FILE .gtm_dbkeys IS FOUND

echo "Checking plugin error messages with gtmcrypt_config env variable by mupip create functionality"

# Set white box testing environment.
echo "# Enable WHITE BOX TESTING"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 22

setenv gtmgbldir create

$gtm_tst/com/dbcreate.csh create 3

cp $gtm_tst/encryption/inref/temp.gde .
$GDE << EOF
@temp.gde
EOF

\rm -rf *.dat

echo "#########TEST CONDITION:ENVIRONMENT VARIABLE gtmcrypt_config SET TO POINT TO CORRECT FILE##############"
setenv gtmcrypt_config ./gtmcrypt.cfg
$MUPIP create -reg=areg
$MUPIP create -reg=default
$MUPIP create -reg=breg
$MUPIP create -reg=yreg
$MUPIP create -reg=zreg
mkdir good
mv *.dat good

echo "#########TEST CONDITION:ENVIRONMENT VARIABLE gtmcrypt_config SET TO INVALID PATH###########"
setenv gtmcrypt_config gtmcryptcfg
$MUPIP create -reg=areg
$MUPIP create -reg=default
$MUPIP create -reg=breg
$MUPIP create -reg=yreg
$MUPIP create -reg=zreg
\rm -rf *.dat

echo "#########TEST CONDITION:ENVIRONMENT VARIABLE gtmcrypt_config NOT SET AND .gtm_dbkeys IS NOT FOUND###########"
unsetenv gtmcrypt_config
$MUPIP create -reg=areg
$MUPIP create -reg=default
$MUPIP create -reg=breg
$MUPIP create -reg=yreg
$MUPIP create -reg=zreg
\rm -rf *.dat

echo "#########TEST CONDITION:ENVIRONMENT VARIABLE gtmcrypt_config NOT SET AND .gtm_dbkeys IS FOUND###########"
# Temporarily set $HOME to a location within the test output. This way, boxes running this test concurrently don't end up deleting
# the .gtm_dbkeys file if some other box is relying on its presence.
mkdir ./tmphome
set save_home = $HOME
setenv HOME `pwd`/tmphome
cp $gtm_dbkeys $HOME/.gtm_dbkeys
$MUPIP create -reg=areg
$MUPIP create -reg=default
$MUPIP create -reg=breg
$MUPIP create -reg=yreg
$MUPIP create -reg=zreg
\rm -rf *.dat
\rm -rf $HOME/.gtm_dbkeys
setenv HOME $save_home

echo "########TEST CONDITION:ENVIRONMENT VARIABLE gtmcrypt_config SET TO POINT TO DIRECTORY AND FILE .gtm_dbkeys IS NOT FOUND####"
mkdir dbkeyfile
setenv gtmcrypt_config ./dbkeyfile
$MUPIP create -reg=areg
$MUPIP create -reg=default
$MUPIP create -reg=breg
$MUPIP create -reg=yreg
$MUPIP create -reg=zreg
\rm -rf *.dat

echo "######TEST CONDITION:ENVIRONMENT VARIABLE gtmcrypt_config SET TO POINT TO DIRECTORY AND FILE .gtm_dbkeys IS FOUND##########"
setenv gtmcrypt_config ./dbkeyfile
cp $gtm_dbkeys dbkeyfile/.gtm_dbkeys
$MUPIP create -reg=areg
$MUPIP create -reg=default
$MUPIP create -reg=breg
$MUPIP create -reg=yreg
$MUPIP create -reg=zreg
setenv gtmcrypt_config ./gtmcrypt.cfg
mv good/*.dat .

$gtm_tst/com/dbcheck.csh
