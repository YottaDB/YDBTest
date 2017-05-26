#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test verifies that call-ins from Java into GT.M work as expected. The test uses Java code to generate the actual
# test M and Java routines, call-in tables, and expected output files on-the-fly.

# In case there is no Java on the box, exit right away.
if ("NA" == $JAVA_HOME) exit

# Get the generic Java settings file.
cp $tst_general_dir/set_java_env.csh .

# Unpack Java files
source $gtm_tst/$tst/u_inref/unpack_java_src.csh

# Ensure that the path for test-generation classes exists.
mkdir -p $tst_working_dir/com/test/ji

# Deal with JVM warnings about large pages (<java_callins_vyast_malloc_fail>).
set large_pages = "Cannot allocate large pages, falling back to regular pages"

# The unfiltered file that keeps the large_pages errors in place
set java_comm_output = "java_comm_output.outx"

# First, create the Java test files.
echo "Command: $JAVA_HOME/bin/${bin_subdir}/javac -encoding utf-8 -classpath $tst_working_dir -d . $tst_working_dir/com/test/ji/TestCI.java" >> $java_comm_output
$JAVA_HOME/bin/${bin_subdir}/javac -encoding utf-8 -classpath $tst_working_dir -d . $tst_working_dir/com/test/ji/TestCI.java |& tee -a $java_comm_output | $grep -v "$large_pages"
echo "Command: $JAVA_HOME/bin/${bin_subdir}/java $jvm_flags com.test.ji.TestCI $tst_working_dir/" >> $java_comm_output
$JAVA_HOME/bin/${bin_subdir}/java $jvm_flags com.test.ji.TestCI "$tst_working_dir/" |& tee -a $java_comm_output | $grep -v "$large_pages"

# Prepare the compilation and execution commands for the tests.
set javac_exe = "$JAVA_HOME/bin/${bin_subdir}javac -encoding utf-8 -classpath $gtmji_dir/gtmji.jar"
set java_exe = "$JAVA_HOME/bin/${bin_subdir}java $jvm_flags -Djava.library.path=$gtmji_dir -classpath ${tst_working_dir}:$gtmji_dir/gtmji.jar"

# Save Java environment settings in a special file.
echo 'setenv tst_working_dir `pwd`'	>> set_java_env.csh
echo 'setenv javac_exe "'$javac_exe'"'	>> set_java_env.csh
echo 'setenv java_exe "'$java_exe'"'	>> set_java_env.csh

# Create a database.
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out

# Get the listing of all test files created.
cd com/test
set java_files = ( Test?.java Test??.java )
cd $tst_working_dir

# First try without setting GTMCI variable.
echo "Trying to invoke call-ins without setting GTMCI:"
unsetenv GTMCI
echo "Command: $javac_exe $tst_working_dir/com/test/Test1.java" >> $java_comm_output
$javac_exe $tst_working_dir/com/test/Test1.java |& tee -a $java_comm_output | $grep -v "$large_pages"
echo "Commnad: $java_exe com.test.Test1" >> $java_comm_output
$java_exe com.test.Test1 |& tee -a $java_comm_output | $grep -v "$large_pages" >&! Test0a.outx
$grep "The GTMCI environment variable not set" Test0a.outx
$grep -q "lbl1" Test0a.outx
if (! $status) echo "JVM did not terminate!"
echo

# Then omit the classpath while compiling.
echo "Trying to omit the classpath during compilation:"
setenv GTMCI $tst_working_dir/Test2.ci
echo "Commnad :$JAVA_HOME/bin/${bin_subdir}javac -encoding utf-8 $tst_working_dir/com/test/Test2.java" >> $java_comm_output
$JAVA_HOME/bin/${bin_subdir}javac -encoding utf-8 $tst_working_dir/com/test/Test2.java |& tee -a $java_comm_output | $grep -v "$large_pages" >&! Test0b.outx
$grep "package com.fis.gtm.ji does not exist" Test0b.outx
$grep "errors" Test0b.outx
echo

# Then provide no path to gtmji.jar in the classpath to the JAR while running.
echo "Trying to provide no classpath during execution:"
setenv GTMCI $tst_working_dir/Test3.ci
echo "Command: $javac_exe $tst_working_dir/com/test/Test3.java" >> $java_comm_output
$javac_exe $tst_working_dir/com/test/Test3.java |& tee -a $java_comm_output | $grep -v "$large_pages"
echo "Command: $JAVA_HOME/bin/${bin_subdir}java $jvm_flags -Djava.library.path=$gtmji_dir -classpath $tst_working_dir com.test.Test3" >> $java_comm_output
$JAVA_HOME/bin/${bin_subdir}java $jvm_flags -Djava.library.path=$gtmji_dir -classpath $tst_working_dir com.test.Test3 |& tee -a $java_comm_output | $grep -v "$large_pages" >&! Test0c.outx
$grep "lang.NoClassDefFoundError" Test0c.outx
$grep -q "lbl1" Test0c.outx
if (! $status) echo "JVM did not terminate!"
echo

set fake_enospc = $gtm_test_fake_enospc

# And finally do all other tests.
foreach java_test ($java_files)
	set test_name = ${java_test:r}
	setenv GTMCI $tst_working_dir/$test_name.ci
	echo "Command: $javac_exe $tst_working_dir/com/test/$java_test" >> $java_comm_output
	$javac_exe $tst_working_dir/com/test/$java_test |& tee -a $java_comm_output | $grep -v "$large_pages"
	if ($test_name == "Test10") then
		setenv gtm_test_fake_enospc 0
	else if ($test_name == "Test22") then
		setenv gtm_test_fake_enospc 0
	endif
	echo "Command: $java_exe com.test.$test_name" >> $java_comm_output
	$java_exe com.test.$test_name |& tee -a $java_comm_output | $grep -v "$large_pages" >&! $test_name.outx
	echo "$java_test produced the following diff:"
	if ($test_name == "Test10") then
		setenv gtm_test_fake_enospc $fake_enospc
		$gtm_tst/com/check_error_exist.csh test10.mje "GTM-F-FORCEDHALT"
		\mv test10.mjex test10.job.logx
	else if ($test_name == "Test17") then
		cp Test17.outx Test17.outx.bak
		$grep -E "(GTM|lbl|###)" Test17.outx.bak | sed -e "s;${tst_working_dir};\.;" -e "s;column [0-9][0-9];column xx;" > Test17.outx
	else if ($test_name == "Test22") then
		setenv gtm_test_fake_enospc $fake_enospc
		$gtm_tst/com/check_error_exist.csh test22.mje "GTM-F-FORCEDHALT"
		\mv test22.mjex test22.job.logx
	endif
	diff $test_name.outx $test_name.cmp
	echo
end

# Verify that the database is OK.
$gtm_tst/com/dbcheck.csh >&! dbcheck.out
