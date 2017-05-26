#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

if (-f $tmp_gtm_dist/plugin/libgtmcrypt.so || -f $tmp_gtm_dist/plugin/libgtmcrypt.sl || -f $tmp_gtm_dist/plugin/libgtmcrypt.dll) then
	set version_support_enc = "TRUE"
else
	set version_support_enc = "FALSE"
endif

if ("TRUE" == $version_support_enc) then
	echo "TRUE"
else
	echo "FALSE"
endif
exit 0
