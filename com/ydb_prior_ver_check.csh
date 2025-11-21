#!/usr/local/bin/tcsh -f
#################################################################
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
#
# $1 - prior version to do checks against
# $2 - if specified, name of the host (local or remote) to specifically do the checks
#      this is currently needed to check if TLS needs to be disabled based on "ldd libgtmtls.so"
#      output on remote host in case of a multi-host "filter" test setup.
#
if ($?ydb_environment_init) then
	# This is a YDB setup.
	#
	# Versions prior to V63000A have issues running in UTF-8 mode (due to icu
	# library naming conventions that changed). So disable UTF8 mode testing in case the older version is < V63000A.
	if (`expr "V63000A" \> "$1"`) then
		if ($?gtm_chset) then
			if ("UTF-8" == $gtm_chset) then
				echo "# Overriding setting of gtm_chset by ydb_prior_ver_check.csh (prior_ver = $1)" >>&! settings.csh
				echo "setenv gtm_chset M" >>&! settings.csh
				$switch_chset M >>&! switch_chset_ydb.out
				rm -f rand.o >& /dev/null # usually created by random_ver.csh and could cause INVOBJFILE due to CHSET mismatch
			endif
		endif
	endif
	if ("arch" == $gtm_test_linux_distrib) then
		# On Arch Linux, versions <= V63000A have issues running with TLS (source server issues TLSDLLNOOPEN error
		# with detail "libgtmtls.so: undefined symbol: SSLv23_method"). So disable TLS in case a version <= V63000A
		# gets chosen on an Arch linux host
		if (`expr "V63000A" \>= "$1"`) then
			echo "# Overriding setting of gtm_test_tls by ydb_prior_ver_check.csh (prior_ver = $1)" >>&! settings.csh
			echo "setenv gtm_test_tls FALSE" >>&! settings.csh
			setenv gtm_test_tls "FALSE"
		endif
	endif
	# On Arch Linux, GT.M V62001 binaries installed from Sourceforge issue SIG-11 when trying to create multi-region gld
	# files with a gtmdbglvl setting of 0x1F0. Therefore disable gtmdbglvl in that case.
	if (`expr "V63000A" \> "$1"`) then
		echo "# Overriding setting of gtmdbglvl by ydb_prior_ver_check.csh (prior_ver = $1)" >>&! settings.csh
		echo "unsetenv gtmdbglvl" >>&! settings.csh
		unsetenv gtmdbglvl
	endif
	set disabletls = 0
	if ($ydb_test_tls13_plus) then
		# This is a system having TLS V1.3 which is not supported by the TLS plugin in pre-r1.24 builds of YottaDB.
		# If the test framework randomly chosen TLS, the source and/or receiver server running the pre-r1.24 build
		# would assert fail (SIG-6) in gtm_tls_impl.c line 1667 "assert(FALSE && ssl_version)". Therefore, disable
		# TLS in that case. In case the build is a pure GT.M build, TLS V1.3 is not supported either so disable TLS
		# in that case too. For example V63004 is a pure GT.M build but V63004_R122 is a YottaDB build of R1.22
		# (which had GT.M GT.M V6.3-004 integrated into it).
		if (!($1 =~ "V*_R*")) then
			# This is a pure GT.M build because it does not have a _Rxxx suffix (e.g. _R122)
			set disabletls = 1
			echo "# Overriding setting of gtm_test_tls by ydb_prior_ver_check.csh TLS V1.3 (prior_ver = $1 is pure GT.M build)" >>&! settings.csh
		else
			# Check if the YottaDB release i.e. xxx in Rxxx is less than 124.
			# Note that some versions might have been named V63009_R131C etc. In that case, only take 131
			# and ignore the trailing C etc. Hence the "cut" command below.
			set ydbrel = `echo $1 | sed 's/.*_R//g' | cut -b 1-3`
			if ($ydbrel < 124) then
				set disabletls = 1
				echo "# Overriding setting of gtm_test_tls by ydb_prior_ver_check.csh TLS V1.3 (prior_ver = $1 < R124)" >>&! settings.csh
			endif
		endif
	endif
	# Check if libgtmtls.so has issues with finding libssl.so or libconfig.so or any other dependent library.
	# a) We noticed libssl.so missing this in Ubuntu 22.04 where they decided to switch to libssl 3.0 (from version 1.1).
	#    In Ubuntu 21.10 we found a libssl1.1 package that provided the needed libraries for version 1.1.
	#    But in Ubuntu 22.04 LTS, they decided to do away with that package so the only solution was to recompile the
	#    older binaries with the newer libssl 3.0. Since there were other issues preventing the recompile from happening
	#    easily, we decided to disable TLS in the test in such cases.
	# b) We noticed libconfig.so.9 missing in Ubuntu 25.04. For similar reasons as (a), it was not possible to rebuild
	#    the older version with the available libconfig.so.11 and so we decided to disable TLS in the test in such cases.
	if ("$2" == "") then
		# Remote host name has not been specified. Do TLS check on local host.
		set notfound = `ldd $gtm_root/$1/pro/plugin/libgtmtls.so |& grep "not found"`
		set hoststr = ""
	else
		# Remote host name has been specified. Do TLS check on remote host.
		set notfound = `$ssh $2 "ldd $gtm_root/$1/pro/plugin/libgtmtls.so" |& grep "not found"`
		set hoststr = "on host = [$2] "
	endif
	if ("" != "$notfound") then
		set disabletls = 1
		echo "# Overriding setting of gtm_test_tls by ydb_prior_ver_check.csh $hoststr(prior_ver = $1) : [$notfound]" >>&! settings.csh
	endif
	if ($disabletls) then
		echo "setenv gtm_test_tls FALSE" >>&! settings.csh
		setenv gtm_test_tls "FALSE"
	endif
	# If this test chose r120 as the prior version, GDE won't work with that version unless ydb_msgprefix is set to "GTM".
	# (see https://gitlab.com/YottaDB/DB/YDB/issues/193 for details). Therefore, set ydb_msgprefix to "GTM" in that case.
	if ($1 == "V63003A_R120") then
		setenv ydb_msgprefix "GTM"
	endif
	# If the prior version is less than r2.04, then [mupip set -mutex_type] is not supported. In that case, disable
	# random mutex_type setting in dbcreate_base.csh by setting ydb_test_mutex_type to DEFAULT.
	set disable_mutex_type = 0
	if (!($1 =~ "V*_R*")) then
		# This is a pure GT.M build because it does not have a _Rxxx suffix (e.g. _R122)
		set disable_mutex_type = 1
		echo "# Overriding setting of ydb_test_mutex_type by ydb_prior_ver_check.csh (prior_ver = $1 is pure GT.M build)" >>&! settings.csh
	else
		# Check if the YottaDB release i.e. xxx in Rxxx is less than 204.
		# Note that some versions might have been named V63009_R131C etc. In that case, only take 131
		# and ignore the trailing C etc. Hence the "cut" command below.
		set ydbrel = `echo $1 | sed 's/.*_R//g' | cut -b 1-3`
		if ($ydbrel < 204) then
			set disable_mutex_type = 1
			echo "# Overriding setting of ydb_test_mutex_type by ydb_prior_ver_check.csh (prior_ver = $1 < R204)" >>&! settings.csh
		endif
	endif
	if ($disable_mutex_type) then
		echo "setenv ydb_test_mutex_type DEFAULT" >>&! settings.csh
		setenv ydb_test_mutex_type "DEFAULT"
	endif
endif
