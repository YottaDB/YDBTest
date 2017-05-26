#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2011, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "External Filter to test large transaction and large global"
source $gtm_tst/com/random_extfilter.csh 1	# sets gtm_tst_ext_filter_src and gtm_tst_ext_filter_rcvr env vars
$gtm_tst/com/dbcreate.csh mumps 1 -block_size=32256 -record_size=32240
#modify the database on the source
$echoline
echo 'Add a large transaction (^a(1) to ^a(2000)) and a large global (^BigGlobal) to the database'
$echoline
$gtm_dist/mumps -run bigtrans
echo
$echoline
echo 'Contents of ^a(2000) = '
$gtm_dist/mumps -run %XCMD 'Write ^a(2000)'
$echoline
echo
$echoline
echo 'Last 5 characters of ^BigGlobal = '
$gtm_dist/mumps -run %XCMD 'Write $extract(^BigGlobal,32221,32225)'
$echoline
echo
$gtm_tst/com/dbcheck.csh -extract
