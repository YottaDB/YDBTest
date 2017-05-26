#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#####
#I've edited the M routines so that they will not ask for user input.
#I tried to make the changes as minimal as possible so that putting in new MVTS test routines would not be too difficult.
#VEXAMINE.m is modified to FAILO, i.e. any test that requires "babysitting", i.e. operator checking, will fail.
#Those tests can be checked from the output (vsr.log).
#I've disabled all tests which seemed to test operator speed and IQ (required operator input).
# Nergis Dincer 12/05/2000
#####

# Use the M std kill and std side effects
setenv gtm_stdxkill 1
setenv gtm_side_effects 1
setenv gtm_poollimit 0 # Setting gtm_poollimit will cause some transactions to restart. Not desirable in this test.

$gtm_tst/com/dbcreate.csh -block=4096 -rec=1024 -key=255
#Set up the information needed
#some are just filled with dummy values
cp $gtm_tst/$tst/inref/set.ext set.ext
if ($?gtm_chset) then
	if ($gtm_chset == "UTF-8") then
		# Make extract file compatible with UTF-8 load
		mv set.ext set.ext1
		sed 's/GT.M MUPIP EXTRACT/& UTF-8/g' set.ext1 > set.ext
	endif
endif
$MUPIP load set.ext
$MUPIP set -journal="enable,on,nobefore" -reg "*"

#Since we get lots of failures and errors now, let's run the individual tests seperately
#Default view "BADCHAR" needs to be over-ridden as V1AC1.m handles with $C(-1) which will trigger INVDLRCVAL error
$GTM << FIN >>&! mvts.out
view "NOBADCHAR"
D ^VV1
ZCONTINUE
ZCONTINUE
ZCONTINUE
ZCONTINUE
ZCONTINUE
ZCONTINUE
H
FIN

$GTM << FIN >>&! mvts.out
D ^VV2
H
FIN

$GTM << FIN >>&! mvts.out
D ^VV3
H
FIN

$GTM << FIN >>&! mvts.out
D ^VV4
H
FIN

$GTM << FIN >>&! mvts.out
D ^VV4TP
H
FIN

$GTM << FIN >>&! mvts.out
D ^VSR
H
FIN

echo "check vsr.log for a summary of the results"
echo "grep FAIL:"					#BYPASSOK
echo "#########################################################################################"
echo "FAILs:"
$grep FAIL vsr.log | $grep -v "OPERATOR"
echo "*SKIP*s:"
$grep "*SKIP*" vsr.log
echo "FAILs minus operator stuff"
$grep FAIL mvts.out | $grep -v "Press" | $grep -v "Before"  | $grep -v "OPERATOR" | $grep -v "<CR>"
# do not need to look at lines like:
#Before answering the PASS-FAIL question,
#Press P/p for PASS or F/f for FAIL and <CR> :
echo "#########################################################################################"

#echo "mvst.out:"
#cat mvts.out
$gtm_tst/com/dbcheck.csh
