#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# run this test with gtm_principal set to "abc" and verify it is passed to mumps process
# For a non-split $P, $ZPIN and $ZPOUT print as the value of $P
# For a split device $ZPIN and $ZPOUT print as the value of $P followed by "< /" or "> /", respectively.
# For a split $P, USE applies to the input side and output side respectively.
# alternate use of wrap and nowrap for $ZPIN and $ZPOUT for all XCMD USE calls to show both sides of a split device
# are set when appropriate
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_principal gtm_principal "abc"
set RUNXCMD="$gtm_dist/mumps -run %XCMD"
echo 'ZSHOW "D" with no $PRINCIPAL redirection'
$RUNXCMD 'write "$P = ",$P,", $ZPIN = ",$ZPIN,", $ZPOUT = ",$ZPOUT,!'
$RUNXCMD 'use $ZPIN:wrap use $ZPOUT:nowrap zshow "d" zshow "d":A zwrite A'
echo 'ZSHOW "D" with no $PRINCIPAL redirection followed by attempt to open %$P'
$RUNXCMD 'zshow "d" open $PRINCIPAL_"< /"'
echo 'ZSHOW "D" with no $PRINCIPAL redirection followed by attempt to open #$P'
$RUNXCMD 'zshow "d" open $PRINCIPAL_"> /"'
echo 'ZSHOW "D" with $PRINCIPAL input redirected from a file'
$RUNXCMD 'use $ZPIN:nowrap use $ZPOUT:wrap zshow "d" zshow "d":A zwrite A' < /dev/null
# make sure output from mumps is redirected to /dev/null - fixed under GTM-5688
# prior to this fix, the "ZSHOW dummy.  should not see this" would be seen in the output
$RUNXCMD 'use $ZPIN:wrap use $ZPOUT:nowrap write "ZSHOW dummy.  should not see this",!' > /dev/null
$switch_chset UTF-8
$gtm_dist/mumps -r tstchset > tstchset.out
$switch_chset M
unsetenv LC_CTYPE
echo 'ZSHOW "D" with $PRINCIPAL output redirected to a file - zshowprin1.out'
$RUNXCMD 'use $ZPIN:nowrap use $ZPOUT:wrap zshow "d" zshow "d":A zwrite A' > zshowprin1.out
cat zshowprin1.out
echo 'ZSHOW "D" with $PRINCIPAL input redirected by |'
echo "TESTING PIPE1" | $RUNXCMD 'use $ZPIN:wrap use $ZPOUT:nowrap zshow "d" read x write x,! zshow "d":A zwrite A'
echo 'ZSHOW "D" with $PRINCIPAL output redirected by |'
$RUNXCMD 'use $ZPIN:nowrap use $ZPOUT:wrap zshow "d" zshow "d":A zwrite A' | cat
echo 'ZSHOW "D" with $PRINCIPAL input and output redirected by |'
echo "TESTING PIPE2" | $RUNXCMD 'use $ZPIN:wrap use $ZPOUT:nowrap zshow "d" read x write x,! zshow "d":A zwrite A' | cat
# do fifo redirection
echo 'ZSHOW "D" with $PRINCIPAL input redirected from a fifo'
# do write to test.fifo in background
echo "TESTING FIFO1" > test.fifo&
$RUNXCMD 'use $ZPIN:nowrap use $ZPOUT:wrap zshow "d" read x write x,! zshow "d":A zwrite A' < test.fifo
echo 'ZSHOW "D" with $PRINCIPAL output redirected to a fifo'
# do write to test.fifo in background
(cat < test.fifo; touch donefile)&
$RUNXCMD 'use $ZPIN:wrap use $ZPOUT:nowrap zshow "d" write "TESTING FIFO2",! zshow "d":A zwrite A' > test.fifo
set cnt=60
while ((! -e donefile) && (0 != $cnt))
	sleep 1
	@ cnt = $cnt - 1
end
if (0 == "$cnt") then
	echo "TEST-E-DONEFILE failed to create donefile in 60 seconds"
	exit 1
endif
