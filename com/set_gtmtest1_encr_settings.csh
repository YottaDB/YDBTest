#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# For multi-user tests (locks/multi_user_lock and mupjnl/test_extract_show_select), we need to set up the encryption configuration
# (gtm_passwd, gtmcrypt_config / gtm_dbkeys) for the $gtmtest1 user. This script sets up a file containing the relevant variables
# that can be sourced in the requisite places before doing the actual MUPIP / MUMPS operation.

if ( $# != 5 ) then
	echo "Usage: $0 <settings file(output)> <database name> <remote key> <remote gtmcrypt_config> <remote gtm_dbkeys>"
	exit 1
endif

set res_file=$1
set dat_file=$2
set key_file=$3
set dbk_file=$4
set dbk_file_old=$5

touch $res_file

if ( "ENCRYPT" != "$test_encryption" ) exit 0

set gtmtest1_gnupghome = "$gtm_com/gnupg_${gtmtest1}"

# Below use of defaults.csh is to define $gt_cc_compiler etc. needed later by modconfig.csh
cat << CAT_EOF > $res_file
touch $dbk_file
setenv gtm_obfuscation_key $gtmtest1_gnupghome/gtmtest1@fnis.com_pubkey.txt
setenv gtm_pinentry_log /tmp/__${gtmtest1}_pinentry.log
setenv gtm_passwd \`echo $gtmtest1 | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '\`
source $gtm_tst/com/defaults.csh $gtm_tst/com/defaults_common_csh
$gtm_tst/com/modconfig.csh $dbk_file append-keypair $dat_file $key_file

if ($dat_file !~ /*) set dat_file = $PWD/$dat_file
if ($key_file !~ /*) set key_file = $PWD/$key_file
echo "dat $dat_file" >>&! $dbk_file_old
echo "key $key_file" >>&! $dbk_file_old

setenv GNUPGHOME  $gtmtest1_gnupghome
setenv gtmcrypt_config $dbk_file
setenv gtm_dbkeys $dbk_file_old
CAT_EOF

exit 0
