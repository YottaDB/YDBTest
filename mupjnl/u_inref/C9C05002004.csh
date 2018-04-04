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

#Test Case #40 :  (C9C05-002004)
unset backslash_quote
alias check_mjf 'unset echo; $tst_awk -f $gtm_tst/$tst/inref/extract.awk -v "user=$USER" -v "host=$HOST:r:r:r" \!:* | sed '"'"'s/\\/%/g;s/.*:://g'"'"' | $tst_awk -F% -f $gtm_tst/$tst/inref/extract_summary.awk'

$gtm_tst/com/dbcreate.csh .
set echo
$gtm_tst/com/jnl_on.csh
cp mumps.dat bak.dat

$GTM <<  EOF
s ^state=1
h 1
s ^dummy=1
h 2
EOF

$gtm_tst/com/jnl_on.csh

$GTM <<  EOF
s ^state=2
h 1
s ^dummy=2
h 2
EOF

cp bak.dat mumps.dat
$MUPIP journal -recov -for mumps.mjl
$MUPIP journal -extract -for mumps.mjl
check_mjf mumps.mjf
$GTM << EOF
d ^%G

*

h
EOF

$gtm_tst/com/dbcheck.csh
#Pre-V44 result (with pro): YDB-E-JNLRECFMT, Journal file record format error encountered
#                           YDB-E-NORECOVERERR, Not all specified recovery was done.
#Expected result: Extraction successful, we should see all updates in the extract file (updates that were in the last generation)
#Return status: success
