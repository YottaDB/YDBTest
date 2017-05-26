#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#!/usr/local/bin/tcsh -f

# A whitebox test case to do partial reencryption on one server, endian convert and
# continue reencryption with the same key on an opposite endian server

# Basic preparation for the test
source $gtm_tst/$tst/u_inref/endiancvt_prepare.csh

source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcreate.csh mumps 1 255 1000 $coll_arg
source $gtm_tst/com/bakrestore_test_replic.csh
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; source coll_env.csh 1; source $gtm_tst/com/bakrestore_test_replic.csh ; $gtm_tst/com/dbcreate_base.csh mumps 1 255 1000 $coll_arg ; source $gtm_tst/com/bakrestore_test_replic.csh"

$gtm_exe/mumps -run populate

$tst_awk -F '[/"]' '{if (/dat:/) {dat = $(NF-1)};if (dat == "") next; if (/key:/) {map[dat] = map[dat]" "$(NF-1)}} END {for (i in map) print i " : " map[i]}' gtmcrypt.cfg >& gtmcrypt_cfg.map
set keys = `$tst_awk -F : '/^mumps.dat/ {print $2}' gtmcrypt_cfg.map`

cat >&! reorg_encrypt.csh << CAT_EOF
set setcomplete = \$1
\$MUPIP reorg -encrypt=\$2 -region DEFAULT
if (1 == \$setcomplete) \$MUPIP set -encryptioncomplete -region DEFAULT
CAT_EOF

$rcp reorg_encrypt.csh "$tst_remote_host":$SEC_SIDE

# test_case_count signals the number of blocks to re-encrypt and exit
setenv gtm_white_box_test_case_number 123	# WBTEST_SLEEP_IN_MUPIP_REORG_ENCRYPT
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_count 10

echo "# Partially encrypt with key1 (white box test case) and endian convert the database"
echo "# Expect the set -encryptioncomplete to fail, since re-encryption is not complete due to the whitebox test case"
source reorg_encrypt.csh 1 $keys[1]
$gtm_tst/$tst/u_inref/integ_check.csh mumps.dat
$MUPIP endiancvt mumps.dat < yes.txt

unsetenv gtm_white_box_test_case_enable

echo "# Ship the db to the remote side and try to continue reencryption with key1"
$rcp mumps.dat "$tst_remote_host":$SEC_SIDE
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; $gtm_tst/$tst/u_inref/integ_check.csh mumps.dat ; source reorg_encrypt.csh 1 $keys[1] ; $gtm_tst/$tst/u_inref/integ_check.csh mumps.dat"

echo "# Now attempt to re-encrypt with key2"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; source reorg_encrypt.csh 1 $keys[2] ; $gtm_tst/$tst/u_inref/integ_check.csh mumps.dat"

echo "# Ship the db to the primary side and endian convert"
$rcp "$tst_remote_host":$SEC_SIDE/mumps.dat mumps.dat
$MUPIP endiancvt mumps.dat < yes.txt

echo "# Attempt re-encryption with key2 - Expect already encrypted with the desired key message"
source reorg_encrypt.csh 0 $keys[2]

echo "# Attempt re-encryption with key1 - Expect it to succeed"
source reorg_encrypt.csh 1 $keys[1]

$gtm_exe/mumps -run %XCMD 'for i=1:10:100 write ^aglobal(i),!'
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcheck.csh
source $gtm_tst/com/bakrestore_test_replic.csh
