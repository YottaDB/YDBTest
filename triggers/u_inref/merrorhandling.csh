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
source $gtm_tst/com/dbcreate.csh mumps 5
$echoline
$gtm_exe/mumps -run twork

$gtm_exe/mumps -run start^merrorhandling

#
# $ETrap testing first
#
$gtm_exe/mumps -run testetrap^merrorhandling
$gtm_exe/mumps -run testetrap2^merrorhandling

setenv gtm_trigger_etrap 'set $ecode=""'
$gtm_exe/mumps -run divbyzeropass^merrorhandling

# BAD gtm_trigger_etrap because of SHELL quoting
setenv gtm_trigger_etrap 'write $zstatus,! write ""HALT!"",! halt'
$gtm_exe/mumps -run badquote^merrorhandling

setenv gtm_trigger_etrap 'write $zstatus,! write "HALT!",! halt'
$gtm_exe/mumps -run newedetrap^merrorhandling

$gtm_exe/mumps -run changeetrap^merrorhandling

setenv gtm_trigger_etrap 'do ^eHandle'
$gtm_exe/mumps -run ehandle^merrorhandling

setenv gtm_trigger_etrap 'do dispatch^eHandle'
$gtm_exe/mumps -run dortnerrs^merrorhandling

$gtm_exe/mumps -run badcompile^merrorhandling

# reseting $ECODE will allow updates to complete
$echoline
setenv gtm_trigger_etrap 'zshow "s" w !'
echo "Expect this to fail because gtm_trigger_etrap does not clear ECODE :'$gtm_trigger_etrap'"
$gtm_exe/mumps -run ecode^merrorhandling "Expect this to FAIL"

$echoline
setenv gtm_trigger_etrap 'zshow "s" set $ecode="" w !'
echo "Expect this to pass because gtm_trigger_etrap clears ECODE :'$gtm_trigger_etrap'"
$gtm_exe/mumps -run ecode^merrorhandling "Expect this to PASS"
unsetenv gtm_trigger_etrap

#
# Non-existent labels and routines
#
$gtm_exe/mumps -run nosuch^merrorhandling

#
# Nested failure, $ecode is set to allow updates to proceed
#
$gtm_exe/mumps -run nested^merrorhandling

#
# $ztrap + triggers is no-no
#
setenv gtm_trigger_etrap 'set $ecode="" set $ztrap="quit -1"'
$gtm_exe/mumps -run noztrap^merrorhandling
unsetenv gtm_trigger_etrap

#
# ZGOTO testing
#
$gtm_exe/mumps -run zgotodm^merrorhandling
$gtm_exe/mumps -run zgotoprompt^merrorhandling

# ZGOTOINVLVL is not a valid error for direct mode
setenv gtm_trigger_etrap 'zshow "s" set $ecode="" w !'
$gtm_exe/mumps -run zgotoinvlvl^merrorhandling

$echoline
$gtm_tst/com/dbcheck.csh -extract

