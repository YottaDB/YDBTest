#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# make sure EDITOR is unset to ensure correct error message output
if ($?EDITOR) then
	unsetenv EDITOR
endif
# Tell geteditor() to return that it was unable to find an editor
echo "Case 1: geteditor() says it cannot find an editor"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 106
$gtm_dist/mumps -direct << EOF
zedit "banana"
halt
EOF

# Force and invalid executable path so the EXEC will fail
echo "Case 2: Let us try to execute an invalid executable path"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 107
$gtm_dist/mumps -direct << EOF
zedit "banana"
halt
EOF
