#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
############################
$gtm_tst/com/dbcreate.csh .
echo "do ^lkebas"
$gtm_exe/mumps -run lkebas


cat << CAT_EOF > lkeroutines.m
lke1	;
	write "do ^lkeindr",!  do ^lkeindr
	write !,"do ^lkesub0",!  do ^lkesub0
	write !,"do ^lkewaitp",!  do ^lkewaitp
CAT_EOF

if ($LFE != "L") then
	$gtm_exe/mumps -run lkeroutines >&! lkeroutines.out
	cat lkeroutines.out
	echo "Start analyzing *.mjo* and *.mje* files..."
	\egrep "FAIL" *.mjo*
	\cat *.mje*
	echo "End analyzing *.mjo* and *.mje* files."
endif

#
$gtm_tst/com/dbcheck.csh  -extract
