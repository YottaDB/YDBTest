#!/usr/local/bin/tcsh
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
# This module is derived from FIS GT.M.
#################################################################

$gtm_tst/com/dbcreate.csh .
if (-e mumps.mjl) then
	mv mumps.mjl mumps.mjl_save
endif
$MUPIP set -journal="enable,on,before" -reg "*"
$GTM << EOF
d ^jnlrecm
d ^jnlrecm
h
EOF
$gtm_exe/mumps -run jnlrecm
$MUPIP journal -extract -for -detail mumps.mjl
echo "Check that the offset + len matches the next offset (i.e. no records are omitted, and len is correct)"
$gtm_exe/mumps -run offset > offset.out
$grep ERROR offset.out
$tst_awk -f $gtm_tst/$tst/inref/extract.awk -v "detail=1" -v "user=$USER" -v "host=$HOST:r:r:r" mumps.mjf > mumps.list
$grep -vE "EPOCH|PBLK" mumps.list  | sed 's/^[^ ]* //g' > detail_extract.mjf
diff detail_extract.mjf $gtm_tst/$tst/outref/detail_extract_mjf.txt >/dev/null
if ($status) then
	echo "TEST-E-DETAIL_EXTRACT check detail_extract.mjf $gtm_tst/$tst/outref/detail_extract_mjf.txt"
endif
$gtm_tst/com/dbcheck.csh
