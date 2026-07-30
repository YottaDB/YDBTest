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
echo '# [#1247] Test that GDE uses the SIGWINCH deviceparameter to keep up with terminal window resizes                     #'
echo '# An expect script resizes the pty of a GDE session and verifies that:                                                #'
echo '#   1. SHOW -SEGMENT output that wraps at the 80 column startup width does not wrap after widening to 132 columns     #'
echo '#   2. GDE invoked from a mumps process removes its SIGWINCH handler when it returns to the caller                    #'
echo '#   3. GDE leaves a SIGWINCH handler that the caller already set up alone, and it works during and after GDE          #'
echo "#---------------------------------------------------------------------------------------------------------------------#"
echo

set tname = gde1247
# Disable readline so the transcript is deterministic (ydb_readline is randomized by the test framework)
unsetenv ydb_readline
# Use a short /tmp global directory path so the GDE messages that include the path never wrap at 80 columns;
# the process id in the name is normalized by the sed below to keep the reference file deterministic
setenv ydb_gbldir /tmp/gde1247_$$.gld
rm -f $ydb_gbldir
cp $gtm_tst/$tst/inref/sigwinch1247.m .
# Use .outx (not .out) file names below so the test framework error scan does not pick over raw expect output
(expect -d $gtm_tst/$tst/u_inref/gde_sigwinch-ydb1247.exp $tname > $tname.exp.outx) >& $tname.exp.dbg
perl $gtm_tst/com/expectsanitize.pl ${tname}.exp.outx | sed "s/gde1247_[0-9]*[.]gld/gde1247.gld/g" >&! ${tname}.exp.sanitized.outx
cat ${tname}.exp.sanitized.outx
rm -f $ydb_gbldir
