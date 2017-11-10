#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
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
echo "setenv LIBPATH $LIBPATH"								>> $tst_general_dir/set_java_env.csh
echo "setenv lib_preload_init $lib_preload_init"					>> $tst_general_dir/set_java_env.csh
echo "setenv lib_preload $lib_preload"							>> $tst_general_dir/set_java_env.csh
echo 'setenv jvm_flags "'$jvm_flags'"'							>> $tst_general_dir/set_java_env.csh
echo "setenv bin_subdir $bin_subdir"							>> $tst_general_dir/set_java_env.csh

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "java test DONE."
