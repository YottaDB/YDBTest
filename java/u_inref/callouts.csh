#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test verifies that call-outs to Java from GT.M work as expected. The test uses Java code to generate the actual
# test M and Java routines, call-out tables, and expected output files on-the-fly.

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
echo "Command: $JAVA_HOME/bin/${bin_subdir}/javac -encoding utf-8 -classpath $tst_working_dir -d . $tst_working_dir/com/test/ji/TestXC.java" >> $java_comm_output
$JAVA_HOME/bin/${bin_subdir}/javac -encoding utf-8 -classpath $tst_working_dir -d . $tst_working_dir/com/test/ji/TestXC.java |& tee -a $java_comm_output | $grep -v "$large_pages"
echo "$JAVA_HOME/bin/${bin_subdir}/java $jvm_flags com.test.ji.TestXC $tst_working_dir/" >> $java_comm_output
$JAVA_HOME/bin/${bin_subdir}/java $jvm_flags com.test.ji.TestXC "$tst_working_dir/" |& tee -a $java_comm_output | $grep -v "$large_pages"

# Create a database.
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out

# Prepare the compilation command.
set javac_exe = "$JAVA_HOME/bin/${bin_subdir}javac -encoding utf-8 -classpath $gtmji_dir/gtmji.jar"

# First try without setting GTMXC_xxx variable.
echo "Trying to invoke call-outs without setting GTMXC_xxx:"
echo "Command: $gtm_dist/mumps -run test1" >> $java_comm_output
$gtm_dist/mumps -run test1 |& tee -a $java_comm_output | $grep -v "$large_pages" >&! test0a.outx
$grep "YDB-E-ZCCTENV, Environmental variable for external package ydb_xc_test1/GTMXC_test1 not set" test0a.outx
$grep -q "lbl1" test0a.outx
if (! $status) echo "MUMPS did not terminate!"
echo

# Then omit the classpath while compiling.
echo "Trying to omit the classpath during compilation:"
setenv GTMXC_test2 $tst_working_dir/test2.xc
echo "Command: $gtm_dist/mumps -run test2" >> $java_comm_output
$gtm_dist/mumps -run test2 |& tee -a $java_comm_output | $grep -v "$large_pages" >&! test0b.outx
unsetenv GTMXC_test2
set path_error_count = `$grep -c "GTMXC_classpath environment variable not defined" test0b.outx`
echo "${path_error_count} GTMXC_classpath errors"
echo

setenv GTMXC_classpath ${tst_working_dir}:$gtmji_dir/gtmji.jar

# Save Java environment settings in a special file.
echo 'setenv tst_working_dir `pwd`'					>> set_java_env.csh
echo 'setenv javac_exe "'$javac_exe'"'					>> set_java_env.csh
echo 'setenv GTMXC_classpath ${tst_working_dir}:$gtmji_dir/gtmji.jar'	>> set_java_env.csh

set fake_enospc = $gtm_test_fake_enospc

if ("AIX" == $HOSTOS) then
	set lib_preload_var = LDR_PRELOAD64
else
	set lib_preload_var = LD_PRELOAD
endif

# And finally do all other tests.
foreach m_test ( test?.m test??.m )
	set test_name = ${m_test:r}
	if ($test_name == "test8") then
		setenv gtm_test_fake_enospc 0
		setenv GTMCI $tst_working_dir/$test_name.ci
	else if ($test_name == "test10") then
		echo "Command: $gtm_dist/mumps test10.m" >> $java_comm_output
		$gtm_dist/mumps test10.m |& tee -a $java_comm_output | $grep -v "$large_pages" >&! test10-compile.outx
	endif
	if (-f $test_name.env) then
		source $test_name.env
	endif
	setenv GTMXC_$test_name $tst_working_dir/$test_name.xc
	setenv $lib_preload_var $lib_preload
	echo "Command: $javac_exe $tst_working_dir/com/test/${test_name:u}.java" >> $java_comm_output
	$javac_exe $tst_working_dir/com/test/${test_name:u}.java |& (setenv $lib_preload_var $lib_preload_init; tee -a $java_comm_output | $grep -v "$large_pages")
	echo "Command: $gtm_dist/mumps -run $test_name" >> $java_comm_output
	$gtm_dist/mumps -run $test_name |& (setenv $lib_preload_var $lib_preload_init; tee -a $java_comm_output | $grep -v "$large_pages") >&! $test_name.outx
	unsetenv GTMXC_${test_name}
	if (-f $test_name.noenv) then
		source $test_name.noenv
	endif
	setenv $lib_preload_var $lib_preload_init
	echo "$m_test produced the following diff:"
	if ($test_name == "test3") then
		cp test3.outx test3.outx.bak
		cat test3.outx.bak | sed -e "s;incompatible with;cannot be cast to;" -e "s;BoundsException: Array index out of range: ;BoundsException: ;" -e "s;divide by zero;\/ by zero;" | $grep -v "ClassCastException.java" > test3.outx
	else if ($test_name == "test5") then
		cp test5.outx test5.outx.bak
		cat test5.outx.bak | sed -e "s; com\/test\/Test5\.; ;" -e "s;(\[Ljava\/lang\/Object\;).;;" > test5.outx
	else if ($test_name == "test8") then
		setenv gtm_test_fake_enospc $fake_enospc
		unsetenv GTMCI
		$gtm_tst/com/check_error_exist.csh test8.mje "YDB-F-FORCEDHALT" | uniq
		\mv test8.mjex test8.job.logx
	else if ($test_name == "test11") then
		cp test11.outx test11.outx.bak
		$grep -v "location" test11.outx.bak > test11.outx
	else if ($test_name == "test13") then
		cp test13.outx test13.outx.bak
		cat test13.outx.bak | sed -e "s;$tst_working_dir;\.;" -e "s; com\/test\/Test13\.; ;" -e "s;(\[Ljava\/lang\/Object\;).;;" > test13.outx
	else if ($test_name == "test16") then
		cp test16.outx test16.outx.bak
		$grep -E "(UNIMPLOP|ZCUNTYPE|###|lbl)" test16.outx.bak | $grep -v ":" > test16.outx
	else if ($test_name == "test22") then
		cp test22.outx test22.outx.bak
		set ln = `cat test22.outx | $gtm_dist/mumps -run LOOP^%XCMD --xec='|if %l?1"-Dgtm.callouts".E write %NR,!  halt|'`
		($head -n 3 test22.outx.bak ; $tail -n +$ln test22.outx.bak) >&! test22.outx
	endif
	diff $test_name.cmp $test_name.outx
	echo
end

# Verify that the database is OK.
$gtm_tst/com/dbcheck.csh >&! dbcheck.out
