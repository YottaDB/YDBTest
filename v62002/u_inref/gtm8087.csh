#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
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

$gtm_tst/com/dbcreate.csh mumps 1 64

# we are matching output of zshow "*"
setenv gtm_test_disable_randomdbtn 1

# Compile a shared library with sample external calls.
$gt_cc_compiler $gtt_cc_shl_options $gt_cc_option_debug -I$gtm_dist $gt_cc_option_I $gtm_tst/v62002/inref/gtm8087xcalls1.c -o gtm8087xcalls1.o
$gt_cc_compiler $gtt_cc_shl_options $gt_cc_option_debug -I$gtm_dist $gt_cc_option_I $gtm_tst/v62002/inref/gtm8087xcalls2.c -o gtm8087xcalls2.o
$gt_ld_shl_linker ${gt_ld_option_output}libgtm8087xcalls1${gt_ld_shl_suffix} $gt_ld_shl_options gtm8087xcalls1.o gtm8087xcalls2.o $gt_ld_sysrtns $gt_ld_syslibs > ld.out

setenv GTMXC_gtm8087xcalls1 $PWD/gtm8087xcalls1.xc
cat > $GTMXC_gtm8087xcalls1 <<1234567890123456789012345678901234567890
$PWD/libgtm8087xcalls1${gt_ld_shl_suffix}

chooseFileByIndex:	gtm_status_t choose_file_by_index(I:gtm_char_t*, I:gtm_int_t, O:gtm_char_t*[100])
renameFile:		gtm_status_t rename_file(I:gtm_char_t*, I:gtm_char_t*)
removeFile:		gtm_status_t remove_file(I:gtm_char_t*)
matchFiles:		gtm_string_t* match_files(I:gtm_char_t*)
murmurHash:		gtm_string_t* murmur_hash(I:gtm_char_t*)
chShmMod:		gtm_status_t ch_shm_mod(I:gtm_int_t, I:gtm_int_t)
truncateFile:		gtm_status_t truncate_file(I:gtm_char_t*, I:gtm_int_t)
iamjustrightforanexternalcallnm:	gtm_status_t remove_file(I:gtm_int_t)
iamtoolongforanexternalcallname1: gtm_status_t remove_file(I:gtm_int_t)
1234567890123456789012345678901234567890

$gt_cc_compiler $gtt_cc_shl_options $gt_cc_option_debug -I$gtm_dist $gt_cc_option_I $gtm_tst/v62002/inref/gtm8087xcalls3.c -o gtm8087xcalls3.o
$gt_ld_shl_linker ${gt_ld_option_output}libgtm8087xcalls3${gt_ld_shl_suffix} $gt_ld_shl_options gtm8087xcalls3.o $gt_ld_sysrtns $gt_ld_syslibs > ld.out

