#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# The test system currently sets/uses/modifies GT.M env vars (e.g. "gtmgbldir"). Not YottaDB env vars (e.g. "ydb_gbldir").
# This means if the parent environment contains YottaDB env vars, it would override with the test system definition of the
# GT.M env vars. Therefore, unset the YottaDB env vars that mostly matter. While at that, also unset the corresponding GT.M
# env var in case it was set in the parent environment (since test will anyways set it later).
unsetenv ydb_boolean      gtm_boolean
unsetenv ydb_chset        gtm_chset
unsetenv ydb_ci           GTMCI
unsetenv ydb_etrap        gtm_etrap
unsetenv ydb_gbldir       gtmgbldir
unsetenv ydb_routines     gtmroutines
unsetenv ydb_side_effects gtm_side_effects
unsetenv ydb_xc_ydbposix  GTMXC_ydbposix
unsetenv ydb_readline
unsetenv ydb_statshare    gtm_statshare
unsetenv ydb_statsdir     gtm_statsdir	# this is defined to $tst_working_dir later in submit_subtest.csh
# Below env var could be set by "ydb_env_set" and could affect the test system so unset this too at the start of the test.
# (see https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1536#note_1193117974 for background)
unsetenv LD_LIBRARY_PATH
# Note that we do not do a blanket "unsetenv" of all "ydb_*" and "gtm*" env vars. This is because there are a few that
# we still need set (e.g. "gtm_dist", "gtm_test_*", "gtm_tst_*") from the parent environment as the test framework will use that.
# See https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1536#note_1193225854 for more details.

# Enable core dumping if unaligned access is detected on Tru64
set chkhost=`uname -s`
if ("OSF1" == $chkhost) then
	uac p sigbus
endif

#First define $gtm_test if it is not defined
if ($?gtm_test == 0) then
	if (`basename $0` == $0) then
		setenv gtm_test "$PWD"
	else
		setenv gtm_test `dirname $0`
	endif
endif

