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
# MUPIP LOAD V5 data into a V4 database. Should load with truncated values.
# By V5 data we mean, Long named (<=31) globals
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
# MM access method works well only from versions V5.3-002. Since the test uses V4 version, force BG
source $gtm_tst/com/gtm_test_setbgaccess.csh

$gtm_tst/com/dbcreate.csh mumps
$GTM << EOF
w \$ZV
do ^varsize
h
EOF

$MUPIP extract -format=zwr v5xtract.zwr >>& v5xtract.out
$gtm_tst/com/dbcheck.csh

# switch to a old versions
setenv version_list `$gtm_tst/com/random_ver.csh -type V4`
if ("$version_list" =~ "*-E-*") then
	echo "There are no V4 versions. Exiting"
	exit 1
endif
#
#check_versions.csh uses env. variable "version_list" for the list of old versions to iterate in the loop
$gtm_tst/com/check_versions.csh mupip_load_switch mupip_load_switch
#