setenv GTMXC_gtm8087xcalls3 $PWD/gtm8087xcalls3.xc
cat > $GTMXC_gtm8087xcalls3 <<1234567890123456789012345678901234567890
$PWD/libgtm8087xcalls3${gt_ld_shl_suffix}
chmod:			gtm_status_t gtm8087_chmod(I:gtm_char_t*, I:gtm_int_t, O:gtm_int_t*)
clockgettime:		gtm_status_t gtm8087_clock_gettime(I:gtm_int_t, O:gtm_long_t*, O:gtm_long_t*, O:gtm_int_t*)
clockval:		gtm_status_t gtm8087helper_clockval(I:gtm_char_t*, O:gtm_int_t*)
cp:			gtm_status_t gtm8087_cp(I:gtm_char_t*, I:gtm_char_t*, O:gtm_int_t*)
filemodeconst:		gtm_status_t gtm8087helper_filemodeconst(I:gtm_char_t*, O:gtm_int_t*)
gettimeofday:		gtm_status_t gtm8087_gettimeofday(O:gtm_long_t*, O:gtm_long_t*, O:gtm_int_t*)
localtime:		gtm_status_t gtm8087_localtime(I:gtm_long_t, O:gtm_int_t*, O:gtm_int_t*, O:gtm_int_t*, O:gtm_int_t*, O:gtm_int_t*, O:gtm_int_t*, O:gtm_int_t*, O:gtm_int_t*, O:gtm_int_t*, O:gtm_int_t*)
mkdir:			gtm_status_t gtm8087_mkdir(I:gtm_char_t*, I:gtm_int_t, O:gtm_int_t*)
mkdtemp:		gtm_status_t gtm8087_mkdtemp(IO:gtm_char_t*, O:gtm_int_t*)
mktime:			gtm_status_t gtm8087_mktime(I:gtm_int_t, I:gtm_int_t, I:gtm_int_t, I:gtm_int_t, I:gtm_int_t, I:gtm_int_t, O:gtm_int_t*, O:gtm_int_t*, IO:gtm_int_t*, O:gtm_long_t*, O:gtm_int_t*)
realpath:		gtm_status_t gtm8087_realpath(I:gtm_char_t*, O:gtm_string_t*[4097], O:gtm_int_t*)
regcomp:		gtm_status_t gtm8087_regcomp(O:gtm_string_t* [8], I:gtm_char_t*, I:gtm_int_t, O:gtm_int_t*)
regconst:		gtm_status_t gtm8087helper_regconst(I:gtm_char_t*, O:gtm_int_t*)
regexec:		gtm_status_t gtm8087_regexec(I:gtm_string_t*, I:gtm_char_t*, I:gtm_int_t, IO:gtm_string_t*, I:gtm_int_t, O:gtm_int_t*)
regfree:		gtm_status_t gtm8087_regfree(I:gtm_string_t*)
regofft2offsets:	gtm_status_t gtm8087helper_regofft2offsets(I:gtm_string_t*, O:gtm_int_t*, O:gtm_int_t*)
rmdir:			gtm_status_t gtm8087_rmdir(I:gtm_char_t*, O:gtm_int_t*)
setenv:			gtm_status_t gtm8087_setenv(I:gtm_char_t*, I:gtm_char_t*, I:gtm_int_t, O:gtm_int_t*)
signalval:		gtm_status_t gtm8087helper_signalval(I:gtm_char_t*, O:gtm_int_t*)
stat:			gtm_status_t gtm8087_stat(I:gtm_char_t*, O:gtm_ulong_t*, O:gtm_ulong_t*, O:gtm_ulong_t*, O:gtm_ulong_t*, O:gtm_ulong_t*, O:gtm_ulong_t*, O:gtm_ulong_t*, O:gtm_long_t*, O:gtm_long_t*, O:gtm_long_t*, O:gtm_long_t*, O:gtm_long_t*, O:gtm_long_t*, O:gtm_long_t*, O:gtm_long_t*, O:gtm_long_t*, O:gtm_int_t*)
symlink:		gtm_status_t gtm8087_symlink(I:gtm_char_t*, I:gtm_char_t*, O:gtm_int_t*)
sysconf:		gtm_status_t gtm8087_sysconf(I:gtm_int_t, O:gtm_long_t*, O:gtm_int_t*)
sysconfval:		gtm_status_t gtm8087helper_sysconfval(I:gtm_char_t*, O:gtm_int_t*)
syslog:			gtm_status_t gtm8087_syslog(I:gtm_int_t, I:gtm_char_t*)
syslogconst:		gtm_status_t gtm8087helper_syslogconst(I:gtm_char_t*, O:gtm_int_t*)
umask:			gtm_status_t gtm8087_umask(I:gtm_int_t, O:gtm_int_t*, O:gtm_int_t*)
unsetenv:		gtm_status_t gtm8087_unsetenv(I:gtm_char_t*, O:gtm_int_t*)
utimes:			gtm_status_t gtm8087_utimes(I:gtm_char_t*, O:gtm_int_t*)
1234567890123456789012345678901234567890

$gtm_dist/mumps -r ^gtm8087


$gtm_dist/mumps -r locallimits31^gtm8087

$gtm_dist/mumps -r locallimits30^gtm8087

$gtm_dist/mumps -r locallimits29^gtm8087

$gtm_dist/mumps -r locallimits28^gtm8087

$gtm_dist/mumps -r globallimits5^gtm8087

$gtm_dist/mumps -r globallimits5b^gtm8087

$gtm_dist/mumps -r globallimits4^gtm8087

$gtm_dist/mumps -r globallimits4b^gtm8087

$gtm_dist/mumps -r globallimits3^gtm8087

$gtm_dist/mumps -r zshowstar^gtm8087

$gtm_tst/com/dbcheck.csh
