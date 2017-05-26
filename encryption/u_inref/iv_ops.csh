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

# Test the operation of various commands in regards to different IV modes.

set opensslver = `openssl version | $tst_awk -F '[ .]' '{ printf "%d%02d%s",$2,$3,$4}'`
if ( `expr "$opensslver" \>= "1001h"` ) then
	# from version 1.0.1h, OpenSSL added a check on the length for the Blowfish cipher.
	# The current key size (256 bits) is longer than the keysize Blowfish and RC5 algorithms use (128 bits)
	# One solution is to reduce the key size in plugin/gtmcrypt/gen_sym_key.sh, which we don't want to.
	# The other solution is to not pick BLOWFISHCFB/bf-cfb algorithm below, which is what this check does
	# Note 1 : It is possible that some distributions removed this check later
	# Note 2 : It is also possible that the check might be backported to earlier versions too (- in case this test fails on servers with older openssl)
	unsetenv gtm_crypt_plugin
	setenv gtm_test_exclude_encralgo BLOWFISHCFB
	echo "# Encryption algorithm re-randomized by the test" >>&! settings.csh
	source $gtm_tst/com/set_encryption_lib_and_algo.csh     >>&! settings.csh

endif
# Disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout.
setenv gtm_dirtree_collhdr_always 1

# Disable random transaction number to have predictable results in the test output.
setenv gtm_test_disable_randomdbtn 1

# Enforce M mode for simpler handling of binary data.
$switch_chset "M" >& switch_chset.log

# Prepare a few constants.
set concat_hex_dump = 'for  read line quit:$zeof  for i=2:1:$length(line," ") set p=$piece(line," ",i) write:(1=$length(p)) "0" write p'
setenv password "gtmrocks"
@ first_data_block = 3			# First block in the database that contains globals
@ block_header_size = 16		# Size of the block header
@ simple_record_size = 8		# Size of a record of type ^a=1
@ extract_label_size = 102		# Size of the extract label including delimiter
@ extract_hash_size = 66		# Size of one encryption hash stored in an extract (including delimiter)
@ extract_iv_size = 3			# Size of the field indicating IV mode in an extract (including delimiter)
@ extract_coll_size = 6			# Size of the collation field in an extract (including delimiter)
@ extract_rec_len_and_encr_size = 6	# Size of the record length + encryption hash index fields in an extract
set null_iv_hex = "00000000000000000000000000000000"

# Set the variable for encryption algorithm.
source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh

############################################################################################################
# TEST 1. Ensure that databases are being created and data in them is being encrypted with non-null IVs.   #
############################################################################################################

echo "TEST 1"

$gtm_tst/com/dbcreate.csh mumps
echo

# Dump the encryption-specific information from the database file header; it should include the IV mode.
echo "# Encryption-related fields:"
$gtm_dist/dse dump -file -all |& $grep -i encr
echo

# Write an update and decrypt it directly from the file using MUPIP DECRYPT and OpenSSL.
$gtm_dist/mumps -run %XCMD 'set ^a=1'

# Figure out the variables that we need to calculate offsets.
@ start_vbn = `$gtm_dist/dse dump -file |& $tst_awk '/VBN/ {print $7}'`
@ block_size = `$gtm_dist/dse dump -file |& $tst_awk '/Block size/ {print $8}'`
@ iv_dump_offset = (($start_vbn - 1) * 512) + ($block_size * $first_data_block)
@ data_dump_offset = $iv_dump_offset + $block_header_size

# Set IV and password in hex format for OpenSSL's enc consumption.
od -j $iv_dump_offset -N $block_header_size -tx1 mumps.dat | $gtm_exe/mumps -run %XCMD "$concat_hex_dump" > iv_hex.out
setenv iv_hex `cat iv_hex.out`
(echo $password | $gpg --homedir=$GNUPGHOME --batch --passphrase-fd 0 -d mumps_dat_key | od -tx1 | $gtm_exe/mumps -run %XCMD "$concat_hex_dump" > key_hex.out) >&! /dev/null
setenv key_hex `cat key_hex.out`

