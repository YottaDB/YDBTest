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


setenv gtm_passwd "1AF39D"

echo "# \$MUPIP set -ENCRYPTABLE -REGION 'DEFAULT'"
$MUPIP SET -ENCRYPTABLE -REGION "DEFAULT"
echo ""

echo "# \$MUPIP set -NOENCRYPTABLE -REGION 'DEFAULT'"
$MUPIP set -NOENCRYPTABLE -REGION "DEFAULT"
echo ""

#unsetenv gtm_passwd
#
#echo "# \$MUPIP set -ENCRYPTABLE -REGION 'DEFAULT'"
#$MUPIP SET -ENCRYPTABLE -REGION "DEFAULT"
#echo ""
#
#echo "# \$MUPIP set -NOENCRYPTABLE -REGION 'DEFAULT'"
#$MUPIP set -NOENCRYPTABLE -REGION "DEFAULT"
#echo ""
