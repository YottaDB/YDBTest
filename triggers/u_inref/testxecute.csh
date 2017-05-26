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
# There is at least on random configuration that cannot be corrected for
setenv gtm_test_spanreg 0
$gtm_tst/com/dbcreate.csh mumps 5 255 4096 8192

# Testing the execution of triggers
# * Intrinsic variables outside of triggers --> moved to isvcheck.csh
#
# * Trigger execution for each command
#
# * Trigger subscript pattern matching
#
# * Intrinsic variables inside of triggers
#
# * Trigger piece + delim matching
#
# * Trigger order must be random (see triggers/u_inref/triggerorder.csh)
#
# Trigger name collision handling (see trignameuniq tests, manually_start and triggers)
#
# Trigger error handling -> see merrrorhandling
# * $ZTrap and $ETrap is set are newed
# * take the value of gtm_trigger_etrap for $etrap
# * uses $Etrap
# * change ztrap or etrap inside the trigger, need to show what happens with non-newed $Etraps

$gtm_exe/mumps -run testxecute

$gtm_exe/mumps -run testpiecedelim

$gtm_exe/mumps -run testxecutelvn

$gtm_tst/com/dbcheck.csh -extract

