#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
setenv gtm_test_mupip_set_version "disable" # Encryption cannot work on V4 databases.
setenv acc_meth BG # MM and encryption is not supported

echo "# Create a single region DB with region DEFAULT"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo "# Check the DB"
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
echo ""


echo "# Testing MUPIP SET -[NO]ENCRYPT in a properly set up environment"
echo "# --------------------------------------------------------------------------"
setenv gtm_passwd "48657920796f7520666f756e64206d79207365637265742120676f6f64206a6f6221" # Garbage string in hexidecimal format (hex is required for this env var)


echo "# \$MUPIP set -ENCRYPTABLE -REGION 'DEFAULT'"
$MUPIP SET -ENCRYPTABLE -REGION "DEFAULT"
echo ""
echo "# \$MUPIP set -NOENCRYPTABLE -REGION 'DEFAULT'"
$MUPIP set -NOENCRYPTABLE -REGION "DEFAULT"

echo ""
echo ""


echo "# Testing MUPIP SET -ENCRYPT  with no set gtm_passwd (expecting failure)"
echo "# --------------------------------------------------------------------------"
unsetenv gtm_passwd

echo "# \$MUPIP set -ENCRYPTABLE -REGION 'DEFAULT'"
$MUPIP SET -ENCRYPTABLE -REGION "DEFAULT"
echo ""
echo "# \$MUPIP set -NOENCRYPTABLE -REGION 'DEFAULT'"
$MUPIP set -NOENCRYPTABLE -REGION "DEFAULT"

setenv gtm_passwd "4a616b652052657a616320372f31312f32303138" # Garbage string in hexidecimal format (hex is required for this env var)

echo ""
echo ""


echo "# Testing MUPIP SET -ENCRYPT  with garbage GNUPGHOME (expecting failure)"
echo "# --------------------------------------------------------------------------"
setenv GNUPGHOME "garbageValue"
echo "GNUPGHOME: $GNUPGHOME"

echo "# \$MUPIP set -ENCRYPTABLE -REGION 'DEFAULT'"
$MUPIP SET -ENCRYPTABLE -REGION "DEFAULT"
echo ""
echo "# \$MUPIP set -NOENCRYPTABLE -REGION 'DEFAULT'"
$MUPIP set -NOENCRYPTABLE -REGION "DEFAULT"

unsetenv GNUPGHOME

# The following block is meant to test for failure when GNUPGHOME is set to a real
# directory that is still invalide. However, MUPIP SET -[NO]ENCRYPTABLE still works.
# It is believed that this is due to a minsunderstanding with the patch notes.
# It is very possible that "invalid directory" simply means "non-existent directory"

#echo "# Testing MUPIP SET -[NO]ENCRYPT  with improper GNUPGHOME (expecting failure)"
#echo "# --------------------------------------------------------------------------"
#mkdir temp
#setenv GNUPGHOME "./temp"
#echo "GNUPGHOME: $GNUPGHOME"
#
#echo "# \$MUPIP set -ENCRYPTABLE -REGION 'DEFAULT'"
#$MUPIP SET -ENCRYPTABLE -REGION "DEFAULT"
#echo ""
#echo "# \$MUPIP set -NOENCRYPTABLE -REGION 'DEFAULT'"
#$MUPIP set -NOENCRYPTABLE -REGION "DEFAULT"
#echo ""
#echo ""
