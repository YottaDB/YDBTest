#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# There is not specific error for exceeding 1 million triggers
#
# Run Time Error:
#
# Action:
#
# The trigger name has two or three parts to it depending on how the trigger
# name was created.
# - Auto name assignment based on GVN
#   gvn_name#auto_assigned_number#unique_ID
# - User supplied name
#   name#unique_ID
#
# * gvn_name is the first 28 characters of the GVN
#   covered in triggers/maxparse_{small,default,medium,large}
#
# * name can be up to 28 7bit alphanumeric ASCII characters
#   covered in triggers/mupiptrigger.  Which can be said as [a-zA-Z0-9]
#   with percent signs allowed only in the first position.
#
# * auto assigned number is from 0 to 999,999 for 1 million triggers
#   This test preivous installed 1 million triggers which caused a lot of grief
#   in terms of CPU, disk and memory. The test now eliminates its disk foot
#   print and reduces the CPU and memory overhead.
#
#   The new test installs a set of triggers upfront to establish the
#   auto-generated name space. After that it continously adds and deletes the
#   newly added trigger. By deleting the just added trigger, this test is no
#   longer bound by global buffers and does not result in a large database.
#
#   This test consumes the auto generate trigger name space
#   1. load 0 to 999,999 triggers
#      - short auto-generated names : someglobal going to DREG
#      - long auto-generated names  :
#        someVeryLongGlobalVariableName[ABC] going to [ABC]REG
#        someVeryLongGlobalVariableName[D] going to DEFAULT
#   2. Execute test programs which hide their output in test*.out files for a
#      nice clean reference file.
#      Test 1
#      - Cannot load triggers past 999,999 for ^someglobal
#      - Load a trigger for ^someglobal with a user defined name
#      - Delete the all triggers defined for ^someglobal reseting #SEQNO
#        randomly choosing one of the following delete operations:
#         -^someglobal(1) -commands=S -xecute="set x=$increment(^fired($ZTName))"
#         -someglobal#1
#         -someglobal#1#
#         -someglobal#*
#         -someglobal*
#      - Load a trigger for ^someglobal. It should be someglobal#1#
#
#      Test 2
#      - Cannot load triggers past 999,999 for ^someVeryLongGlobalVariableName[ABCD]
#        (randomly chosen)
#      - Load a trigger for ^someVeryLongGlobalVariableName[ABCD] with a user
#        defined name and delete it
#      - Reset #SEQNO by renaming all the triggers with user defined names
#      - Load a trigger for ^someVeryLongGlobalVariableName[ABCD]. It should be
#        someVeryLongGlobalVar#1#
#
# * unique_ID is a two character alpha numeric string composed
#   triggers of the same name cannot be installed, but different DAT files could
#   have triggers with the same name.  The runtime constructs this unique. This

# turn off gtmdbglvl checking for this particular subtest due to run time
# constraints
unsetenv gtmdbglvl

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 116

$gtm_tst/com/dbcreate.csh mumps 5
$gtm_exe/mumps -run setup^maxtrignames >&! setup.log

$echoline
# Create the scenario loading 999,999 triggers with shared and non-shared
# trigger name space.
$gtm_exe/mumps -run maxtrignames

# validate that the before and after pictures are the same. Obscure the cycle
# counts because they vary for ^someVeryLongGlobalVariableNameX
foreach trg (initial.trg loaded.trg)
	$tst_awk '/^;/{sub(/cycle: [0-9]*$/,"");printf("%-40s\t;",$0);getline;print $0}' $trg > ${trg}x
end
diff initial.trgx loaded.trgx

# Tests silently output to test*.out
$gtm_exe/mumps -run test1^maxtrignames
$gtm_exe/mumps -run test2^maxtrignames

# output the final results
set trg=complete.trg
$MUPIP trigger -select $trg
$tst_awk '/^;/{sub(/cycle: [0-9]*$/,"");printf("%-40s\t;",$0);getline;print $0}' $trg | sort

$echoline
$gtm_tst/com/dbcheck.csh -extract
