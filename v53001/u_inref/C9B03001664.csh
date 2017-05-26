#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2008, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps 1

$echoline
echo "test gtm_noundef env.variable settings"
$echoline

unsetenv gtm_noundef
echo "gtm_noundef not set"
$GTM << EOF
write \$view("UNDEF")
view "NOUNDEF"
write \$view("UNDEF")
EOF

echo "gtm_noundef set to TRUE"
setenv gtm_noundef TRUE
$GTM << EOF
write \$view("UNDEF")
view "UNDEF"
write \$view("UNDEF")
EOF

echo "gtm_noundef set to FALSE"
setenv gtm_noundef FALSE
$GTM << EOF
write \$view("UNDEF")
view "NOUNDEF"
write \$view("UNDEF")
EOF


$echoline
echo "run noundeftst with gtm_noundef set to FALSE"
setenv gtm_noundef FALSE
$echoline
echo "Do not pass the parameter GEN, so that all the test runs in indirection mode"
$echoline
$gtm_exe/mumps -run noundeftst
$echoline
echo "Pass the parameter GEN, so that the test creates a file with all the test cases and runs in direct mode"
$echoline
$gtm_exe/mumps -run noundeftst FALSE GEN
$echoline

echo "run noundeftst with gtm_noundef set to TRUE"
$echoline
setenv gtm_noundef TRUE
$echoline
echo "Do not pass the parameter GEN, so that all the test runs in indirection mode"
$echoline
$GTM << EOF
do ^noundeftst
EOF
$echoline
echo "Pass the parameter GEN, so that the test creates a file with all the test cases and runs in direct mode"
$echoline
$gtm_exe/mumps -run noundeftst TRUE GEN
$echoline
$gtm_tst/com/dbcheck.csh
