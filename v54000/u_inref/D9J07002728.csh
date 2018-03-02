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

$gtm_tst/com/dbcreate.csh mumps 1

cat >> badcomp.m << EOF
badcomp	;
	w "hello"!
	quit
EOF
echo "# Start background job with compile error"
$GTM << GTM_EOF >&! badcomp.outx &
	set ^A=0
	zcompile "badcomp.m"
	; Wait until lsof finishes
	for i=1:1:300 quit:1=^A  hang 1
	quit
GTM_EOF
set pid = $!
echo "# Wait until object file is created"
$gtm_tst/com/wait_for_log.csh -log badcomp.o
echo "# Output from lsof means badcomp.o is open (and probably locked).  We expect no output."
($lsof $tst_working_dir/badcomp.o > lsof.outx) >& lsof.err
# lsof 4.90 had a bug where it listed extraneous output so filter that out by a grep of badcomp.o
$grep badcomp.o lsof.outx
echo "# Signal background zcompile job to finish"
$GTM << GTM_EOF
	set ^A=1
	quit
GTM_EOF
$gtm_tst/com/wait_for_proc_to_die.csh $pid
$gtm_tst/com/dbcheck.csh
