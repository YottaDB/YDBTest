#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test race between db_init and rundown with encryption and gld/fileheader out of sync

$gtm_tst/com/dbcreate.csh mumps 1				>& dbcreate.log

$GDE change -segment DEFAULT -noencryption			>& gdeupdate.log

$gtm_exe/mumps -run gtm8142

$gtm_tst/com/dbcheck.csh

echo "Done."