# Dump the record into a file.
$gtm_dist/mumps -run dd $data_dump_offset $simple_record_size mumps.dat > encrypted_record.out

# Decrypt the record by OpenSSL.
echo "# Record decrypted by OpenSSL:"
openssl enc -$encr_algorithm -nosalt -d -K $key_hex -iv $iv_hex -in encrypted_record.out | od -tx1
echo

# Decrypt the record by MUPIP CRYPT.
echo "# Record decrypted by MUPIP CRYPT:"
$gtm_dist/mupip crypt -decrypt -file=mumps.dat -offset=$iv_dump_offset -length=$block_size -type=db_iv | od -tx1
echo

echo "# Do the integrity check:"
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh bak1 "*.dat *.gld *.out *.cfg" mv
echo

# Encryption plug-ins within the prior version range enforced below are unstable on AIX boxes and cannot be used.
if ("AIX" != "$HOSTOS") then
	############################################################################################################
	# TEST 2. Encrypted database created with the current version cannot be downgraded.                        #
	############################################################################################################

	echo "TEST 2"

	# Choose a random prior version that supports encryption.
	echo "# Randomly choose a prior V5 version to create the database first"
	set prior_ver = `$gtm_tst/com/random_ver.csh -gte V53004 -lt V60000`
	if ("$prior_ver" =~ "*-E-*") then
		echo "No prior versions available: $prior_ver"
		exit -1
	endif
	echo "$prior_ver" > priorver.out
	source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
	source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
	echo

	# Disable mupip-set-version to V4 as that will disturb Fully Upgraded flag and in turn affect the static reference file.
	setenv gtm_test_mupip_set_version "disable"
	$gtm_tst/com/dbcreate.csh mumps 1 64 512 >&! dbcreate_V5.out

	echo "# Switch to current version"
	source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
	source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
	$GDE exit >&! gde.out
	if (-f $gtm_dbkeys) then
		$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys gtmcrypt.cfg
	endif
	echo

	# Ensure that nothing except encryption prevents the downgrade.
	echo "# Update limits and database file header"
	$gtm_dist/mumps -run %XCMD 'set ^a=1 kill ^a'
	$MUPIP integ -reg "*" -noonline >&! integ.out
	echo

	# Attempt downgrade. It should fail due to encryption.
	echo "# Try updating the database"
	echo "yes" | $gtm_dist/mupip downgrade mumps.dat -version=V5
	echo

	echo "# Do the integrity check:"
	$gtm_tst/com/dbcheck.csh
	$gtm_tst/com/backup_dbjnl.csh bak2 "*.dat *.gld *.out *.cfg" mv
	echo
endif

############################################################################################################
# TEST 3. New extract (version 9) uses non-null IVs and cannot be processed using an older version.        #
############################################################################################################

echo "TEST 3"

$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run %XCMD 'set ^a=1'
echo

# Do an extract and dump the header information.
echo "# Do an extract"
$gtm_dist/mupip extract -fo=bin extract.bin
od -j 2 -N 26 -tc extract.bin
echo

@ iv_dump_offset = $extract_label_size + $extract_hash_size + $extract_iv_size + $extract_coll_size + $extract_rec_len_and_encr_size
@ data_dump_offset = $iv_dump_offset + $block_header_size

# Set IV and password in hex format for OpenSSL's enc consumption.
od -j $iv_dump_offset -N $block_header_size -tx1 extract.bin | $gtm_exe/mumps -run %XCMD "$concat_hex_dump" > iv_hex.out
setenv iv_hex `cat iv_hex.out`
(echo $password | $gpg --homedir=$GNUPGHOME --batch --passphrase-fd 0 -d mumps_dat_key | od -tx1 | $gtm_exe/mumps -run %XCMD "$concat_hex_dump" > key_hex.out) >&! /dev/null
setenv key_hex `cat key_hex.out`

# Dump the record into a file.
$gtm_dist/mumps -run dd $data_dump_offset $simple_record_size extract.bin > encrypted_record.out

