#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo 'This test defines $SHELL as the null string'
env SHELL= $gtm_dist/mumps -run %XCMD 'zsystem "echo THIS ALWAYS WORKS" zsystem "echo PASS"'
$echoline
echo 'This test undefines $SHELL'
$gtm_dist/mumps -run %XCMD 'set x=$&gtmposix.unsetenv("SHELL",.errno) zsystem "echo THIS ALWAYS WORKS" zsystem "echo PASS"'

$echoline
echo 'Try null zsystem with null string for $SHELL'
printf "printf PASS1 && exit\n" | env SHELL= $gtm_dist/mumps -run %XCMD 'write "Test1:" zsy  write !'
printf "printf PASS2 && exit\n" | env SHELL= $gtm_dist/mumps -run %XCMD 'write "Test2:" zsy "" write !'
env SHELL= $gtm_dist/mumps -run %XCMD 'write "Test3:" zsy "echo PASS3" write !'

$echoline
echo 'Try null zsystem with undefined $SHELL'
printf "printf PASS1 && exit\n" | $gtm_dist/mumps -run %XCMD 'set x=$&gtmposix.unsetenv("SHELL",.errno) write "Test1:" zsy  write !'
printf "printf PASS2 && exit\n" | $gtm_dist/mumps -run %XCMD 'set x=$&gtmposix.unsetenv("SHELL",.errno) write "Test2:" zsy "" write !'
$gtm_dist/mumps -run %XCMD 'set x=$&gtmposix.unsetenv("SHELL",.errno) write "Test3:" zsy "echo PASS3" write !'

$echoline
echo 'Try null zsystem with defined $SHELL'
printf "printf PASS1 && exit\n" | $gtm_dist/mumps -run %XCMD 'write "Test1:" zsy  write !'
printf "printf PASS2 && exit\n" | $gtm_dist/mumps -run %XCMD 'write "Test2:" zsy "" write !'
$gtm_dist/mumps -run %XCMD 'write "Test3:" zsy "echo PASS3" write !'
