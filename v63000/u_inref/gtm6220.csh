#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo ">>> Journal enable is done in this test. So let's not randomly enable journaling in dbcreate.csh"
setenv gtm_test_jnl NON_SETJNL
#
echo ">>> Since we will use before images let's set BG access method"
source $gtm_tst/com/gtm_test_setbgaccess.csh

echo ">>> Let's use before images"
source $gtm_tst/com/gtm_test_setbeforeimage.csh

echo ">>> Create the database"
$gtm_tst/com/dbcreate.csh mumps

echo ">>> Enable journaling with before images"

$MUPIP set -journal="enable,on,before" -reg "*" >& mupip_set_jnl.log

# get time 10 seconds after start of journaled updates
$ydb_dist/mumps -run %XCMD 'write $zdate($$addtime^difftime($horolog,10),"DD-MON-YEAR 24:60:SS"),!' > aftertime.txt

echo ">>> Do approximately two minutes of journaled update"
$GTM << GTM_EOF
	for i=1:1:1200 set ^a(i)=i*i hang .1
GTM_EOF

# get time 10 seconds before end of journaled updates
$ydb_dist/mumps -run %XCMD 'write $zdate($$addtime^difftime($horolog,-10),"DD-MON-YEAR 24:60:SS"),!' > beforetime.txt

set beforetime=`$grep \^\[0-9\] beforetime.txt`
set aftertime=`$grep \^\[0-9\] aftertime.txt`

echo ">>> Take an extract from within the middle of the journal file"
$MUPIP journal -extract=msg1.log -before=\"$beforetime\" -after=\"$aftertime\" -fences=none -noverify -detail -forward mumps.mjl >&! jnl_extract.out

$gtm_tst/com/dbcheck.csh