# Decrypt the record by OpenSSL.
echo "# Record decrypted by OpenSSL:"
openssl enc -$encr_algorithm -nosalt -d -K $key_hex -iv $iv_hex -in encrypted_record.out | od -tx1
echo

# Choose a random prior version that supports encryption.
echo "# Randomly choose any version prior to V62003"
set prior_ver = `$gtm_tst/com/random_ver.csh -lte V62002 -gte V53004`
if ("$prior_ver" =~ "*-E-*") then
        echo "No prior versions available: $prior_ver"
        exit -1
endif
echo "$prior_ver" > priorver.out
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
echo

# Attempt a load of the new extract.
echo "# Attempt a load"
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate_V5.out
$gtm_dist/mupip load -format=bin extract.bin
echo

echo "# Switch to current version"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
$GDE exit >&! gde.out
if (-f $gtm_dbkeys) then
	$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys gtmcrypt.cfg
endif
echo

echo "# Do the integrity check:"
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh bak3 "*.dat *.gld *.out *.bin *.cfg" mv
echo

############################################################################################################
# TEST 4. Extracts can be created using null IVs, in which case they have version 8 and can be loaded by a #
# prior version.                                                                                           #
############################################################################################################

echo "TEST 4"

$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run %XCMD 'set ^a=1'
echo

# Do an extract and dump the header information.
echo "# Do an extract"
$gtm_dist/mupip extract -fo=bin -null_iv extract.bin
od -j 2 -N 26 -tc extract.bin
echo

@ data_dump_offset = $extract_label_size + $extract_hash_size + $extract_coll_size + $extract_rec_len_and_encr_size

# Set IV and password in hex format for OpenSSL's enc consumption.
(echo $password | $gpg --homedir=$GNUPGHOME --batch --passphrase-fd 0 -d mumps_dat_key | od -tx1 | $gtm_exe/mumps -run %XCMD "$concat_hex_dump" > key_hex.out) >&! /dev/null
setenv key_hex `cat key_hex.out`

# Dump the record into a file.
$gtm_dist/mumps -run dd $data_dump_offset $simple_record_size extract.bin > encrypted_record.out

# Decrypt the record by OpenSSL.
echo "# Record decrypted by OpenSSL:"
openssl enc -$encr_algorithm -nosalt -d -K $key_hex -iv $null_iv_hex -in encrypted_record.out | od -tx1
echo

# Choose a random prior version that supports encryption.
echo "# Set prior version to V62002"
set prior_ver = "V62002"
echo "$prior_ver" > priorver.out
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
echo

# Attempt a load of the new extract.
echo "# Attempt a load"
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate_V6.out
$gtm_dist/mupip load -format=bin extract.bin

echo "# Switch to current version"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
$GDE exit >&! gde.out
echo

echo "# Do the integrity check:"
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh bak4 "*.dat *.gld *.out *.bin *.cfg" mv
echo

############################################################################################################
# TEST 5. Database created with a previous version and opened using the current version uses null IV mode  #
# and is fully operational.                                                                                #
############################################################################################################

echo "TEST 5"

# Choose a random prior version that supports encryption.
echo "# Randomly choose any version prior to V62003"
set prior_ver = `$gtm_tst/com/random_ver.csh -lte V62002 -gte V53004`
if ("$prior_ver" =~ "*-E-*") then
        echo "No prior versions available: $prior_ver"
        exit -1
endif
echo "$prior_ver" > priorver.out
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh

# Create a database using the old version.
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate_V6.out

# Switch back to the current version and make an update.
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
$GDE exit >&! gde.out
if (-f $gtm_dbkeys) then
	$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys gtmcrypt.cfg
endif
$gtm_dist/mumps -run %XCMD 'set ^a=1'
echo

# Dump the encryption-specific information from the database file header; it should include the IV mode.
echo "# Encryption-related fields:"
$gtm_dist/dse dump -file -all |& $grep -i encr
echo

