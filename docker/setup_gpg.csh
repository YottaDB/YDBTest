#!/bin/tcsh -fe
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
mkdir /usr/library/com
chown gtmtest:gtc /usr/library/com
chmod 775 /usr/library/com
setenv GNUPGHOME /usr/library/com/gnupg
setenv gtm_pubkey $GNUPGHOME/gtm@fnis.com_pubkey.txt
setenv gtm_dist /usr/library/V999_R999/dbg
cp $gtm_dist/plugin/gtmcrypt/gen_keypair.sh .
# Create temp copy of gen_keypair.sh: Remove passphrase related lines and just export the var here
# We don't have an tty to be able to prompt for a password while building this
sed -i '80,89d' gen_keypair.sh
chmod +x gen_keypair.sh
setenv passphrase "ydbrocks"
./gen_keypair.sh gtm@fnis.com gtm
rm ./gen_keypair.sh
chown -R gtmtest:gtc $GNUPGHOME
cd $GNUPGHOME
cp -a /usr/library/gtm_test/T999/com/pinentry-test-gtm.sh .
echo "no-secmem-warning" >> gpg.conf
echo "no-permission-warning" >> gpg.conf
mv gpg-agent.conf gpg-agent.conf.bak
awk '/pinentry-program/{gsub(/\/.*/,"'$PWD'/pinentry-test-gtm.sh")};{print}' gpg-agent.conf.bak > gpg-agent.conf
echo 'no-use-standard-socket' >> gpg-agent.conf
unsetenv GNUPGHOME
setenv gtm_chset M
setenv LC_ALL C
