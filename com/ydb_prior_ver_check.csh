#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# $1 - prior version to do checks against
#
if ($?ydb_environment_init) then
	# This is a YDB setup.
	#
	# Versions prior to V63000A have issues running in UTF-8 mode (due to icu
	# library naming conventions that changed). So disable UTF8 mode testing in case the older version is < V63000A.
	if (`expr "V63000A" \> "$1"`) then
		if ($?gtm_chset) then
			if ("UTF-8" == $gtm_chset) then
				$switch_chset M >>&! switch_chset_ydb.out
				rm -f rand.o >& /dev/null # usually created by random_ver.csh and could cause INVOBJFILE due to CHSET mismatch
			endif
		endif
	endif
	# On Arch Linux, versions <= V63000A have issues running with TLS (source server issues TLSDLLNOOPEN error
	# with detail "libgtmtls.so: undefined symbol: SSLv23_method"). So disable TLS in case a version <= V63000A gets chosen.
	# Since it is not straightforward to disable this only for Arch Linux, we disable it for all linux distributions.
	if (`expr "V63000A" \>= "$1"`) then
		setenv gtm_test_tls "FALSE"
	endif
	# On Arch Linux, GT.M V62001 binaries installed from Sourceforge issue SIG-11 when trying to create multi-region gld
	# files with a gtmdbglvl setting of 0x1F0. Therefore disable gtmdbglvl in that case.
	if (`expr "V63000A" \> "$1"`) then
		unsetenv gtmdbglvl
	endif
endif
