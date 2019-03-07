#################################################################
#								#
# Copyright (c) 2004-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# source this file.
# usage:
# source $gtm_tst/com/switch_gtm_version.csh <ver> <image>
#
# this script saves off the previous GT.M version set in gtm_ver_save in case
# the caller wants to use it to switch back

if ("" == "$1") then
	echo "Please specify which version to switch to."
	exit
endif
setenv test_no_ipv6_ver 1
set ver_to_switch = "$1"
set ver_image = "$2"
setenv gtm_ver_noecho
set gtm_ver_save = "$gtm_exe:h:t"
# Some environment variables have to be disabled for prior versions, as they might have issues in the past.
set envlist_to_save = (gtmdbglvl gtmcompile)
set hugepages_env = (HUGETLB_MORECORE HUGETLB_SHM HUGETLB_VERBOSE LD_PRELOAD)
set disable_custom_errors = (gtm_custom_errors gtm_test_fake_enospc)
set set_to_empty_vars = (gtm_test_qdbrundown_parms)
if (("$ver_to_switch" != "$tst_ver") && ("$gtm_ver_save" == "$tst_ver")) then
	# if switching to versions prior to V6.0-002 unset custom errors settings (MREP GTM-7622_priorver_no_custom_errors)
	if (`expr "V60002" \> "$ver_to_switch"`) then
		set envlist_to_save = ($envlist_to_save $disable_custom_errors)
	endif
	# if switching to versions prior to V6.0-001 unset huge pages related environment variables
	if (`expr "V60001" \> "$ver_to_switch"`) then
		set envlist_to_save = ($envlist_to_save $hugepages_env)
	endif
	# if switching to versions prior to V6.3-000 set gtm_test_qdbrundown_parms to ""
	# since $gtm_test_qdbrundown_parms is used directly in scripts
	if (`expr "V63000" \> "$ver_to_switch"`) then
		set envlist_to_save = ($envlist_to_save gtm_test_qdbrundown_parms)
	endif
	# gtm_poollimit settings take effect with V6.3-000A and beyond.
	if (`expr "V63000A" \> "$ver_to_switch"`) then
		set envlist_to_save = ($envlist_to_save gtm_poollimit)
	endif
	# i.e switching from current -> old. save if the environment variable is existing
	foreach envvar ($envlist_to_save)
		printenv $envvar >&! /dev/null
		if ( ! $status) then
			setenv tst_save_$envvar `printenv $envvar`
			if ( $envvar =~ "*$set_to_empty_vars*" ) then
				setenv $envvar ""
			else
				unsetenv $envvar
			endif
		endif
	end
else if (("$ver_to_switch" == "$tst_ver") && ("$gtm_ver_save" != "$tst_ver")) then
	# i.e switching from old -> current. If the saved version of the environment variable is existing restore.
	foreach envvar ($envlist_to_save $hugepages_env $disable_custom_errors $set_to_empty_vars)
		printenv tst_save_$envvar >&! /dev/null
		if ( ! $status) then
			setenv $envvar `printenv tst_save_$envvar`
			unsetenv tst_save_$envvar
		endif
	end
else
	# It is either a current -> current switch or old -> old switch. Not doing anything.
endif

# There is no bta build for prior versions
if ("bta" == ${ver_image:al}) then
    set ver_image = "pro"
endif

source $gtm_tst/com/set_active_version.csh $ver_to_switch $ver_image
# setenv below is to ensure that utilities like GDE,MUPIP point to the desired gtm_exe
setenv GTM "$gtm_exe/mumps -direct"
setenv MUPIP "$gtm_exe/mupip"
setenv LKE "$gtm_exe/lke"
setenv DSE "$gtm_exe/dse"
setenv GDE "$gtm_exe/mumps -run GDE"
setenv verno "$gtm_exe:h:t"
source $gtm_tst/com/set_gtmroutines.csh "M"