# Figure out the variables that we need to calculate offsets.
@ start_vbn = `$gtm_dist/dse dump -file |& $tst_awk '/VBN/ {print $7}'`
@ block_size = `$gtm_dist/dse dump -file |& $tst_awk '/Block size/ {print $8}'`
@ iv_dump_offset = (($start_vbn - 1) * 512) + ($block_size * $first_data_block)
@ data_dump_offset = $iv_dump_offset + $block_header_size

# Set IV and password in hex format for OpenSSL's enc consumption.
(echo $password | $gpg --homedir=$GNUPGHOME --batch --passphrase-fd 0 -d mumps_dat_key | od -tx1 | $gtm_exe/mumps -run %XCMD "$concat_hex_dump" > key_hex.out) >&! /dev/null
setenv key_hex `cat key_hex.out`

# Dump the record into a file.
$gtm_dist/mumps -run dd $data_dump_offset $simple_record_size mumps.dat > encrypted_record.out

# Decrypt the record by OpenSSL.
echo "# Record decrypted by OpenSSL:"
openssl enc -$encr_algorithm -nosalt -d -K $key_hex -iv $null_iv_hex -in encrypted_record.out | od -tx1
echo

# Decrypt the record by MUPIP CRYPT.
echo "# Record decrypted by MUPIP CRYPT:"
$gtm_dist/mupip crypt -decrypt -file=mumps.dat -offset=$iv_dump_offset -length=$block_size -type=db_no_iv | od -tx1
echo

echo "# Do the integrity check:"
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh bak5 "*.dat *.gld *.out *.bin *.cfg" mv
echo

############################################################################################################
# TEST 6. Loads of extracts with null IVs into non-null-IV database as well as loads of extracts with      #
# non-null IVs into null-IV database work.                                                                 #
############################################################################################################

echo "TEST 6"

$gtm_tst/com/dbcreate.csh mumps
echo

# Write an update and decrypt it directly from the file using MUPIP DECRYPT and OpenSSL.
$gtm_dist/mumps -run %XCMD 'set ^a=1'

# Do an extract in the null IV mode.
$gtm_dist/mupip extract -fo=bin -null_iv extract.bin
echo

# Load the null-IV extract into a non-null-IV database.
$gtm_dist/mupip load -format=bin extract.bin

# Now do a regular extract.
$gtm_dist/mupip extract -fo=bin extract2.bin
echo

# Choose a random prior version that supports encryption.
echo "# Randomly choose any version prior to V62003"
set prior_ver = `$gtm_tst/com/random_ver.csh -lte V62002 -gte V53004`
if ("$prior_ver" =~ "*-E-*") then
        echo "No prior versions available: $prior_ver"
        exit -1
endif
echo "$prior_ver" > priorver.out
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate_V6.out
echo

echo "# Switch to current version"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
$GDE exit >&! gde.out
if (-f $gtm_dbkeys) then
	$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys gtmcrypt.cfg
endif

# Try to load the non-null-IV extract into a null-IV database.
$gtm_dist/mupip load -format=bin extract2.bin

echo "# Do the integrity check:"
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh bak6 "*.dat *.gld *.out *.bin *.cfg" mv
echo

############################################################################################################
# TEST 7. Backups use non-null IVs and can be loaded into database with either null or non-null IVs.       #
############################################################################################################

echo "TEST 7"

$gtm_tst/com/dbcreate.csh mumps
echo

$gtm_dist/mumps -run %XCMD 'set ^a=1'

# Do an incremental backup.
$gtm_dist/mupip backup -bytestream DEFAULT mumps.dat.bak

$gtm_tst/com/backup_dbjnl.csh bak7a "*.dat" mv

od -N 26 -tc mumps.dat.bak
echo

$gtm_tst/com/dbcreate.csh mumps
echo

# Restore the backup.
$MUPIP restore mumps.dat mumps.dat.bak
echo

echo "# Do the integrity check:"
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh bak7b "*.dat" mv
echo

