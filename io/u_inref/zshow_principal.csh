#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#;;;zshow_principal.csh
#;;;Test the unix behavior of ZSHOW "D" for $PRINCIPAL where the input side does not equal the output side
#;;;This work was done under GTM-8134
#;;;
# Create one-region gld and associated .dat file
$switch_chset M
$gtm_tst/com/dbcreate.csh mumps 1
# create simple M routine to change chset
cat >> tstchset.m <<EOF
tstchset
	zshow "d"
	open \$P:(ichset="M":ochset="M")
	zshow "d"
EOF

$echoline
echo "************************* zshowprin.exp ***************************"
$echoline
# create test.fifo for later use
$gtm_exe/mumps -run %XCMD 'open "test.fifo":(fifo:newversion)'
setenv TERM xterm
## Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/inref/zshowprin.exp > zshow_principal.outx) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
echo 'TEST that ichset=M and ochset=M when OPEN $P:(ichset="M":ochset="M") is done with a split $P' >> zshow_principal.outx
cat tstchset.out >> zshow_principal.outx
# cleanup the zshow_principal.out file for the reference file
$gtm_exe/mumps -run zshowprin
# for a split device show correct operation of $PRINCIPAL, $ZPIN, $ZPOUT
# generate error messages for split device trying to open $ZPIN or $ZPOUT
$gtm_exe/mumps -run zpinandzpout 1 </dev/null >zpinandzpout.outx
cat zpinandzpout.outx
$gtm_tst/com/dbcheck.csh
