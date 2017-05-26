#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# We do not want autorelink-enabled directories because this test plays with $gtmroutines itself.
source $gtm_tst/com/gtm_test_disable_autorelink.csh

# Define a few environment variables that can be used for testing.
setenv one	1
setenv two	2

# Start actual testing.
$gtm_exe/mumps -run rctlupdate >&! mumps.log

# Indicate whether the test succeeded.
$grep FAIL mumps.log
if ($status) then
	echo "TEST-I-PASS, Test succeeded."
endif
echo

# Set up the environment for a few specific test cases.
mkdir dir
cd dir
mkdir dir3 dir4 dir5
chmod 000 dir4
touch %a.o y z.o dir3/a.o
ln -s dir1 dir2
ln -s dir2 dir1
ln -s dir1 a.o
ln -s abcd.o b.o
ln -s y c.o
ln -s z.o d.o

echo "Case 1. Bad symbolic links should not be included in the processing of wildcarded arguments:"
$gtm_dist/mumps -run %XCMD 'zrupdate "dir*"'
echo

echo "Case 2. Files without an extension should not be considered:"
$gtm_dist/mumps -run %XCMD 'zrupdate "dir1"'
echo

echo "Case 3. Error reporting should be consistent (FILEPARSE is the primary error):"
$gtm_dist/mumps -run %XCMD 'zrupdate "dir1/a.o"'
echo

echo "Case 4. When erroring out on bad permissions, no relinkctl entry should be created:"
$gtm_dist/mumps -run %XCMD 'zrupdate "dir4/a.o" zshow "A"'
echo

echo "Case 5. Object files whose name begins with '%' should not be allowed:"
$gtm_dist/mumps -run %XCMD 'zrupdate "%a.o" zshow "A"'
echo

echo "Case 6. Symbolic links should not be accepted for consideration as routine object entries:"
$gtm_dist/mumps -run %XCMD 'zrupdate "*.o" zshow "A"'
echo

echo "Case 7. The '?' wildcard character needs to be supported:"
$gtm_dist/mumps -run %XCMD 'zrupdate "?.o" zshow "A"'
echo

echo "Case 8. If the directory in ZRUPDATE argument is missing, and the relinkctl file for it was created"
echo "        by a different process and never opened by the process doing the ZRUPDATE, we should still"
echo "        increment its cycle."
cat > task.csh <<EOF
#!/usr/local/bin/tcsh -f
mv dir3 dir3.bak
$gtm_dist/mumps -run %XCMD 'zrupdate "dir3/a.o" zshow "A"'
EOF
chmod 755 task.csh
$gtm_dist/mumps -run %XCMD 'zrupdate "dir3/a.o" zshow "A" write ! zsystem "task.csh"'

chmod 777 dir4
