#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2003, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# C9D06-002309
\mkdir ./dir1 ; cd ./dir1
$gtm_tst/com/dbcreate.csh mumps 1
# To make the reference file consistent for before and nobefore image journaling,
# redirect the set -journal output to a file and grep only for the journal state info
$MUPIP set $tst_jnl_str -region "*" >&! mupip_set_jnl.out
$grep "GTM-I-JNLSTATE" mupip_set_jnl.out
$GTM <<EOF
do in0^pfill("set",1)
EOF
$gtm_tst/com/dbcheck.csh
cd ..
\cp -f ./dir1/mumps.mjl .
\rm -rf dir1/*.mjl dir1/*.dat dir1/*.gld
if ("ENCRYPT" == "$test_encryption") setenv gtmcrypt_config "`pwd`/dir1/gtmcrypt.cfg"
# JOURNAL EXTRACT is issued when there are no database files in the current directory.
# JOURNAL EXTRACT might need to read the database file to get the collation information.
# To skip the JOURNAL EXTRACT from reading the database file, set the env variable
# gtm_extract_nocol to non-zero value.
setenv gtm_extract_nocol 1
$MUPIP journal -extract -for mumps.mjl
if ($status) echo "TEST-E-EXTRACT. mupip journal -extract -for mumps.mjl failed!"
#
if ( "ENCRYPT" == "$test_encryption" ) setenv gtmcrypt_config `pwd`/gtmcrypt.cfg
mv mumps.mjl mumps_orig.mjl	# this way it is not in the way in case the below dbcreate decides to enable journaling
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << xyz
do ^umjrnl("mumps.mjf")
h
xyz

$GTM <<aa
do in0^pfill("ver",1)
halt
$gtm_tst/com/dbcheck.csh
