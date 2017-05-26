#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "CASE 1:" >>&! zshow.op
echo >>&! zshow.op
$gtm_exe/mumps -run "%XCMD" "do zshow^zshow(0)" >>&! zshow.op
echo "-----------------" >>&! zshow.op
echo "CASE 2" >>&! zshow.op
echo >>&! zshow.op
setenv gtm_principal_editing "EMPTERM"
$gtm_exe/mumps -run "%XCMD" "do zshow^zshow(0)" >>&! zshow.op
echo "-----------------" >>&! zshow.op
echo "CASE 3" >>&! zshow.op
echo >>&! zshow.op
setenv gtm_principal_editing "NOEMPTERM"
$gtm_exe/mumps -run "%XCMD" "do zshow^zshow(0)" >>&! zshow.op
echo "-----------------" >>&! zshow.op
echo "CASE 4" >>&! zshow.op
echo >>&! zshow.op
unsetenv gtm_principal_editing
$gtm_exe/mumps -run "%XCMD" "do zshow^zshow(1)" >>&! zshow.op
echo "-----------------" >>&! zshow.op

