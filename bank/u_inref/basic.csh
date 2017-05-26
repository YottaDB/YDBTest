#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtmgbldir acct.gld
setenv test_specific_gde $gtm_tst/$tst/inref/mregtst.gde
# exclude ACNM from list of regions generated in .sprgde files as this is relied upon as untouched by the test
setenv gtm_test_sprgde_exclude_reglist "ACNM"
source $gtm_tst/com/dbcreate.csh acct 3

$GTM << aaa
w "d ^mrtstbld",!  d ^mrtstbld
quit
aaa

$MUPIP freeze -on ACNM >& freeze_on_ACNM.out # freeze just the ACNM region which is not updated by the routines below

$GTM << aaa
s tp="$gtm_test_tp"
if tp="TP" w "d ^mrtptst",!  d ^mrtptst
if tp="NON_TP" w "d ^mrtst",!  d ^mrtst
write "d ^mrverify",!  d ^mrverify
quit
aaa

$MUPIP freeze -off ACNM	>& freeze_off_ACNM.out# unfreeze the ACNM region just before integ

source $gtm_tst/com/dbcheck.csh
