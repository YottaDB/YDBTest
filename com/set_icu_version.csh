#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# We had code here that used to set ydb_icu_version as follows.
#      setenv ydb_icu_version `pkg-config --modversion icu-io`
# This used to set the env var to a value like 65.1
# But this does not work on SLED 15 as libicuio.so points to a file called libicuio.so.suse65.1.
# Need to set ydb_icu_version to 65.1.suse in that case. The below sed command takes care of that.
# Need "sort -u" in case /usr/lib64 is a soft link to /usr/lib as we would then get duplicate lines (seen in Ubuntu AARCH64)
setenv ydb_icu_version `readlink /usr/lib*/libicuio.so /usr/lib*/*/libicuio.so | sort -u | sed 's/libicuio.so.\([a-z]*\)\([0-9\.]*\)/\2.\1/;s/\.$//;'` \ ||
	echo "set_icu_version.csh: could not set ydb_icu_version" && exit 1

# Set a different env var that holds just the numeric (only major/minor) part of the icu version for later use by tests
setenv gtm_tst_icu_numeric_version `echo $ydb_icu_version | cut -d. -f1` \ ||
	echo "set_icu_version.csh: could not set gtm_tst_icu_numeric_version" && exit 1

# set gtm_icu_version too in case we run pre-r1.22 versions (they don't understand ydb_icu_version)
setenv gtm_icu_version $ydb_icu_version

