#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo '# In GT.M versions V6.3-008 and later when entering a shell'
echo '# command line longer than 32KiB GT.M will issue an error of'
echo '# either CLIERR or CLISTRTOOLONG. In V6.3-007 a regression'
echo '# allowed this condition to cause a segmentation violation(SIG-11)'

echo '# We attempted to produce the CLIERR but we were not able to reproduce'
echo '# the error in our test'
echo '# Verifying that a shell command line over 32KiB reports a CLISTRTOOLONG'
$ydb_dist/mumps -run gtm9110