# Choose a random prior version that supports encryption.
echo "# Randomly choose any version prior to V62003"
set prior_ver = `$gtm_tst/com/random_ver.csh -lte V62002 -gte V53004`
if ("$prior_ver" =~ "*-E-*") then
        echo "No prior versions available: $prior_ver"
        exit -1
endif
echo "$prior_ver" > priorver.out
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate_V6.out
echo

echo "# Switch to current version"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
$GDE exit >&! gde.out
if (-f $gtm_dbkeys) then
	$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys gtmcrypt.cfg
endif

# Restore the backup now that the database uses null IV mode.
$MUPIP restore mumps.dat mumps.dat.bak
echo

echo "# Do the integrity check:"
$gtm_tst/com/dbcheck.csh
echo

@ iv_dump_offset = 3484
@ data_dump_offset = $iv_dump_offset + $block_header_size

# Set IV and password in hex format for OpenSSL's enc consumption.
od -j $iv_dump_offset -N $block_header_size -tx1 mumps.dat.bak | $gtm_exe/mumps -run %XCMD "$concat_hex_dump" > iv_hex.out
setenv iv_hex `cat iv_hex.out`
(echo $password | $gpg --homedir=$GNUPGHOME --batch --passphrase-fd 0 -d mumps_dat_key | od -tx1 | $gtm_exe/mumps -run %XCMD "$concat_hex_dump" > key_hex.out) >&! /dev/null
setenv key_hex `cat key_hex.out`

# Dump the record into a file.
$gtm_dist/mumps -run dd $data_dump_offset $simple_record_size mumps.dat.bak > encrypted_record.out

# Decrypt the record by OpenSSL.
echo "# Record decrypted by OpenSSL:"
openssl enc -$encr_algorithm -nosalt -d -K $key_hex -iv $iv_hex -in encrypted_record.out | od -tx1

$gtm_tst/com/backup_dbjnl.csh bak7c "*.dat *.gld *.out *.bin *.cfg" mv
echo

############################################################################################################
# TEST 8. Journal files use non-null IVs for logical and AIMG records.                                     #
############################################################################################################

echo "TEST 8"

$gtm_tst/com/dbcreate.csh mumps
echo

# Set journaling.
$gtm_dist/mupip set -journal="on,enable,before" -reg "*"

# Set an update and do a DSE operation to produce an AIMG record.
$gtm_dist/mumps -run %XCMD 'set ^a=1'
$gtm_dist/dse change -block=3 -tn=2

# Dump the journal header information to ensure that it is using non-null IVs.
$gtm_dist/mupip journal -show=header -backward mumps.mjl |& $grep -E "(crypted|IV)"
echo

# Create a journal extract.
$gtm_dist/mupip journal -extract -forward mumps.mjl -detail
echo

# Set journaling-related variables.
@ jrec_prefix_length = 24	# Length of a journal record prefix
@ jrec_suffix_length = 4	# Length of a journal record suffix
@ log_rec_header_length = 24	# Length of a logical journal record header
set set_iv_offset = `$tst_awk '/SET/ {print $1}' mumps.mjf`
@ set_iv_offset = `$gtm_tst/com/radixconvert.csh h2d $set_iv_offset | $tst_awk '{print $5}'`
set set_full_rec_length = `$tst_awk -F '( |\\[|\\])' '/SET/ {print $3}' mumps.mjf`
@ set_full_rec_length = `$gtm_tst/com/radixconvert.csh h2d $set_full_rec_length | $tst_awk '{print $5}'`
@ set_rec_length = $set_full_rec_length - $jrec_prefix_length - $log_rec_header_length - $jrec_suffix_length
@ set_iv_length = 3		# Length of data from which an IV for logical journal records is derived
@ set_data_offset = $set_iv_offset + $log_rec_header_length + $jrec_prefix_length
if (12 < $set_rec_length) then
	@ set_rec_length = 12	# If due to alignment the record size turned out bigger than expected, correct it
endif

