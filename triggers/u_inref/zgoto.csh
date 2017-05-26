#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$gtm_tst/com/dbcreate.csh mumps 5 >& dbcreate.log

$gtm_exe/mumps -run setup^runzgoto

$GTM << DONUT
do noref^runzgoto
write "Back at GTM prompt with \$ZLEVEL=",\$ZLEVEL,!
DONUT

$GTM << DONUT
do ref^runzgoto
write "Should not get here",!
DONUT

$GTM << DONUT
write "testing [z]goto to bounce around the same level",!
kill ^a
DONUT

$gtm_exe/mumps -run minusone^runzgoto
$gtm_exe/mumps -run controlled^runzgoto
$gtm_exe/mumps -run assertfail^runzgoto
$gtm_exe/mumps -run multilinezgoto
$gtm_exe/mumps -run cleanup^runzgoto
$gtm_tst/com/dbcheck.csh -extract >& dbcheck.log
