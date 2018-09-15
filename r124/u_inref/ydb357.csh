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
#
set sig = 3
set signame = "SIGQUIT"

echo "-----------------------------------------------------------------------------------------------------------"
echo "# Test that $signame (kill -$sig) sent to a mumps process during ZSYSTEM is handled little later but not lost"
echo "# Send signal $signame after Step2 but before Step3"
echo "# Step1, Step2 and Step3 should be seen in output but Step4 should not be"
echo "-----------------------------------------------------------------------------------------------------------"
echo ""
set echo
$ydb_dist/mumps -run ^%XCMD 'write "Step1",! zsystem "echo ""Step2""; kill -'$sig' "_$j_"; echo ""Step3""" write "Step4",!'
unset echo
echo ""

echo "-----------------------------------------------------------------------------------------------------------"
echo "# Test that $signame (kill -$sig) sent to a mumps process during ZEDIT is handled little later but not lost"
echo "# Send signal $signame after Step2 but before Step3"
echo "# Step1, Step2 and Step3 should be seen in output but Step4 should not be"
echo "-----------------------------------------------------------------------------------------------------------"
echo ""
echo "#\!/usr/local/bin/tcsh" > tmp.csh
echo "echo Step2" >> tmp.csh
echo "source kill.csh" >> tmp.csh
echo "echo Step3" >> tmp.csh
chmod +x tmp.csh
set echo
setenv EDITOR "tmp.csh"
cat tmp.csh
$ydb_dist/mumps -run ^%XCMD 'write "Step1",! zsystem "echo ""kill -'$sig' "_$j_""" > kill.csh" zedit "x.m" write "Step4",!'
unset echo
echo ""
