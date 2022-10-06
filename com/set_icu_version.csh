#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
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
setenv ydb_icu_version `readlink /usr/lib*/libicuio.so /usr/lib*/*/libicuio.so | sed 's/libicuio.so.\([a-z]*\)\([0-9\.]*\)/\2.\1/;s/\.$//;'`

# set gtm_icu_version too in case we run pre-r1.22 versions (they don't understand ydb_icu_version)
setenv gtm_icu_version $ydb_icu_version

