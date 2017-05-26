#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# First generate the required gde command list

$gtm_exe/mumps -run %XCMD 'do ^gengdefile("'$gtm_tst/$tst/inref/errors.cmd'")'

# If there is an error gde @file.com won't return.
#$GDE @errors.cmd

# Now generate a script to be executed

echo "$GDE << gde_eof"	>>&! errors_script.csh
cat gdeerrors.cmd	>>&! errors_script.csh
echo "gde_eof"		>>&! errors_script.csh

chmod +x errors_script.csh

./errors_script.csh

$GDE << gde_eof >>&! addregions.out
add -region AREG -dyn=ASEG -stdnullcoll
add -segment ASEG -file=a.dat
add -name abcd(1,2,1:10) -region=AREG
change -region DEFAULT -stdnullcoll
gde_eof

$MUPIP create

$GTM << \gtm_eof
	set ^abcd(1,20000)=1,^abcd(1,2,4)=1,^abcd(1,2.4)=1,^abcd(1,2)=1,^abcd(1E4)=1
	write $view("REGION","^abcd(1,20000)")
	write $view("REGION","^abcd(1E4)")
	write $view("REGION",$name(^abcd(1E4)))
	write $view("REGION","^abcd(1,2,4)")
	write $view("REGION","^abcd(1,2.4)")
	write $view("REGION","^abcd(1,x)")
	write $view("REGION","^abcd(1,x(2)")
	write $view("REGION","^abcd(1,x(2))")
	write $view("REGION","^abcd(1,3(2))")
	write $view("REGION","^abcd(1,2")
	write $view("REGION","^abcd(1,2)")
	write $view("REGION","abcd(1,2,4)")
\gtm_eof


