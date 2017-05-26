#!/usr/local/bin/tcsh -f
# Note: This is a trival test case now. For a more stressed test with several switch
#       MUPIP rollback/recover gets confused with different autoswicth in different generations.
#	Once S/W is fixed we can add those stressed tests from /gtc/staff/gtm_test/test_case_layek/autoswitch
#		- Layek 5/17/2002
$gtm_tst/com/dbcreate.csh mumps 1 255 3500 4096 1000 4096 1000
echo "$MUPIP set -journal=enable,on,before,alloc=2048,extension=100,auto=16448 -reg DEFAULT"
$MUPIP set -journal=enable,on,before,alloc=2048,extension=100,auto=16448 -reg DEFAULT
$GTM << aaa
W "Start SET...",!
FOR i=1:1:40 S ^x(i)=\$h
h 1
h
aaa
sleep 2
source $gtm_tst/com/get_abs_time.csh
$GTM << aaa
W "Start SET...",!
FOR i=1:1:40 S ^y(i)=\$h
h 1
h
aaa
###
echo "$MUPIP set -journal=enable,on,before,alloc=2048,extension=10,auto=16388 -reg DEFAULT"
$MUPIP set -journal=enable,on,before,alloc=2048,extension=10,auto=16388 -reg DEFAULT
$GTM << aaa
W "Start SET...",!
FOR i=1:1:40 S ^dummy(i)=\$j(i,3200)
h
aaa
#
$gtm_tst/com/dbcheck.csh -replon -extr
###############################################################
$gtm_tst/$tst/u_inref/jnlverify.csh >& jnlverify.out
if ($?test_replic == 1) then
	$gtm_tst/$tst/u_inref/jnlrollback.csh 10 >>&! rollback.out
	$grep "JNLSUCC" rollback.out
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/jnlverify.csh >>&! jnlverify.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/jnlrollback.csh 10 >>&! sec_rollback.out; $grep 'JNLSUCC' sec_rollback.out"
	$tst_tcsh $gtm_tst/com/RF_EXTR.csh 
else
	echo "$MUPIP journal -recover -back * -since=<gtm_test_since_time>"
	$MUPIP journal -recover -back "*" -since=\"$gtm_test_since_time\" >& back_rec.out
	if ($status) then
		echo "TEST-E-recover failed!"
		exit
	endif
	$grep "JNLSUCC" back_rec.out
endif
