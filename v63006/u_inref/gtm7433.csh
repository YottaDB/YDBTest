#!/usr/local/bin/tcsh
#################################################################
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
#
#
#

set DOLLAR='$'

echo '# Name-level $ORDER(,-1) and $ZPREVIOUS() return an empty string when they reach the trigger definitions (stored in ^#t) as it is not a normally accessible global'
echo '# Since the introduction of triggers in V5.4-000 if there were trigger definitions, these functions could return ^#t'

echo; echo '# This does not sucessfully test the above release note as this simple case does not reproduce the issue'

$gtm_tst/com/dbcreate.csh mumps

echo '# Setting the trigger'
cat >> trigger.trg << xx
+^a(*) -command=set -xecute="set tmp=${DOLLAR}incr(^b,1)"
xx
$gtm_dist/mupip trigger -triggerfile=trigger.trg

echo '# Setting ^a, and ^b'
$gtm_dist/mumps -run %XCMD 'set ^a(1)=1'
echo '# Printing all globals using $order(^b,-1) should only see ^a, and ^b'
$gtm_dist/mumps -run %XCMD 'set i="^b" for  quit:i=""  write "i: ",i,! set i=$order(@i,-1)'

echo '# Printing all globals using $zprevious(^b) should only see ^a, and ^b'
$gtm_dist/mumps -run %XCMD 'set i="^b" for  quit:i=""  write "i: ",i,! set i=$zprevious(@i)'


$gtm_tst/com/dbcheck.csh