if !($?gtm_test_com_individual) then
	if ($0 =~ */T*/com/*) then
		#then gtmtest.csh is called from a version, pick that as gtm_test_com_individual
		setenv gtm_test_com_individual $0:h
		set gtm_test_com_individual_testver = $gtm_test_com_individual:h:t
	else
		setenv gtm_test_com_individual $gtm_test/T990/com
	endif
	setenv gtm_test_com_individual_set
endif

# IF LC_ALL is set in user's environment, unset it here. setting LC_COLLATE by set_specific.csh will be of no use if LC_ALL is set.
# Check <failures_due_to_sort_order>
# Also unset gtm_chset as there might be a mismatch between LC_ALL and gtm_chset if only one of them is unset.
# Check <GTM_E_NONUTF8LOCALE_if_cur_env_utf8>
unsetenv LC_ALL ; unsetenv gtm_chset
source $gtm_test_com_individual/set_specific.csh

if ($#argv == 0 ) then
	$tst_awk -f $gtm_test_com_individual/help_screen.awk $gtm_test_com_individual/arguments.csh | more
	exit 1
endif

######
# first read the defaults, so that anything unset will have a default value
if ($?gtm_dist == 0) then
   echo 'TEST-E-GTMDIST_UNDEFINED : gtm_dist env var is not defined. Cannot start any tests.'
   exit 40
endif

source $gtm_test_com_individual/defaults.csh $gtm_test_com_individual/defaults_common_csh
if ($status) exit $status
umask 002
# then source a conf file in home directory if exists
if (-e ~$user/.testrc) then
	source ~$user/.testrc
endif
# then parse command line
source $gtm_test_com_individual/arguments.csh $argv
if ($status) then
	$gtm_test_com_individual/clean_and_exit.csh
	exit 1
endif

######
# check if there is a test version for the GT.M version running. If not,
# a) pick the test version that started the test or
# b) see if a test version matching $tst_ver is available or
# c) pick from $gtm_test_com_individual

if !($?tst_src) then
	set src_matching_tst_ver=$tst_ver:s/V/T/
	if ($?gtm_test_com_individual_testver) then
		setenv tst_src $gtm_test_com_individual_testver
	else if (-e $gtm_test/$src_matching_tst_ver/com/gtmtest.csh) then
		setenv tst_src $src_matching_tst_ver
	else
		setenv tst_src $gtm_test_com_individual:h:t
	endif
endif

# Reset gtm_test_com_individual based on $tst_src above
if ($?gtm_test_com_individual_set) setenv gtm_test_com_individual $gtm_test/$tst_src/com

if ( $0 !~ *$tst_src* && ! "$?force_gtm_test_com_individual" ) then
	echo "TEST-I-GTMTEST_VERSION, Since the test version $tst_src will be used, it is best to use its gtmtest.csh"
	echo "This script will now call: $gtm_tst/com/gtmtest.csh $argv"
	echo '(Avoid this redirection with `setenv force_gtm_test_com_individual`)'
	echo "################################################################################"
	$gtm_tst/com/gtmtest.csh $argv
	set stat = $status
	echo "################################################################################"
	echo "TEST-I-EXIT_STATUS, The exit status from the gtmtest.csh call was: $stat"
	$gtm_test_com_individual/clean_and_exit.csh
	exit $stat
endif

# Source the actual test version's defaults
# remove the rm commands since such cleanup has already been done.
$grep -v "rm " $gtm_tst/com/defaults_csh >! ${TMP_FILE_PREFIX}_defaults_csh
source $gtm_test_com_individual/defaults.csh ${TMP_FILE_PREFIX}_defaults_csh
if ($status) exit $status

setenv lsof "$gtm_tst/com/lsof"	# Define "lsof" variable to point to centralized framework script

# The above "source" invocation would have defined "gt_ld_options_common" and "gtm_tst" env vars.
# The below "source" invocation would update "gt_ld_options_common" with "-fsanitize=address" if needed.
source $gtm_tst/com/set_ydb_build_env_vars.csh

# Set gtm_icu_version/ydb_icu_version env vars at startup
source $gtm_tst/com/set_icu_version.csh

source $gtm_tst/com/set_gtm_machtype.csh # do this before as it defines gtm_test_os_machtype env var (needed by set_ldlibpath.csh)
source $gtm_tst/com/set_ldlibpath.csh
# Various checks and exits :
if ( $USER =~ {library,,root} ) then
	echo "TEST-E-USER Do not run the tests as root or library"
	$gtm_test_com_individual/clean_and_exit.csh
	exit 1
endif

if (! -d $gtm_tst) then
	echo "TEST-E-TESTVERSION Test version $tst_src not found ($gtm_tst)"
	$gtm_test_com_individual/clean_and_exit.csh
	exit 2
endif

# Set env var is_tst_dir_ssd to 1 if disk containing $tst_dir is a SSD. And to 0 otherwise.
setenv is_tst_dir_ssd `$gtm_test_com_individual/is_curdir_ssd.csh $tst_dir`

# Set env var tst_dir_fstype based on the filesystem of $tst_dir.
setenv tst_dir_fstype `$gtm_test_com_individual/get_filesystem_type.csh $tst_dir`
setenv tmp_dir_fstype `$gtm_test_com_individual/get_filesystem_type.csh /tmp`

# Set env var to is_tst_dir_cmp_fs to 1 if disk containing $tst_dir is a compressed filesystem. And to 0 otherwise.
setenv is_tst_dir_cmp_fs `$gtm_test_com_individual/is_curdir_compressed_fs.csh $tst_dir`

if (`echo $tst_dir | $tst_awk -F/ '$2 ~/gtc/ || $2 ~/usr/ || $3 ~/gtc/ {print "1"}'`) then
	echo "TEST-E-DIR1 Will not submit the test in $tst_dir."
	echo "Please specify a non-/gtc/ non-/usr/ directory to run the tests."
	$gtm_test_com_individual/clean_and_exit.csh
	exit 3
endif

if (! -d $tst_dir) then
	mkdir $tst_dir
	if ($status) then
		echo "creating $tst_dir failed. Cleaning up and exiting now"
		$gtm_test_com_individual/clean_and_exit.csh
		exit 4
	endif
endif
if (!(-w $tst_dir)) then
	echo "Please specify a directory (with proper write access) for output"
	$gtm_test_com_individual/clean_and_exit.csh
	exit 6
endif

cd $tst_dir ; setenv tst_dir `pwd` ; cd -

if ($?gtm_test_replay) then
	if ! (-e $gtm_test_replay) then
		echo "The file $gtm_test_replay passed to gtm_test_replay does not exist. Cleaning up and exiting now"
		$gtm_test_com_individual/clean_and_exit.csh
		exit 7
	endif
endif

## Check if the dependencies to run the testsystem are in place
set setup_status = `source $gtm_test_com_individual/check_setup_dependencies.csh $gtm_test_com_individual`
if ("0" != "$setup_status") then
	echo "TEST-E-SETUP. Some setup dependency is missing. The check failed with $setup_status"
	exit 8
endif

## Check for sufficient disk space.
$gtm_test_com_individual/check_space.csh submit >&! ${TMP_FILE_PREFIX}_call_check_space.out
if ($status) then
	echo "TEST-E-SPACE Will not submit tests due to lack of space in $tst_dir"
	$df $tst_dir
	$gtm_test_com_individual/clean_and_exit.csh
	exit 9
endif

## Switch to the test version - Exit if version is not available
setenv gtm_ver_noecho
source $gtm_tst/com/set_active_version.csh $tst_ver $tst_image
if ( ("$tst_ver" != "${gtm_ver:t}") || ("$tst_image" != "${gtm_exe:t}") ) then
	echo "Unable to switch version to $tst_ver $tst_image. Exiting now"
	exit 10
endif
######
#determine the list of tests to be submitted
# commandline, request file (and exclude), minorbucket, bucket
# determine what bucket is submitted
if ("$bucket" != "") then
	# A bucket is requested, determine what bucket is requested
	foreach suite ($bucket)
		set suite = ` echo $suite|cut -c 1`
		if (("E" == "$suite") || ("e" == "$suite")) set ebucket
		if (("L" == "$suite") || ("l" == "$suite")) set lbucket
		if (("T" == "$suite") || ("t" == "$suite")) set tbucket
	end
endif
# if both E_ALL and L_ALL are submitted, we should error out
if (($?ebucket) && ($?lbucket)) then
	echo "TEST-E-DOUBLEBUCKET Cannot submit both E_ALL and L_ALL"
	$gtm_test_com_individual/clean_and_exit.csh
	exit 11
endif

#At this point, process the things that might have been set by different methods
if ($?test_list_only) then
	echo "These are the tests for $tst_src"
	echo "And their applicabilities"
	echo "All tests are applicable to: $test_default_applicable"
	more $gtm_tst/com/test_applic
	$gtm_test_com_individual/clean_and_exit.csh
	exit 12
endif
#########
if ("" == "$mailing_list" ) then
	echo "empty mailing list! No mail will be sent!"
	setenv tst_dont_send_mail
else
	setenv mailing_list "${mailing_list:as/ /,/}"
endif

### Check for various GT.M feature support ###
# Unicode support
if (! $?gtm_test_unicode_support) then
	setenv gtm_test_unicode_support "FALSE"
	set chkhost=`uname -s`
	if ("CYGWIN*" !~ $chkhost) then
		if ( -e $gtm_tools/check_utf8_support.csh ) then
			if ( "TRUE" == `$gtm_tools/check_utf8_support.csh` ) setenv gtm_test_unicode_support "TRUE"
		endif
	endif
endif
# Encryption support
set encrypt_supported = `$gtm_tst/com/is_encrypt_support.csh $tst_ver $tst_image`
# FIPS support
source $gtm_tst/com/set_fips_support.csh

#############################################
####System specific test excludes
if ($?gtm_test_noggsetup) then
	setenv gtm_test_noggusers 1
	setenv gtm_test_noggtoolsdir 1
	setenv gtm_test_noIGS 1
	setenv gtm_test_temporary_disable 1	# env var to temporarily disable a few tests to get clean E_ALL in non-GG setup
endif
set hostn = $HOST:r:r:r
if ($?cms_tools) then
	setenv gtm_server_location `$cms_tools/determine_server_location.csh`
else
	setenv gtm_server_location NONGG
endif
if ("2WL" == "$gtm_server_location") then
	echo "-x endiancvt"	>>&! $test_list
endif

# do not run dbg speed test
if ("dbg" == "$tst_image") then
	echo "-x speed" >>! $test_list
endif

# Speed Test disabled on ia64 if ver less V5.3
set gtm_ver_comparison = `echo $tst_ver | $tst_awk '{v = "V53000"; if ($1 < v) print "prev53"}'`
if (("prev53" == "$gtm_ver_comparison") && ("ia64" == "$gtm_test_machtype")) then
	echo "-x speed" >>! $test_list
endif

# Indicate whether autorelink is supported on the current platform.
setenv gtm_test_autorelink_support 1

# relink test disabled on HPUX-IA64
if ("HOST_HP-UX_IA64" == "$gtm_test_os_machtype") then
	echo "-x relink"        >>! $test_list
	unsetenv gtm_test_autorelink_support
endif

# Shared library and recursive relink not supported on i386
if ("x86" == "$gtm_platform") then
	echo "-x sharedlib"	>>! $test_list
	echo "-x relink"	>>! $test_list
	unsetenv gtm_test_autorelink_support
endif

# disable unicode tests if not supported
if ("FALSE" == "$gtm_test_unicode_support") then
	echo "-x unicode_socket"	>>! $test_list
	echo "-x unicode_io"		>>! $test_list
endif

# Assume triggers are always supported unless specified otherwise by gtm_test_trigger env var
# If gtm_test_trigger is set to zero, disable the triggers test
if ( $?gtm_test_trigger ) then
	if ( $gtm_test_trigger == 0 ) echo "-x triggers"	>>! $test_list
endif

# disable encryption tests if not supported
if ("TRUE" != "$encrypt_supported") echo "-x encryption"		>>! $test_list
# If -noencrypt is passed specifically, disable encryption test
if ($?test_encryption) then
	if ("ENCRYPT" != "$test_encryption") echo "-x encryption"	>>! $test_list
endif
# If tls is explicitly disabled, disable tls test
if ($?gtm_test_tls) then
	if ("TRUE" != "$gtm_test_tls") echo "-x tls"			>>! $test_list
endif

# disable dbx for pro builds on z/OS because the pro builds have no symbols
# disable for dbg as well to prevent getting CEE2530S A debug tool was not available.
# when this problem is resolved, restore && "pro" == $tst_image to if
# on HPPA, GDB is causing a GT.M process to be hung in the middle of gdsfilext <GDB_on_HPPA_kill_process_in_fsync>
if ( ("os390" == $gtm_test_osname) || ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") ) then
	setenv tst_disable_dbx
endif

# On platforms/hosts that do no have prior versions of GT.M disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	echo "-x dbcompatibility"					>>&! $test_list
	echo "-x 64bittn"						>>&! $test_list
	echo "-x filter"						>>&! $test_list
endif

# If the platform/host does not have GG structured build directory, disable tests that require them
if ($?gtm_test_noggbuilddir) then
	echo "-x relink"						>>&! $test_list
endif

# If env variable gtm_test_nomultihost is set, disable all multi-host testing
# (including the disabling of randomization of multisite_replic tests further down)
if ($?gtm_test_nomultihost) then
	echo "-x GT.CM"		>>! $test_list
	echo "-x tcp_bkup"	>>! $test_list
	echo "-x endiancvt"	>>! $test_list
endif

if ($?ydb_environment_init) then
	# We do not have a cross-endian platform in a YDB setup. So disable endianvt permanently.
	echo "-x endiancvt"	>>! $test_list
	setenv gtmtest_noxendian 1
endif

if ($?gtm_test_temporary_disable) then
	echo "-x dbload"		>>! $test_list	# needs $gtm_test/big_files/dbload/*.go
	echo "-x dbcompatibility"	>>! $test_list	# can be re-enabled once V63002/T63002 is released (wait for "gld_mismatch")
	echo "-x filter"		>>! $test_list	# can be re-enabled once V63002/T63002 is released
endif

#############
# If some servers are explicitly disabled, check if proper buddies are available, if not disable such testing
if ( ($?exclude_servers) && !($?gtm_test_nomultihost) ) then
	set b1 = `$gtm_tst/com/get_buddy_server.csh SE1`
	set b2 = `$gtm_tst/com/get_buddy_server.csh SE2`
	if ( ("$b1" == "$b2") || ("" == "$b1") || ("" == "$b2") ) then
		# Disable multi-host testing if two unique same endian buddies are not available
		# All multi-host tests have to be explicitly excluded because gtm_test_nomultihost is set here,
		# which would result in do_random_multihost.csh unconditionally setting test_replic_mh_type to 0
		# The below tests would then run in single-host mode incorrectly
		echo "-x tcp_bkup"	>>! $test_list
		echo "-x endiancvt"	>>! $test_list
		setenv gtm_test_nomultihost 1
	endif
	set b3 = `$gtm_tst/com/get_buddy_server.csh RE`
	if ("" == "$b3") then
		# The below tests require other endian buddy. Exclude them if it is not available
		echo "-x endiancvt"	>>! $test_list
		setenv gtmtest_noxendian 1
	endif
	set b4 = `$gtm_tst/com/get_buddy_server.csh GTCM`
	if (2 != $#b4) then
		# Exclude GT.CM tests if two unique GTCM buddies are not available
		echo "-x GT.CM" >>! $test_list
	endif

endif

############
# Exclude "go" test if ASAN is enabled and CLANG is the compiler (not GCC).
# --------------------------------------------------------------------------
# In this case we get errors like the following from a "go build".
#	/usr/bin/ld: dbg/libyottadb.so: undefined reference to `__asan_stack_free_7'
# Interestingly, this does not happen if GCC is the compiler.
# I suspect the issue is that "go build" is compiling the main executable without "-fsanitize=address"
# and is linking with "libyottadb.so" which has been compiled/linked with "-fsanitize=address".
# The solution suggested to work around this (see https://github.com/google/sanitizers/wiki/AddressSanitizerAsDso)
# is to use LD_PRELOAD which sounds risky and so I am not going there for now.
# Also https://go-review.googlesource.com/c/go/+/368834/2/doc/go1.18.html seems to suggest a new "-asan" option in "go build"
# which will let it interoperate with C code compiled with the address sanitizer.
# Therefore, we disable all "go" tests if ASAN is enabled AND YottaDB was built with CLANG.
if ($gtm_test_libyottadb_asan_enabled && ("clang" == $gtm_test_asan_compiler)) then
	echo "-x go" >>! $test_list
endif

#############################################
#process request file and command line arguments, for requests and excludes

if (-e $test_list) then
   # fills $exclude_file too
   $tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/request.awk $test_list>! $tmpfile
   source $tmpfile #this produces $test_list_1
   $tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/applic.awk $gtm_tst/com/test_applic $test_list_1 >>! $submit_tests_temp
endif

if (($?minorbucket)||("$bucket" != "")) then
   #reset env. vars --undefine and redefine
   foreach option ($tst_options_all)
      #echo "reset" $option
      unsetenv $option
      end
   echo "#Reset options for bucket submission" >! ${TMP_FILE_PREFIX}_option_default_2
   $tst_awk -f $gtm_tst/com/process.awk -f $gtm_test_com_individual/process_defaults.awk $gtm_test_com_individual/default_options_csh >>! ${TMP_FILE_PREFIX}_option_default_2
   source ${TMP_FILE_PREFIX}_option_default_2
   endif
#minorbucket requested
if ($?minorbucket) then
   #take the tests requested, but run all L/E tests for them
   foreach test_case (`cut -f 2,3 -d " " $test_list_1 |sort -u |sed 's/ /@/'`)
     $grep `echo $test_case|cut -f 1 -d @` $gtm_tst/com/SUITE |$grep " $LFE " >>! ${submit_tests_temp}_a
     set tst_name = `echo $test_case|cut -f 1 -d @`
     #grep each test (and the LE) from SUITE (instead of grep, AWK is used
     #since only specific fields are to be searched)
     $tst_awk '($2 ~ suite && $1 == tst){if ($1 !~ /#/)  print}' tst=$tst_name suite=$LFE $gtm_tst/com/SUITE >>! ${TMP_FILE_PREFIX}_buckets
   end

   #if there are any tests from SUITE
   if (-e ${TMP_FILE_PREFIX}_buckets) then
      #correct numbering
      $tst_awk '{print ++no[$1] " " $0}' ${TMP_FILE_PREFIX}_buckets >! $submit_tests
      #fill in missing options and test applicability
      $tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/applic.awk $gtm_tst/com/test_applic $submit_tests>! $submit_tests_temp
   endif
endif #minorbucket if

############################
# Total bucket (LE) requested, all other requests overriden,
# but excludes are accounted for

if ("$bucket" != "") then
   # A bucket is requested, determine tests to be run

   foreach suite ($bucket)
     set suite = ` echo $suite|cut -c 1`
     #grep each suite (instead of grep, AWK is used
     #since only a specific field is to be searched)
     $tst_awk '$2 ~ suite {if ($1 !~ /#/) print }' suite=$suite  $gtm_tst/com/SUITE >>! ${TMP_FILE_PREFIX}_buckets
   end
   #if there are any tests from SUITE
   if (-e ${TMP_FILE_PREFIX}_buckets) then
      $tst_awk '{print ++no[$1] " " $0}' ${TMP_FILE_PREFIX}_buckets >>! $test_list_1
      #run this through the applicability,too and fill in missing options
      $tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/applic.awk $gtm_tst/com/test_applic $test_list_1 >>! $submit_tests_temp
   endif

endif

# $LFE should be changed to E when the T_ALL is submitted since the individual test would expect $LFE to be E or L.
if ($?tbucket) setenv LFE "E"

####
#All tests requested are in $submit_tests_temp now
#Process the excludes now which are in $exclude_file
#Maybe some more functionality might be added later on.
#like exclude= basic BG

if (! -e $submit_tests_temp) then
	echo "TEST-E-NOTESTSUB $submit_tests_temp does not exist. No tests were submitted!"
	echo "Exiting now. ${TMP_FILE_PREFIX}_* files will not be cleaned up"
	exit 13
endif

if (-e $exclude_file) then
	$grep -v -f $exclude_file $submit_tests_temp >! ${TMP_FILE_PREFIX}_submit_tests_temp3
else
	\cp $submit_tests_temp ${TMP_FILE_PREFIX}_submit_tests_temp3
endif
#the reason of a test's cancellation starts with a #
$grep "#" ${TMP_FILE_PREFIX}_submit_tests_temp3 > /dev/null
if (! $status) then
	echo "############################"
	echo "TEST-W-APPLIC Some tests are canceled due to appplicability.  The list is:"
	$grep "#" ${TMP_FILE_PREFIX}_submit_tests_temp3
	echo "############################"
endif
#the file exists, but is empty
if (`cat ${TMP_FILE_PREFIX}_submit_tests_temp3 | $grep -v "#" ` == "") then
	#the file does exist, but is it empty (or just has canceled elements)
	#the reason of a test's cancellation starts with a #
	$tst_awk '$1 ~/#/ {print }' $submit_tests
	echo "TEST-E-NOTESTS No test specified, or all requested tests excluded"
	echo "Exiting now. ${TMP_FILE_PREFIX}_* files will not be cleaned up"
	exit 14
endif
# remove canceled tests altogether
$grep -v "#" ${TMP_FILE_PREFIX}_submit_tests_temp3 >! ${TMP_FILE_PREFIX}_submit_tests_temp4
# randomly inverse the test suite if it is -E_ALL - Don't inverse if $eall_noinverse is set
set rand_no = `date | $tst_awk '{srand() ; print (int(rand() * 2))}'`
if (($?ebucket) && ($rand_no) && !($?eall_noinverse)) then
	$tst_awk '{ test[NR]=$0 } END { for(i=NR; i; --i) print test[i] } ' ${TMP_FILE_PREFIX}_submit_tests_temp4 >! $submit_tests
else
	cp ${TMP_FILE_PREFIX}_submit_tests_temp4 $submit_tests
endif

#####
#to correct numbering to the universal numbers
if (! -e $gtm_tst/com/determine_test_num.txt) then
	echo "TEST-E-INCVER, Incorrect test version, $gtm_tst/com/determine_test_num.txt does not exist"
	$gtm_test_com_individual/clean_and_exit.csh
	exit 15
endif
cp $submit_tests ${TMP_FILE_PREFIX}_submit_tests_temp1
$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/determine_test_num.awk -v "unix=1" $gtm_tst/com/determine_test_num.txt ${TMP_FILE_PREFIX}_submit_tests_temp1 >! $submit_tests
#####
# re-number those tests that were submitted multiple times
mv $submit_tests ${TMP_FILE_PREFIX}_submit_tests_temp2
$tst_awk '$1 !~ /#/ {seen[$1,$2]++; if (1 != seen[$1,$2]) $1 = $1"_"seen[$1,$2]; print $0}' ${TMP_FILE_PREFIX}_submit_tests_temp2 >! $submit_tests
#####
if ($test_num_runs != 1) then
	mv $submit_tests ${TMP_FILE_PREFIX}_tmp_submit_test
	set num_run = 1
	while ($num_run <= $test_num_runs)
		cat ${TMP_FILE_PREFIX}_tmp_submit_test | $tst_awk '{$1 = $1 "_" num_run;print }' num_run=$num_run>>! $submit_tests
		@ num_run = $num_run + 1
	end
	\rm ${TMP_FILE_PREFIX}_tmp_submit_test
	endif



if (`cat $submit_tests` == "") then
   #the file does exist, but is it empty
   echo "$submit_tests is empty. No test specified, or all requested tests excluded or eliminated (due to applicability)"
   echo "Exiting now. ${TMP_FILE_PREFIX}_* files will not be cleaned up"
   exit 16
endif
# determine host,remote server locations
if ($?cms_tools) then
	setenv gtm_remote_location `$cms_tools/determine_server_location.csh $tst_remote_host:r:r:r`
	# check if the remote location and the test originating location are on the same side of the tunnel
	if ( "$gtm_server_location" != "$gtm_remote_location" ) then
		set tmpfile = /tmp/__${USER}_location_error_$$.out
		echo "TEST-E-REMOTEHOST ACROSS LOCATION. chosen replication server is across locations - i.e 2WL vs MID" >&! $tmpfile
		echo "Host $tst_org_host is at $gtm_server_location but remote host $tst_remote_host is at $gtm_remote_location" >>&! $tmpfile
		echo "test submitted as " >>&! $tmpfile
		echo "$argv" >>&! $tmpfile
		echo "Pls. re-submit test picking a remote host from $gtm_server_location. Exiting..." >>&! $tmpfile
	#	At this point when we exit we don't have even test dirs created, so let's mail the user as to what went wrong
	#	for a quick update/reason instead of getting puzzled later.
		if (!($?tst_dont_send_mail)) mailx -s "TEST-E-REMOTEHOST ACROSS LOCATION, $hostn did not run tests" $mailing_list < $tmpfile
		cat $tmpfile;rm -f $tmpfile
		$gtm_test_com_individual/clean_and_exit.csh
		exit 17
	endif
else
	setenv gtm_remote_location NONGG
endif

#if there is (at least one) test that is REPLIC, set test_replic
unsetenv test_replic
unsetenv tst_other_servers_list_ms
$grep " REPLIC" $submit_tests >& /dev/null
if ($status == 0 ) setenv test_replic 1
$grep " MULTISITE" $submit_tests >& /dev/null
if ($status == 0 ) then
	setenv test_replic "MULTISITE"
endif
# if there is (at least one) test that is GT.CM, set test_gtm_gtcm_one
unsetenv test_gtm_gtcm_one
$grep " GT.CM" $submit_tests >& /dev/null
if ($status == 0 ) setenv test_gtm_gtcm_one
#################################################################
#for debugging
if ($?test_debug_print_only) then
	# for debugging
	cat $submit_tests
	echo "No of Tests submitted :: "`wc -l $submit_tests | $tst_awk '{print $1}'`
	echo "Test Version                   :: $tst_ver"
	echo "Test Image                     :: "`basename $gtm_dist`
	echo "Test Mail List                 :: $mailing_list"
	echo "Test Output Directory (base)   :: $tst_dir"
	echo "Test Source Directory          :: $tst_src"
	if ($?test_replic) then
		echo "Test Remote Host               :: $tst_remote_host"
		echo "Test Remote Directory          :: $tst_remote_dir"
	endif
	if (($?test_replic)||($?test_gtm_gtcm_one)) then
	   echo "Test Remote Version            :: $remote_ver"
	   echo "Test Remote Image              :: $remote_image"
	   echo "Test Remote User               :: $tst_remote_user"
	endif
	echo " "
   $gtm_test_com_individual/clean_and_exit.csh
   exit 18
endif
#############################################################################
if ($?gtm_test_dryrun) then
	echo "#############################################################################"

	echo "TEST-W-DRYRUN This is a dry run, no subtests will be submitted."
	echo "Note that a warning line will be printed in outstream.log. "
	echo "Remove it when creating the reference file."
	echo "#############################################################################"
endif

if ("$gtm_test_run_time" != "now") then
	set at_temp_file = ${TMP_FILE_PREFIX}_at_temp_file
	echo "$tst_tcsh -c ls >& /dev/null" |  at $gtm_test_run_time >&  $at_temp_file
	$atrm `$tst_awk -f $gtm_test_com_individual/at.awk -v remove=1 $at_temp_file`
	set test_dirn = `$tst_awk -f $gtm_test_com_individual/at.awk $at_temp_file`
	\rm -f $at_temp_file >& /dev/null
endif


# After this point, gtcm_command.csh can be used for all GT.CM related commands, since the env.var.s it needs are setup

if  ("$gtm_test_run_time" == "now") then
	set test_dirn = `date +%y%m%d_%H%M%S`
endif
setenv gtm_test_server_serial_no ""
if ($?cms_tools) then
	if (-e $cms_tools/tstdirs) then
		# get the default directories for each host
		source $cms_tools/tstdirs
		# search for the host in tstdirs, and determine its serial no. (the first part of the comment line)
		setenv gtm_test_server_serial_no `$grep -vE "^[ 	]#" $cms_tools/tstdirs | $tst_awk -F "#" '/_'${tst_org_host}'( |	)/ {print $NF}'`
		# and server location is already determined in var. gtm_server_location
	endif
endif
if ($?ydb_environment_init) then
	setenv gtm_test_server_serial_no `$tst_awk '($2 == "gtm_tstdir_'$hostn'") {print $0;}' $gtm_test/tstdirs.csh | $tst_awk -F "#" '/_'$hostn'( |)/ {print $NF}'`
endif
if ("" == "$gtm_test_server_serial_no") setenv gtm_test_server_serial_no "00" # default, in case no serial no is found (such as linux boxes)
setenv gtm_test_port_range $gtm_test_server_serial_no
if ("ATL" != "$gtm_server_location") then
	setenv gtm_test_port_range `expr $gtm_test_server_serial_no - 40`
endif
if (0 > $gtm_test_port_range) setenv gtm_test_port_range 00
setenv gtm_tst_out `mktemp -d $tst_dir/tst_${tst_ver}_${gtm_exe:t}_${gtm_test_server_serial_no}_${test_dirn}_XXX`  # unique
chmod 755 $gtm_tst_out   # ensures directory is accessible by other userids in the same group (e.g. gtmtest1)
setenv gtm_tst_out `echo $gtm_tst_out | sed -e "s|$tst_dir/||"`   # gtm_tst_out shouldn't have $tst_dir/ on the front

if ($status == 0) then
	echo "Created ${tst_dir}/$gtm_tst_out"
	chmod g+w $tst_dir/$gtm_tst_out
else
	echo "Could not create directory $tst_dir_$gtm_tst_out. ERROR"
	$gtm_test_com_individual/clean_and_exit.csh
	exit 19
endif

if ($?gtm_test_buildcycle) then
	set build_ver_log_dir = $ggdata/tests/buildver_logs
	if (! -d $build_ver_log_dir) then
		mkdir -p $build_ver_log_dir
		if ($status) then
			echo "TEST-E-BUILDVERLOGDIR, Could not create log directory $build_ver_log_dir"
			set dontwritebuildlog
		endif
	endif
	if (! $?dontwritebuildlog) then
		if !($?gtm_server_location) setenv gtm_server_location ""
		set build_ver_log_file = "$build_ver_log_dir/testdirs_$tst_ver.log.$gtm_server_location"
		if ((-e $build_ver_log_file) && (! -w $build_ver_log_file)) then
			echo "TEST-W-BUILDLOG_WRITE could not write to the buildver_log ($build_ver_log_file), do not have write access"
		else
			echo "${hostn}:$tst_dir/$gtm_tst_out" >>! $build_ver_log_file
			if ($status) then
				echo "TEST-E-BUILDLOG_WRITE could not write to the buildver_log ($build_ver_log_file), do not have write access"
			endif
		endif
	endif
endif
##################
# Check if it is "non-allowed" directory again
if (`echo $tst_dir | $tst_awk -F/ '$2 ~/gtc/ || $2 ~/usr/ || $3 ~/gtc/ {print "1"}'`) then
   echo "TEST-E-DIR2 Will not submit the test in $tst_dir."
   echo "Please specify a non-/gtc/ non-/usr/ directory to run the tests."
   echo "The directory $tst_dir/$gtm_tst_out has been created. Please remove it."
   $gtm_test_com_individual/clean_and_exit.csh
   exit 20
endif
########################
#############################################################################
#set directories from the corrected tst_dir
###########################################
# Copy the replay settings file now
if ($?gtm_test_replay) then
	set newfilename = $tst_dir/$gtm_tst_out/debugfiles/replay_settings.csh
	mkdir -p $newfilename:h
	cp $gtm_test_replay $newfilename
	setenv gtm_test_replay $newfilename
endif
# create the cleanup script as well.
set cleanup_script = $tst_dir/$gtm_tst_out/cleanup.csh
echo "#\!/usr/local/bin/tcsh -f" >>! $cleanup_script
chmod +x $cleanup_script
if ("default" != "$tst_jnldir") echo "rm -rf $tst_jnldir/$gtm_tst_out" >>! $cleanup_script
if ("default" != "$tst_bakdir") echo "rm -rf $tst_bakdir/$gtm_tst_out" >>! $cleanup_script

# take care of the renaming (test assignments) in cleanup.csh:
sed 's,\(_[0-9][0-9]_[0-9][0-9]\)/,\1/*,g' $cleanup_script >! ${TMP_FILE_PREFIX}_cleanup_csh
mv ${TMP_FILE_PREFIX}_cleanup_csh $cleanup_script

############################################################################################################
#### Is encryption supported on this platform ? If not, unconditionally disable encryption

# Encryption support
if ("TRUE" != "$encrypt_supported") then
	setenv test_encryption NON_ENCRYPT # No more randomizations for -encrypt in do_random_settings.csh
endif

##############################################################################
#at this point, all environment variables necessary to run the tests must
#have been set, through (in decreasing order of priority)
# 1. command line arguments
# 2. personal rc file
# 3. default configuration file (cannot be overriden)
#
# tests are ready to be run.
#set other necessary environment variables
#############################################################################

if ("$test_want_concurrency" == "yes") then
   if ("$test_load_dir" == "") then
      setenv test_load_dir "$tst_dir/$gtm_tst_out/_load"
   endif
   if ( ! (-e $test_load_dir) ) mkdir -p $test_load_dir
 endif

if ("$test_want_concurrency" == "yes"  &&  !(-e $test_load_dir/loadinp.m)) then
   \cp $gtm_tst/com/{clear,loadinp,load,unload,getnear}.m $test_load_dir

   if (!(-e $test_load_dir/load.dat)) then
      pushd $test_load_dir
      setenv gtmgbldir load.gld
      if (!(-e load.gld)) then
	 $gtm_exe/mumps -run GDE << GDEEOF
	    ch -s DEFAULT -file=load.dat
	    exit
GDEEOF
      endif
      $gtm_exe/mupip create
      $gtm_exe/mumps -direct <<GTMEOF
	  d ^loadinp
	  h
GTMEOF
     popd
  endif
endif

###################################################################################
echo "Test Version            :: $tst_ver"
echo "Test Image              :: "`basename $gtm_dist`
echo "Test Mail List          :: $mailing_list"
echo "Test Output Directory   :: $tst_dir/$gtm_tst_out"
echo "Test Source Directory   :: $tst_src"
if (($?test_replic)||($?test_gtm_gtcm_one)) then
	echo "Test Remote Host        :: $tst_remote_host"
	echo "Test Remote Version     :: $remote_ver"
	echo "Test Remote Image       :: $remote_image"
	echo "Test Remote User        :: $tst_remote_user"
endif
echo " "


set confil = $tst_dir/$gtm_tst_out/config.log
echo " " > $confil
echo "GTMTEST ARGUMENTS: $argv"			>> $confil
echo " " 					>> $confil
echo "OUTPUT CONFIGURATION"			>> $confil
echo " " 					>> $confil
echo "PRODUCT:  GT.M/GT.CM"			>> $confil
echo "VERSION:  `basename $gtm_ver`"		>> $confil
set time_stamp = `ls -ld $gtm_ver| $tst_awk '{if (length($7)==1) $7="0"_$7; time=$6"_"$7"_"$8;  print toupper(time)}' | sed 's/://g'`
echo "TIME STAMP:       $time_stamp"		>> $confil
echo "IMAGE:            `basename $gtm_dist`"	>> $confil
echo "TEST SOURCE:      $gtm_tst"		>> $confil
echo "HOST:             $hostn"			>> $confil
echo "HOSTOS:           $HOSTOS"		>> $confil
echo "USER:             $USER"			>> $confil
echo "MAIL TO:          $mailing_list"		>> $confil
echo "TEST JNL DIR:     $tst_jnldir"		>> $confil
echo "TEST BACKUP DIR:  $tst_bakdir"		>> $confil
if ($?test_replic) echo "REMOTE HOST:      $tst_remote_host"	>> $confil
if (($?test_replic)||($?test_gtm_gtcm_one)) then
   echo "REMOTE VERSION:   $remote_ver"				>> $confil
   echo "REMOTE IMAGE:     $remote_image"			>> $confil
   echo "REMOTE USER:      $tst_remote_user"			>> $confil
endif
if ($?test_replic) then
   echo "TEST REMOTE DIR:  $tst_remote_dir"			>> $confil
   echo "BUFFSIZE:         $tst_buffsize"			>> $confil
   echo "LOG:              $tst_rf_log"				>> $confil
   echo "TEST REMOTE JNL DIR:	$tst_remote_jnldir" 		>> $confil
   echo "TEST REMOTE BACKUP DIR:	$tst_remote_bakdir"	>> $confil
endif
echo " "        >> $confil
#call a new shell script after this point
\cp $submit_tests $tst_dir/$gtm_tst_out/submitted_tests

if ($?test_no_background) then
   $gtm_tst/com/submit.csh  -f < /dev/null
   exit $status
else
   if ("$gtm_test_run_time" == "now" || "$gtm_test_run_time" == "") then
	$gtm_tst/com/submit.csh -f < /dev/null >& /dev/null &
   else
	set at_script = $tst_dir/$gtm_tst_out/at_script # keep the at script in the test output directory itself
	echo "#\!/usr/local/bin/tcsh -f" >>! $at_script
	setenv | $grep -v "TERMCAP"| sed 's/=/ "/' | sed 's/$/"/'  | sed 's/^/setenv /' >> $at_script
   	echo "$tst_tcsh $gtm_tst/com/submit.csh -f < /dev/null" >> $at_script
	# HP-UX wont take echo "$shell -f at_script  >>& /dev/null"
	chmod a-w $at_script
	chmod +x $at_script
	echo "$at_script " | at $gtm_test_run_time
   endif
endif
