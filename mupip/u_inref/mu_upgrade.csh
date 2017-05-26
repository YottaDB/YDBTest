#! /usr/local/bin/tcsh -f
#
$GDE << aaa
exit
aaa
if("ENCRYPT" == $test_encryption) then
	$GDE change -segment DEFAULT -encr >> gde_encr.out
endif
cp $gtm_tst/$tst/inref/v3.dat mumps.dat
cp $gtm_tst/$tst/inref/yes.txt .
$MUPIP upgrade mumps.dat < yes.txt
$GTM << aaa
d in0^dbfill("set")
aaa
$GTM << aaa
d in0^dbfill("ver")
aaa

