#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script takes the current user's database key as an input, decrypts it, and re-encrypts it with gtmtest1's public key.
# The script is used whenever a test involes a multi-user interaction and gtmtest1 needs to access the database files.
#
# Usage :
#  $1 - key to be encrypted for gtmtest1
#  $2 - output file where the encrypted key has to be stored
#  $gtmtest1 contains the username of the other user, which, for all practical reasons, is gtmtest1

if ("ENCRYPT" != "$test_encryption") exit

if ($# < 2) then
	echo "Usage : $0 <Key to be encrypted for gtmtest1> <output file where the encrypted key has to be stored>"
	exit
endif

set in_key = $1
set out_key = $2

# Record permissions and timestamps of $GNUPGHOME files before the import.
set fulltime = ""
if ("Linux" == $HOSTOS) set fulltime="--full-time"
ls -lart $fulltime $GNUPGHOME >&! ls_gtmtest_GNUPGHOME_b4IMPORT.out

# Ensure that gtmtest1's public key file exists.
set pubkey = "/usr/library/com/gnupg_gtmtest1/$gtmtest1@fnis.com_pubkey.txt"
if (!(-e ${pubkey})) then
	echo "TEST-E-FAIL ${pubkey} does not exist!"
	exit 1
endif

# Import gtmtest1's public key into the current user's keyring.
printf "%s\n%s\n" y $gtm_test_gpghome_passwd | $gtm_tst_ver_gtmcrypt_dir/import_and_sign_key.sh $pubkey $gtmtest1 >&! import_gtmtest1.out

# Record permissions and timestamps of $GNUPGHOME files after the import.
ls -lart $fulltime $GNUPGHOME >&! ls_gtmtest_GNUPGHOME_afterIMPORT

# Wait for the keyring to be updated with the imported information. Although the above import command is run in foreground, we have
# evidence that files like pubring.gpg in $GNUPGHOME are updated a few milliseconds later. With a certain timing, we could have the
# subsequent encryption commands fail. See <decryption_fails_C9K05003270_gpg_late_key_creation> for more details.
@ cntr = 1
while ($cntr < 10)
	set lk_outfile = list_keys_`date +%H%M%S`.out
	$gpg --homedir=$GNUPGHOME --list-keys >&! $lk_outfile
	$grep "$gtmtest1@fnis.com" $lk_outfile >>&! grep_on_listkeys.out
	if (0 == $status) break
	@ cntr++
	sleep 1
end

# Encrypt the symmetric database key with the now-signed public key of gtmtest1, so that gtmtest1 can use the database as well.
echo $gtm_test_gpghome_passwd | $gtm_tst_ver_gtmcrypt_dir/encrypt_sign_db_key.sh $in_key $out_key $gtmtest1 >&! encrypt_for_gtmtest1.out

# Dump gpg --list-keys output for debugging purposes.
$gpg --homedir=$GNUPGHOME --list-keys >&! list_keys.out
