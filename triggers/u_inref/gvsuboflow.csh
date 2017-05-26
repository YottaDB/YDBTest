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
# While analyzing this failure, I noticed that op_fnztrigger was doing a save
# and restore of the entire gv_currkey structure including the "top" field.
# This represents the length of the currently allocated buffer for the global
# variable gv_currkey. This buffer could be freed/reallocated if inside the
# $ztrigger, we open a database that has a bigger keysize than all dbs opened
# until this point. In this case, gv_currkey->top will increase. Therefore
# while restoring gv_currkey at the end of the $ztrigger function, we should
# take care not to restore gv_currkey->top. I have this fixed now.

# local GDE file since the small keys don't work so well
cat > smallkeys.gde << EOF
add -name a -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=a.dat
change -region AREG -key=10
change -region DEFAULT -key=64
EOF

setenv gtm_test_spanreg 0  # Test specific GDE file doesn't work with spanreg
setenv test_specific_gde $tst_working_dir/smallkeys.gde
$gtm_tst/com/dbcreate.csh mumps

$gtm_exe/mumps -run gvsuboflow

$gtm_tst/com/dbcheck.csh -extract
