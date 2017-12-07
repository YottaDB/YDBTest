#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if ("ENCRYPT" != "$test_encryption") then
	exit 0
endif

set available_list = ()
if ( "TRUE" == "`$gtm_tst/com/is_encrypt_support.csh ${gtm_dist:h:t} ${gtm_dist:t}`" ) then
	set default_link = "`filetest -L $gtm_dist/plugin/libgtmcrypt${gt_ld_shl_suffix}`"
	if ( "$default_link" == -1 ) then
		# libgtmcrypt.so is not a symlink, so assume an old version with default lib.
		set default_only
		if ("aix" == "$gtm_test_osname") then
			set default_lib = "openssl"
		else
			set default_lib = "gcrypt"
		endif
		set default_algo = "AES256CFB"
		set available_list = ( $default_lib )
	else
		unset default_only
		set gtmcrypt_libs=`echo $gtm_dist/plugin/libgtmcrypt_*_*${gt_ld_shl_suffix}`
		foreach lib ($gtmcrypt_libs)
			# Convert "/path/to/libgtmcrypt_lib_algo.so" into ("libgtmcrypt" "lib" "algo")
			set splitlib = ( ${lib:t:r:as/_/ /} )
			# Add lib to available_list, dropping any duplicates.
			set -l available_list = ($available_list $splitlib[2])
		end
		set default_split = (${default_link:r:as/_/ /})
		set default_lib = $default_split[2]
		set default_algo = $default_split[3]
	endif
endif

if ( $#available_list == 0 ) then
	set supported_list = "FALSE"
	setenv test_encryption "NON_ENCRYPT"
	echo "# This machine doesn't support OpenSSL or Libgcrypt"
	echo "setenv test_encryption NON_ENCRYPT"
else if (! $?gtm_crypt_plugin) then
	if ( ! $?default_only) then
		set supported_list = "$available_list"
		if ($?gtm_test_exclude_encrlib) then
			set -f exclude_list = ($gtm_test_exclude_encrlib)
			set supported_list = ()
			foreach lib ($available_list)
				# set -f : $lib is added to exclude_list_plus at the end "only" if it is not already in exclude_list
				set -f exclude_list_plus = ($exclude_list $lib)
				if ("$exclude_list_plus" != "$exclude_list") then
					# $lib is not in $exclude_list - add it to supported_list
					set -f supported_list = ($supported_list $lib)
				endif
			end
		endif
		if ( 0 == $#supported_list) then
			echo "# All available encryption libraries ($available_list) were excluded ($gtm_test_exclude_encrlib)"
			echo "setenv test_encryption NON_ENCRYPT"
			setenv test_encryption NON_ENCRYPT
			exit
		endif
		# With V6.0-001 onwards, we build 3 different encryption libraries as part of a regular build.
		# 1. Library = libgcrypt; Algo = AES256CFB
		# 2. Library = libcrypto; Algo = AES256CFB
		# 3. Library = libcrypto; Algo = BLOWFISHCFB
		# Randomly choose one of the three. Also randomly let the test pick default one pointed by libgtmcrypt.so
		# Note: From V6.3-001 onwards, BLOWFISHCFB is not supported.
		setenv encryption_lib `$gtm_dist/mumps -run chooseamong $supported_list`
		set algorithms = "AES256CFB"
		if ("openssl" == $encryption_lib) then
			set algorithms = "AES256CFB"
		endif
		set available_algo = "$algorithms"
		if ($?gtm_test_exclude_encralgo) then
			set -f exclude_list = ($gtm_test_exclude_encralgo)
			set algorithms = ()
			foreach algo ($available_algo)
				# set -f : $algo is added to exclude_list_plus at the end only if it is not already in exclude_list
				set -f exclude_list_plus = ($exclude_list $algo)
				if ("$exclude_list_plus" != "$exclude_list") then
					# $algo is not in $exclude_list - add it to algorithms list
					set -f algorithms = ($algorithms $algo)
				endif
			end
			# Note: If $gtm_test_exclude_encralgo is set increasing the probability of AES256CFB doesn't make sense
		endif
		if ( 0 == $#algorithms) then
			echo "# All available algorithms ($available_algo) were excluded ($gtm_test_exclude_encralgo)"
			echo "setenv test_encryption NON_ENCRYPT"
			setenv test_encryption NON_ENCRYPT
			exit
		endif
		\rm -f chooseamong.o
		setenv encryption_algorithm `$gtm_dist/mumps -run chooseamong $algorithms`
		\rm -f chooseamong.o
	endif
	# V53004..V54001 don't work with chooseamong, so use awk.
	set rand = `$tst_awk 'BEGIN { srand(); opt=int(4*rand())+1; print substr("0012", opt, 1) }'`

	if ( (! $?default_only) && ($rand == 0 || $?gtm_test_exclude_encrlib || $?gtm_test_exclude_encralgo ) ) then
		# If default_only is not set (in case of old versions) AND if rand = 0 or one of the libraries/algorithms is explicitly excluded
		# point gtm_crypt_plugin to a specific algorithm than to libgtmcrypt.so
		setenv gtm_crypt_plugin libgtmcrypt_${encryption_lib}_${encryption_algorithm}${gt_ld_shl_suffix}
	else
		# We either set gtm_crypt_plugin to "libgtmcrypt.so" to test the default case OR unsetenv gtm_crypt_plugin
		# which also picks up the default installation. In either case, we still need to set encryption_lib and
		# encryption_algorithm which is used by random_ver.csh. The default configuration can be obtained from the
		# script $gtm_tst_ver_gtmcrypt_dir/show_install_config.csh
		setenv encryption_lib $default_lib
		setenv encryption_algorithm $default_algo
		if ($rand == 1) then
			setenv gtm_crypt_plugin "libgtmcrypt"$gt_ld_shl_suffix
		else	# $rand == 2
			unsetenv gtm_crypt_plugin
		endif
	endif
	echo "# encryption_lib encryption_algorithm gtm_crypt_plugin randomized by set_encryption_lib_and_algo.csh"
	echo "setenv encryption_lib $encryption_lib"
	echo "setenv encryption_algorithm $encryption_algorithm"
	if ($?gtm_crypt_plugin) then
		echo "setenv gtm_crypt_plugin $gtm_crypt_plugin"
	else
		echo "# gtm_crypt_plugin unset intentionally"
		echo "unsetenv gtm_crypt_plugin"
	endif
else
	echo "# gtm_crypt_plugin was already set before coming into do_random_settings.csh"
	echo "setenv gtm_crypt_plugin $gtm_crypt_plugin"
	# Even though $gtm_crypt_plugin is already specified in the test startup command, set encryption_lib and
	# encryption_algorithm in case a test needs it explicitly.
	if ($gtm_crypt_plugin =~ libgtmcrypt_*_*${gt_ld_shl_suffix}) then
		set gcp_split=(${gtm_crypt_plugin:r:as/_/ /})
		setenv encryption_lib $gcp_split[2]
		setenv encryption_algorithm $gcp_split[3]
	else
		setenv encryption_lib $default_lib
		setenv encryption_algorithm $default_algo
	endif
endif
