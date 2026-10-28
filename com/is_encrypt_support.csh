#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Figure out if the given host supports encryption
if ($# < 2) then
	echo "Usage: $0 remote_ver remote_image"
	exit 1
endif

setenv tmp_gtm_dist "$gtm_root/$1/$2"

set version_support_enc = "FALSE"
foreach plugin ($tmp_gtm_dist/plugin/libgtmcrypt.so $tmp_gtm_dist/plugin/libgtmcrypt.sl $tmp_gtm_dist/plugin/libgtmcrypt.dll)
	if (-f $plugin) then
		set version_support_enc = "TRUE"
		break
	endif
end

if ("TRUE" == $version_support_enc) then
	# The plugin exists but could still fail to load at run time (CRYPTDLNOOPEN) if a library it depends on is
	# not installed on this system. For example, an older build's plugin needs libgpgme.so.11 which is not available
	# in Ubuntu 26.04. Treat such a build as not supporting encryption, like com/ydb_prior_ver_check.csh does for TLS.
	set notfound = `ldd $plugin |& grep "not found"`
	if ("" != "$notfound") then
		set version_support_enc = "FALSE"
	endif
endif

if ("TRUE" == $version_support_enc) then
	echo "TRUE"
else
	echo "FALSE"
endif
exit 0
