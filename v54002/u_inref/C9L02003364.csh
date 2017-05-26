#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2011, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test the startup script operates properly and that an error message is
# created in the .mje file when the startup script is not exists with a non-zero status.

echo "Create driver.m"
cat >>& driver.m << EOF
driver
	if 1=\$zcmdline job ^mtest:(startup="echo.csh")
	else  job ^mtest:(startup="badecho.csh")
EOF

echo "Create mtest.m"
cat >>& mtest.m << EOF
mtest
	write "Write some output to mtest.mjo",!
	set p="pid.out"
	open p:newversion
	use p
	write \$job,!
	close p
	write "Write some more output to mtest.mjo",!
	halt
EOF

echo "Create echo.csh which exits with a 0"
cat >>& echo.csh << EOF
#!/usr/local/bin/tcsh
echo "verifies echo.csh was executed" > echo.out
exit 0
EOF

echo "Create badecho.csh which exits with a 1"
cat >>& badecho.csh << EOF
#!/usr/local/bin/tcsh
echo "verifies badecho.csh was executed" > badecho.out
exit 1
EOF

echo "Make echo.csh executable"
chmod 755 echo.csh
echo
echo "Execute driver"
$gtm_exe/mumps -run driver 1

echo
echo "Wait for mtest to die"
echo
$gtm_tst/com/wait_for_log.csh -log pid.out -duration 300 -waitcreation
if (0 != $status) then
	echo "pid.out was not created - test failed"
	exit 1
endif
set pid=`cat pid.out`
$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
if ($status) then
	echo "TEST-E-ERROR process $pid did not die."
endif
endif

echo "Output from mtest.mjo:"
cat mtest.mjo
echo "Output from mtest.mje:"
cat mtest.mje
echo "Output from echo.out:"
cat echo.out

cp mtest.mjo save_mtest.mjo
cp mtest.mje save_mtest.mje

echo "Make badecho.csh executable"
chmod 755 badecho.csh
echo
echo "Execute driver for badecho"
$gtm_exe/mumps -run driver 2
echo
echo "Wait for error in mtest.mje"
$gtm_tst/com/wait_for_log.csh -log mtest.mje -message "GTM-E-JOBSTARTCMDFAIL" -duration 300
$gtm_tst/com/check_error_exist.csh mtest.mje "GTM-E-JOBSTARTCMDFAIL"
echo "Output from mtest.mjo:"
cat mtest.mjo
echo "Output from mtest.mje:"
cat mtest.mje
# To avoid catching "-E-" in GTM-E-JOSTARTCMDFAIL by test system.
mv mtest.mjex mtest.bkup
echo "Output from badecho.out:"
cat badecho.out