# If the prior version supports encryption (from V53004 onwards) and the test is run with
# encryption then we have to change the gtm_passwd before the test attempts to use this
# version. Not doing so will let the test use the gtm_passwd created at the beginning
# of the test which is incorrect w.r.t to the chosen prior version due to the fact that
# the password masking logic uses inode number of the mumps executable
if ( ( "ENCRYPT" == "$test_encryption" ) && ( -x $gtm_tools/check_encrypt_support.sh ) ) then
	if ( "TRUE" == "`$gtm_tst/com/is_encrypt_support.csh $verno $ver_image`" )  then
		set maskpass = $gtm_dist/plugin/gtmcrypt/maskpass	# prior version's maskpass
		setenv gtm_passwd `echo $gtm_test_gpghome_passwd | $maskpass | cut -d " " -f3`
		# From V6.0-001 onwards, platforms that support encryption build all possible libraries. Currently, below is the
		# supported list.
		# 1. Library = libgcrypt; Algo = AES256CFB
		# 2. Library = libcrypto; Algo = AES256CFB
		# 3. Library = libcrypto; Algo = BLOWFISHCFB
		# If the prior version is pre-V6.0-001, then set an environment variable pointing to the library that knows to work
		# with the database created by the prior version. This way, the current version ($ver_to_switch) can decrypt the
		# encrypted content created by the prior version.
		# Note: From V6.3-001 onwards, BLOWFISHCFB is not supported.
		if ($ver_to_switch =~ "V9*" || `expr $ver_to_switch ">" "V60000"`) then
			if ("AIX" == $HOSTOS) then
				set encryption_lib = "openssl"
			else
				set encryption_lib = "gcrypt"
			endif
			set encryption_algorithm = "AES256CFB"
			setenv gtm_crypt_plugin libgtmcrypt_${encryption_lib}_${encryption_algorithm}${gt_ld_shl_suffix}
		endif
		setenv GTMXC_gpgagent $gtm_dist/plugin/gpgagent.tab
		# pinentry.m prior to V62002 was not UTF-8 compatible. This tells pinentry-test-gtm.sh to switch to M mode
		if (`expr $ver_to_switch "<" "V62002"`) then
			setenv gtm_test_force_pinentry_chset "M"
		else
			unsetenv gtm_test_force_pinentry_chset
		endif
	else
		# The version supports encryption, but the plugin isn't present.
		setenv test_encryption "NON_ENCRYPT"
	endif
endif

# If the prior version supports TLS (V61000 onwards) and the test is run with TLS,
# source set_tls_env.csh to reset gtmtls_passwd using the switched version
if ( ("TRUE" == "$gtm_test_tls") && (`expr $ver_to_switch ">=" "V61000"`) ) then
	source $gtm_tst/com/set_tls_env.csh
endif

if ($?gtm_chset) then
	if ( ("UTF-8" == $gtm_chset) && (52 <= `echo $1|cut -c2-3`) ) then
		# NOTE: Beginning V52 release  because of M vs UTF-8 compiled modules restrictions we need to set gtmroutines accordingly.
		source $gtm_tst/com/set_locale.csh
		source $gtm_tst/com/set_gtmroutines.csh "UTF8"
	endif
endif
if (-e $tst_general_dir/run_cre_coll_sl_reverse.txt) then
	# It means $gtm_tst/com/cre_coll_sl_reverse.csh was run and
	# whenever we switch b/w 32 and 64 bit GTM, we need to rerun to create the appropriate (64/32) objects
	set tmp_gtm_collate_n = `cat $tst_general_dir/run_cre_coll_sl_reverse.txt`
	source $gtm_tst/com/cre_coll_sl_reverse.csh $tmp_gtm_collate_n
endif
# Prior versions may not support all the errors in the current custom_errors_sample.txt, so if gtm_custom_errors points to a
# sample file, and the sample file for the new version exists, point to that. Otherwise, leave it unmodified. Versions without
# a sample file don't support custom errors, and so will ignore it. Later, if the test switches back to a version with custom
# errors support it will get the correct sample file.
if ($?gtm_custom_errors) then
	if (("$gtm_custom_errors" =~ */tools/custom_errors_sample.txt) && (-e "$gtm_root/$ver_to_switch/tools/custom_errors_sample.txt")) then
		setenv gtm_custom_errors "$gtm_root/$ver_to_switch/tools/custom_errors_sample.txt"
	endif
endif
# this workaround is to avoid issues when switching between some V4 versions
setenv gtm_tools "$gtm_root/$gtm_curpro/tools"
