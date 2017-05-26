#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "User Name          : " `whoami`
echo "Version            : " $1
echo "Image              : " $2
echo "Calling User       : " $5

source $gtm_com/gtm_cshrc.csh
setenv gtm_tst $4
source $gtm_tst/com/remote_getenv.csh $3

version $1 $2
echo $gtm_exe
setenv GTM "$gtm_exe/mumps -direct"
cd $3
setenv gtmgbldir "mumps.gld"

set calling_user = $5

# Creating GNUPGHOME inside test output directory fails due to too long path on a few servers (thunder and bolt)
setenv GNUPGHOME /tmp/__${USER}_$gtm_tst_out
echo "ssh $user@$HOST:ar 'rm -rf $GNUPGHOME'"	>> $tst_general_dir/cleanup.csh
setenv GTMXC_gpgagent $gtm_exe/plugin/gpgagent.tab
setenv gtm_passwd `echo "gtmtest1" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
echo "GNUPGHOME = $GNUPGHOME"
echo "GTMXC_gpgagent = $GTMXC_gpgagent"
echo "gtm_passwd = $gtm_passwd"

setenv gtm_pubkey $cwd/$USER@fnis.com_pubkey.txt
# Create a fresh key
$gtm_tst/$tst/u_inref/call_gen_keypair.csh

mkdir ${USER}_files ; mv gpg_agents_*.out gpg_agents_*.pids gen_keypair_${USER}.out ${USER}_files
chmod -R 777 ${USER}_files

# Create a text file to be given as the input for the import_and_sign_key.sh as the script is an interactive one
cat << CAT_EOF >> input.txt
Y
$gtmtest1
CAT_EOF

# Capture the list of keys before importing and signing
$gpg --homedir=$GNUPGHOME --list-keys >&! before_import_list_keys.out

echo "#### Import the pubkey.asc ####"
$gtm_tst_ver_gtmcrypt_dir/import_and_sign_key.sh $tst_general_dir/tmp/pubkey.asc gtm@fnis.com < input.txt >&! import_and_sign.out
set stat = $status
if ($stat) then
	echo "Import and/or Signing failed. Please see import_and_sign.out for more details"
else
	echo "#### Import successful ####"
endif

# Capture the list of keys before importing and signing. This should contain the above user id
# in the imported list
$gpg --homedir=$GNUPGHOME --list-keys >&! after_import_list_keys.out

# As this GNUPGHOME is created as gtmtest1 change the permission
chmod -R 777 $GNUPGHOME
$gtm_tst/com/reset_gpg_agent.csh
