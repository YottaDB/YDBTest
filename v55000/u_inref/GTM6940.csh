#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################
#
# A $ZInterrupt executing a ZWRITE or MERGE that got an error did not
# recover gracefully. Assert fails or error loops depending on build type.
#
setenv TERM xterm
(expect -d -f $gtm_tst/$tst/u_inref/GTM6940.exp $gtm_dist > GTM6940_expect.logs) >& expect.dbg
perl $gtm_tst/com/expectsanitize.pl GTM6940_expect.logs
