#!/usr/local/bin/tcsh -f
#################################################################
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

echo "#---------------------------------------------------------------------------------------------------------------------#"
echo '# [#1247] Test the SIGWINCH deviceparameter for terminal devices                                                      #'
echo '# An expect script resizes the pty of a mumps -direct process (which delivers SIGWINCH) and verifies that:            #'
echo '#   1. with no handler set, a resize is ignored and the device WIDTH/LENGTH are not refreshed                         #'
echo '#   2. USE $principal:SIGWINCH=expr stores the handler and ZSHOW "D" displays it                                      #'
echo '#   3. a resize XECUTEs the handler after refreshing the device WIDTH/LENGTH to the new window size                   #'
echo '#   4. a resize in the middle of a READ runs the handler and the READ then resumes with its input intact              #'
echo '#   5. an error in the handler is reported and leaves the process usable                                              #'
echo '#   6. SIGWINCH="" removes the handler and resizes are ignored again                                                  #'
echo '#   7. a handler is free to HALT, terminating the process                                                             #'
echo "#---------------------------------------------------------------------------------------------------------------------#"
echo

set tname = sigwinch1247
# Disable readline so the direct mode transcript below is deterministic (ydb_readline is randomized by
# the test framework); the SIGWINCH out-of-band machinery is common to the readline and non-readline paths.
unsetenv ydb_readline
cp $gtm_tst/$tst/inref/sigwinch1247.m .
# Use .outx (not .out) file names below since the transcript includes an expected DIVZERO error message
# which the test framework error scan (com/errors.csh) should not treat as a test failure.
(expect -d $gtm_tst/$tst/u_inref/sigwinch_devparam-ydb1247.exp $tname > $tname.exp.outx) >& $tname.exp.dbg
perl $gtm_tst/com/expectsanitize.pl ${tname}.exp.outx >&! ${tname}.exp.sanitized.outx
cat ${tname}.exp.sanitized.outx
