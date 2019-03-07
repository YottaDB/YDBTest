#!/usr/local/bin/tcsh -f
#################################################################
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

# icu-config --version can return values like 50.1.2, 55.1, 57.1, 59.1
# In these cases, we want ydb_icu_version to be set to 5.0, 5.5, 5.7, 5.9 respectively.
set icuver = `icu-config --version | cut -d. -f1`
setenv ydb_icu_version `expr $icuver / 10`.`expr $icuver % 10`

# set gtm_icu_version too in case we run pre-r1.22 versions (they don't understand ydb_icu_version)
setenv gtm_icu_version $ydb_icu_version

