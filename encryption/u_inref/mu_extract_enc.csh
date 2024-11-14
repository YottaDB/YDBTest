#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test mupip load and extract operations between encrypted and un-encrypted databases
#

setenv ydb_msgprefix	"GTM"	# So can run the test under GTM or YDB and have same output
setenv ydb_prompt	"GTM>"	# So can run the test under GTM or YDB and have same output

# adding random spanning regions functionality to this test is more work for very little (if any) payoff.
# hence disabling this scheme here.
setenv gtm_test_spanreg 0

if (! $?gtm_test_replay) then
	set extr_enc_prior_ver = `$gtm_tst/com/random_ver.csh -gte V63002`
	if ("$extr_enc_prior_ver" =~ "*-E-*") then
		echo "The requested prior version is not available: $extr_enc_prior_ver"
		exit 1
	endif
	set randcurver = `$gtm_exe/mumps -run rand 4`
	if (0 == $randcurver) then
		# Randomly choose to do everything with current version (25% of the time)
		set extr_enc_prior_ver = "$tst_ver"
	endif
	set randglobal = `$gtm_exe/mumps -run rand 3`
	if (0 == $randglobal) then
		# Both globals go to encrypted regions
		setenv global1 aglobal
		setenv global2 mglobal
	else if (1 == $randglobal) then
		# Both globals go to non-encrypted regions
		setenv global1 yglobal
		setenv global2 zglobal
	else
		# The globals go to both encrypted and non-encrypted regions
		setenv global1 aglobal
		setenv global2 yglobal
	endif
	echo "setenv extr_enc_prior_ver $extr_enc_prior_ver"	>>&! settings.csh
	echo "setenv global1 $global1"				>>&! settings.csh
	echo "setenv global2 $global2"				>>&! settings.csh
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $extr_enc_prior_ver

setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode as we are switching to a prior version and that can cause database file
				# to be created in a future version relative to the current prior version.

echo "# Switch to the random version"
source $gtm_test/$tst_src/com/switch_gtm_version.csh $extr_enc_prior_ver $tst_image
echo "# Create databases with encryption"
$gtm_tst/com/dbcreate.csh mumps 3 >&! dbcreate_orig.out
echo "# Create two more regions and db without encryption"
cp $gtm_tst/encryption/inref/temp.gde .
$GDE_SAFE @temp.gde >&! gde_encr_noencr_1.out
$MUPIP create -reg=ZREG
$MUPIP create -reg=YREG

echo "# Update a few random globals"
$GTM << EOF
for i=1:5:2000  s (^$global1("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv",i),^$global2("This is a random global",i))=i
for i=851:5:926  K ^$global1("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv",i)
h
EOF

#
#
echo "# Extract in binary format"
$MUPIP extract extr.bin -format=binary >&! extract_orig.out
if ($status) then
	echo "TEST-E-EXTRACT : binary extract failed. Check extract_orig.out"
	exit 1
endif
$gtm_tst/com/dbcheck.csh >&! dbcheck_orig.out
$gtm_tst/com/backup_dbjnl.csh bak1 "*.dat *.gld" mv

$echoline
echo "# Switch to the current version and create encrypted database"
source $gtm_test/$tst_src/com/switch_gtm_version.csh $tst_ver $tst_image
$gtm_tst/com/dbcreate.csh mumps 1
echo "## Load the binary extract into the encrypted database"
$MUPIP load -fo=binary extr.bin >&! load_encrypted_db.out
$grep -v 'Label =' load_encrypted_db.out
$gtm_tst/com/backup_dbjnl.csh bak2 "*.dat *.gld" mv

$echoline
echo "# Create a non-encrypted database"
setenv gtmgbldir mumps
$GDE_SAFE exit >&! gde_noencr.out
$MUPIP create
echo "# Load the binary extract into the non-encrypted database"
$MUPIP load -fo=binary extr.bin >&! load_unencrypted_db.out
$grep -v 'Label ='  load_unencrypted_db.out
echo "## Extract from unencrypted database now to be later loaded into a mix of encrypted and non-encrypted db"
$MUPIP extract extrunenc.bin -fo=binary >&! extract_unencrypted_db.out
if ($status) then
	echo "TEST-E-EXTRACT : binary extract failed. Check extract_unencrypted_db.out"
	exit 1
endif
$gtm_tst/com/backup_dbjnl.csh bak3 "*.dat *.gld" mv

$echoline
echo "# Create a mix of encrypted and non-encrypted datbases"
$gtm_tst/com/dbcreate.csh mumps 2
cat << EOF >&! mu_extract_env_mix_encr_noencr_2.gde
add -name y* -reg=YREG
add -reg YREG -dyn=YSEG
add -seg YSEG -file=y.dat
EOF
$GDE_SAFE @mu_extract_env_mix_encr_noencr_2.gde >&! gde_encr_noencr_2.out
$MUPIP create -reg=YREG
echo "# Load the binary extract into this mixed databases"
$MUPIP load -fo=binary extr.bin >&! load_mixed_db.out
$grep -v 'Label =' load_mixed_db.out
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh bak4 "*.dat *.gld" mv

$echoline
echo "## Load extract from unencrypted db into a mix of unencrypted and encrypted database files"
$gtm_tst/com/dbcreate.csh mumps 2
cat << EOF >&! mu_extract_env_mix_encr_noencr_3.gde
add -name m* -reg=MREG
add -reg MREG -dyn=MSEG
add -seg MSEG -file=m.dat
EOF
$GDE_SAFE @mu_extract_env_mix_encr_noencr_3.gde >&! gde_encr_noencr_3.out
$MUPIP create -reg=MREG
$MUPIP load -fo=binary extrunenc.bin >&! load_mixed_db_case2.out
$grep -v 'Label =' load_mixed_db_case2.out

$gtm_tst/com/dbcheck.csh
