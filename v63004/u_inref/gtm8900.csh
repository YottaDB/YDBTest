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

echo "# \$MUPIP set -ENCRYPTABLE -region="DEFAULT""
$MUPIP set -ENCRYPTABLE -region="DEFAULT"
$MUPIP set -ENCRYPTABLE -file="mumps.dat"
#These errors seems to be unrelated to the reasons for failure described in the patch
#%YDB-E-CLIERR, Assignment is not allowed for this option : REGION
#%YDB-E-CLIERR, Assignment is not allowed for this option : FILE

echo "# \$MUPIP set -NOENCRYPTABLE -region="DEFAULT""
$MUPIP set -NOENCRYPTABLE -region="DEFAULT"
$MUPIP set -NOENCRYPTABLE -file="mumps.dat"
#These errors seems to be unrelated to the reasons for failure described in the patch
#%YDB-E-CLIERR, Assignment is not allowed for this option : REGION
#%YDB-E-CLIERR, Assignment is not allowed for this option : FILE

$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif

