#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#This subtest tests mupip extract behavior with standalone database and while doing
# parallel GTM updates without gtm_passwd.

# 'go' format is not supported in UTF-8 mode
# Since the intent of the subtest is to explicitly check extract in zwr, go and binary format, it is forced to run in M mode
$switch_chset M >&! switch_chset.out
setenv save_gtm_passwd $gtm_passwd
$gtm_tst/com/dbcreate.csh mumps 1

$GTM << EOF
d fill1^myfill("set")
d fill1^myfill("ver")
h
EOF

echo "--------------------------------------------------------------------------------------------------"
echo "Try extracting database without gtm_passwd and expect error message"
echo "--------------------------------------------------------------------------------------------------"
echo "unsetenv gtmpasswd"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_passwd gtm_passwd
echo "##################################"
echo "mupip extract -fo=bin ext1.bin"
$MUPIP extract -fo=bin ext1.bin
echo "##################################"
echo "mupip extract -fo=zwr ext1.zwr"
$MUPIP extract -fo=zwr ext1.zwr
echo "##################################"
echo "mupip extract -fo=go ext1.go"
$MUPIP extract -fo=go ext1.go

mv  mumps.dat mumps.dat_1
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_passwd gtm_passwd $save_gtm_passwd
$MUPIP create
echo "--------------------------------------------------------------------------------------------------"
echo "Try extracting while doing parallel GTM updates without gtm_passwd and expect error message"
echo "--------------------------------------------------------------------------------------------------"
setenv gtm_test_dbfill "SLOWFILL"
setenv gtm_test_jobcnt 1
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep 5
source $gtm_tst/com/unset_ydb_env_var.csh ydb_passwd gtm_passwd
echo "##################################"
echo "mupip extract -fo=bin ext2.bin"
$MUPIP extract -fo=bin ext2.bin
echo "##################################"
echo "mupip extract -fo=zwr ext2.zwr"
$MUPIP extract -fo=zwr ext2.zwr
echo "##################################"
echo "mupip extract -fo=go ext2.go"
$MUPIP extract -fo=go ext2.go

echo "--------------------------------------------------------------------------------------------------"
echo "Try extracting while doing parallel GTM updates with wrong gtm_passwd and expect error message"
echo "--------------------------------------------------------------------------------------------------"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_passwd gtm_passwd `echo "badvalue" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -d " " -f3`
$gtm_tst/com/reset_gpg_agent.csh
echo "##################################"
echo "mupip extract -fo=bin ext3.bin"
$MUPIP extract -fo=bin ext3.bin
echo "##################################"
echo "mupip extract -fo=zwr ext3.zwr"
$MUPIP extract -fo=zwr ext3.zwr
echo "##################################"
echo "mupip extract -fo=go ext3.go"
$MUPIP extract -fo=go ext3.go

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_passwd gtm_passwd $save_gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
$gtm_tst/com/endtp.csh >>&! imptp.out

mv mumps.dat mumps.dat_2

# The below test is to verify how MUPIP EXTRACT on an unencrypted region with password not set behaves when the
# GLD contains a mix of encrypted and unencrypted regions. Depending on the ordering of the encrypted and unencrypted
# regions either an error will be issued or the extract will happen successfully on the unencrypted region
# (a) DEFAULT is unencrypted and AREG is encrypted
#	In this case, MUPIP EXTRACT on a global contained in DEFAULT will successfully do the extract
# (b) DEFAULT is encrypted and AREG is unencrypted
# 	In this case, MUPIP EXTRACT on a global contained in AREG will error out.
# The issue is that MUPIP EXTRACT -SELECT uses op_gvorder to determine the list of global names that satisfy the select list.
# Given a global name, op_gvorder will hop over to other databases if necessary (depending on the .gld name mapping) to find
# the next available global.
$GDE <<EOF
add -name a* -reg=AREG
add -reg AREG -d=ASEG
add -seg ASEG -file=a.dat
EOF

$MUPIP create

$GTM << EOF
d fill1^myfill("set")
d fill1^myfill("ver")
h
EOF

echo "-----------------------------------------------------------------------------------------"
echo "Try binary extract with select qualifier to extract gloabl from unencrypted region (AREG)"
echo "-----------------------------------------------------------------------------------------"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_passwd gtm_passwd
echo "mupip extract -fo=bin -select=a* ext4.bin"
$MUPIP extract -fo=bin -select="a*" ext4.bin

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_passwd gtm_passwd $save_gtm_passwd

$gtm_tst/com/backup_dbjnl.csh "back1" "*.dat" mv
$GDE <<EOF
ch -s default -noencr
ch -s aseg -encr
EOF
setenv gtm_encrypt_notty "--no-permission-warning"
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 new_a_key $user_emailid >>& encrypt_db_key.out
unsetenv gtm_encrypt_notty
$gtm_tst/com/modconfig.csh gtmcrypt.cfg append-keypair $PWD/a.dat $PWD/new_a_key

$MUPIP create
$GTM << EOF
s ^a=10
s ^b=20
EOF

echo "--------------------------------------------------------------------------------------------"
echo "Try binary extract with select qualifier to extract global from unencrypted region (DEFAULT)"
echo "--------------------------------------------------------------------------------------------"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_passwd gtm_passwd
echo "mupip extract -fo=bin -select=b* ext5.bin"
$MUPIP extract -fo=bin -select="b*" ext5.bin
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_passwd gtm_passwd $save_gtm_passwd
$gtm_tst/com/dbcheck.csh
