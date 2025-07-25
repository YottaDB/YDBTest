#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
# callins	[sopini] A large set of tests for call-ins from Java.
# callouts	[sopini] A large set of tests for call-outs to Java.
#-------------------------------------------------------------------------------------

echo "java test starts..."

# Run with unicode.
setenv gtm_test_unicode "TRUE"
$switch_chset "UTF-8" >&! switch_utf8.log

# List the subtests separated by spaces under the appropriate environment variable name.
setenv subtest_list  "callins callouts"

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS.
setenv subtest_exclude_list	""

setenv gtmji_dir $gtm_dist/plugin
if ($?alt_gtmji_dir) then
	setenv gtmji_dir $alt_gtmji_dir
endif

# Set environment variables required to run Java call-ins and call-outs.
if ("AIX" == $HOSTOS) then
	if (! ($?LIBPATH) ) setenv LIBPATH ""
	if (! ($?LDR_PRELOAD64) ) setenv LDR_PRELOAD64 ""
	setenv LIBPATH ${LIBPATH}:${JAVA_SO_HOME}:${JVM_SO_HOME}:${gtmji_dir}
	setenv lib_preload_init ${LDR_PRELOAD64}
	setenv lib_preload ${LDR_PRELOAD64}:${JAVA_SO_HOME}/libjsig.so
else
	if (! ($?LD_LIBRARY_PATH) ) setenv LD_LIBRARY_PATH ""
	if (! ($?LD_PRELOAD) ) setenv LD_PRELOAD ""
	setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${JAVA_SO_HOME}:${JVM_SO_HOME}:${gtmji_dir}
	setenv lib_preload_init ${LD_PRELOAD}
	setenv lib_preload ${LD_PRELOAD}:${JAVA_SO_HOME}/libjsig.so
	if (1 == $gtm_test_use_V6_DBs) then
		# We are going to create dbs with a random older V6 build.
		if ("ENCRYPT" == $test_encryption) then
			echo "# gtm_test_use_V6_DBs changed from 1 to 0 by java/instream.csh"	>>&! settings.csh
			echo "# because LD_LIBRARY_PATH set by java/instream.csh would "	>>&! settings.csh
			echo '# include $gtm_dist/plugin and would have a version mismatch'	>>&! settings.csh
			echo '# with the V6 build $gtm_dist/plugin and cause CRYPTINIT errors'	>>&! settings.csh
			echo "setenv gtm_test_use_V6_DBs 0"					>>&! settings.csh
			setenv gtm_test_use_V6_DBs 0
		endif
	endif
endif

# Have a bigger stack limit (some platforms seem to need it).
setenv jvm_flags "-Xss4M"
setenv bin_subdir ""

# Set JVM flags for 64-bit execution mode.
if ("SunOS" == $HOSTOS) then
	setenv jvm_flags "$jvm_flags -d64"
	setenv bin_subdir "sparcv9/"
else if ("AIX" == $HOSTOS) then
	setenv jvm_flags "$jvm_flags -Xmso4M"
else if ("Linux" == $HOSTOS) then
	# JVMs do not support huge pages, so disable (just unsetting the GT.M
	# test environment variable for huge pages does not work).
	setenv jvm_flags "$jvm_flags -XX:-UseLargePages"
	setenv GTMXC_jvm_options "-XX:-UseLargePages"
endif

# Define envvar for SIGUSR1 value on all platforms (for certain tests).
if (("OSF1" == $HOSTOS) || ("AIX" == $HOSTOS)) then
	setenv sigusrval 30
else if (("SunOS" == $HOSTOS) || ("HP-UX" == $HOSTOS) || ("OS/390" == $HOSTOS)) then
	setenv sigusrval 16
else if ("Linux" == $HOSTOS) then
	setenv sigusrval 10
endif

# Save Java environment settings in a special file.
echo "#\!/usr/local/bin/tcsh -f"							>> $tst_general_dir/set_java_env.csh
echo "# Use this file to set Java environment used by 'java' test on the current box."	>> $tst_general_dir/set_java_env.csh
echo "cp -r * $tst_general_dir/tmp"							>> $tst_general_dir/set_java_env.csh
echo "cd $tst_general_dir/tmp"								>> $tst_general_dir/set_java_env.csh
echo "setenv JAVA_HOME $JAVA_HOME"							>> $tst_general_dir/set_java_env.csh
echo "setenv gtmji_dir $gtmji_dir"							>> $tst_general_dir/set_java_env.csh
echo "setenv LD_LIBRARY_PATH $LD_LIBRARY_PATH"						>> $tst_general_dir/set_java_env.csh
if ($?LIBPATH) then
	echo "setenv LIBPATH $LIBPATH"							>> $tst_general_dir/set_java_env.csh
else
	echo "unsetenv LIBPATH"								>> $tst_general_dir/set_java_env.csh
endif
echo "setenv lib_preload_init $lib_preload_init"					>> $tst_general_dir/set_java_env.csh
echo "setenv lib_preload $lib_preload"							>> $tst_general_dir/set_java_env.csh
echo 'setenv jvm_flags "'$jvm_flags'"'							>> $tst_general_dir/set_java_env.csh
echo "setenv bin_subdir $bin_subdir"							>> $tst_general_dir/set_java_env.csh

source $gtm_tst/com/is_libyottadb_asan_enabled.csh	# defines "gtm_test_libyottadb_asan_enabled" env var
if ($gtm_test_libyottadb_asan_enabled) then
	# libyottadb.so was built with address sanitizer
	# The below subtest has been seen to fail with the following symptom.
	#	==31240==Shadow memory range interleaves with an existing memory mapping. ASan cannot proceed correctly. ABORTING.
	#	==31240==ASan shadow was supposed to be located in the [0x00007fff7000-0x10007fff7fff] range.
	#	==31240==This might be related to ELF_ET_DYN_BASE change in Linux 4.12.
	#	==31240==See https://github.com/google/sanitizers/issues/856 for possible workarounds.
	# At this point, the above issue 856 is still open.
	# Therefore disable this subtest at least until that issue is open.
	setenv subtest_exclude_list "$subtest_exclude_list callins"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "java test DONE."
