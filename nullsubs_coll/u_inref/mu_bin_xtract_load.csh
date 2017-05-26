#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# load mupip binary extract of V4 database to a V5 database.
# switch between stdnullcolls & nostdnullcolls in V5 & check.
#

# This test uses extract of a V4 database which is guaranteed to be in M mode. So no point running this test in UTF-8 mode.
# Unconditionally switch to M mode.
$switch_chset "M" >& switch_chset.log
# This test uses V4 versions in a lot of subtests. MM access method works well only from versions V5.3-002.
source $gtm_tst/com/gtm_test_setbgaccess.csh

setenv version_list `$gtm_tst/com/random_ver.csh -type V4`
if ("$version_list" =~ "*-E-*") then
	echo "There are no V4 versions. Exiting"
	exit 1
endif
#
# check_versions.csh uses env. variable "version_list" for the list of old versions to iterate in the loop
$gtm_tst/com/check_versions.csh bin_xtract_load_switch bin_xtract_load_switch
#