# Since the IV is based on the length field in the jrec_prefix structure, which is bytes 2--4 of the structure,
# temporarily update the variable, so we can get the proper hex string for OpenSSL's use.
@ set_iv_offset++
od -j $set_iv_offset -N $set_iv_length -tx1 mumps.mjl | $gtm_exe/mumps -run %XCMD "$concat_hex_dump" > iv_hex.out
@ set_iv_offset--
setenv iv_hex `cat iv_hex.out`
if ("BIG_ENDIAN" == "$gtm_endian") then
	setenv iv_hex "00${iv_hex}"
else
	setenv iv_hex "${iv_hex}00"
endif
setenv iv_hex "${iv_hex}${iv_hex}${iv_hex}${iv_hex}"
(echo $password | $gpg --homedir=$GNUPGHOME --batch --passphrase-fd 0 -d mumps_dat_key | od -tx1 | $gtm_exe/mumps -run %XCMD "$concat_hex_dump" > key_hex.out) >&! /dev/null
setenv key_hex `cat key_hex.out`

# Dump the record into a file.
$gtm_dist/mumps -run dd $set_data_offset $set_rec_length mumps.mjl > encrypted_record.out

# Decrypt the record by OpenSSL.
echo "# Record decrypted by OpenSSL:"
openssl enc -$encr_algorithm -nosalt -d -K $key_hex -iv $iv_hex -in encrypted_record.out | od -tx1
echo

# Decrypt the record by MUPIP CRYPT.
echo "# Record decrypted by MUPIP CRYPT:"
$gtm_dist/mupip crypt -decrypt -file=mumps.mjl -offset=$set_iv_offset -length=$set_full_rec_length -type=jnl_log_iv | od -tx1
echo

# Set journaling-related variables.
@ non_log_rec_header_length = 16	# Length of a non-logical journal record header
set aimg_rec_offset = `$tst_awk '/AIMG/ {print $1}' mumps.mjf | $tail -1`
@ aimg_rec_offset = `$gtm_tst/com/radixconvert.csh h2d $aimg_rec_offset | $tst_awk '{print $5}'`
@ aimg_iv_offset = $aimg_rec_offset + $jrec_prefix_length + $non_log_rec_header_length
set aimg_full_rec_length = `$tst_awk -F '( |\\[|\\])' '/AIMG/ {print $3}' mumps.mjf | $tail -1`
@ aimg_full_rec_length = `$gtm_tst/com/radixconvert.csh h2d $aimg_full_rec_length | $tst_awk '{print $5}'`
@ aimg_iv_length = 16			# Length of data from which an IV for non-logical journal records is taken
@ aimg_rec_length = $simple_record_size
@ aimg_data_offset = $aimg_iv_offset + $aimg_iv_length

# Set the IV and key hex values.
od -j $aimg_iv_offset -N $aimg_iv_length -tx1 mumps.mjl | $gtm_exe/mumps -run %XCMD "$concat_hex_dump" > iv_hex.out
setenv iv_hex `cat iv_hex.out`
(echo $password | $gpg --homedir=$GNUPGHOME --batch --passphrase-fd 0 -d mumps_dat_key | od -tx1 | $gtm_exe/mumps -run %XCMD "$concat_hex_dump" > key_hex.out) >&! /dev/null
setenv key_hex `cat key_hex.out`

# Dump the record into a file.
$gtm_dist/mumps -run dd $aimg_data_offset $aimg_rec_length mumps.mjl > encrypted_record.out

# Decrypt the record by OpenSSL.
echo "# Record decrypted by OpenSSL:"
openssl enc -$encr_algorithm -nosalt -d -K $key_hex -iv $iv_hex -in encrypted_record.out | od -tx1
echo

# Decrypt the record by MUPIP CRYPT.
echo "# Record decrypted by MUPIP CRYPT:"
$gtm_dist/mupip crypt -decrypt -file=mumps.mjl -offset=$aimg_rec_offset -length=$aimg_full_rec_length -type=jnl_nonlog_iv | od -tx1
echo

echo "# Do the integrity check:"
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh bak8 "*.dat *.gld *.out *.cfg" mv
