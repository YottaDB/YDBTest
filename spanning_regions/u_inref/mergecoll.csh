#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test for GTM-5573

source $gtm_tst/com/cre_coll_sl_reverse.csh 1
source $gtm_tst/com/cre_coll_sl_straight.csh 2
setenv gtm_collate_1 $PWD/libreverse.so
setenv gtm_collate_2 $PWD/libstraight.so
unsetenv gtm_local_collate

$GDE << GDE_EOF >&! gde.out
change -segment DEFAULT -file=mumps.dat
add -name a -region=areg
add -region areg -dyn=aseg -std -null_subscripts=always
add -segment aseg -file=a
add -name c* -region=creg
add -region creg -dyn=cseg -std -null_subscripts=never
add -segment cseg -file=c
change -region DEFAULT -std -null_subscripts=always
exit
GDE_EOF

if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	$GDE << GDE_EOF1 >&! gde_span.out
	add -name a(1,2) -reg=DEFAULT
	add -name c(1,2) -reg=DEFAULT
GDE_EOF1

endif

$MUPIP create

foreach acoll (0 1)
	foreach bcoll (0 2)
		$DSE << DSE_EOF >>&! dse.out
		 find -reg=AREG
		 change -file -def=$acoll
		 find -reg=DEFAULT
		 change -file -def=$bcoll
		 find -reg=CREG
		 change -file -def=$bcoll
DSE_EOF

		echo "----------------------------------"
		echo "Testing with ^a coll = $acoll : ^b coll = $bcoll",!
		echo "----------------------------------"
		$gtm_exe/mumps -run mergecoll >& mergecoll_${acoll}_${bcoll}.txt
	end
end

echo "Cat output of mergecoll_0_0.txt"
cat mergecoll_0_0.txt
echo "# Expect ZERO diff in the below"
set echo
diff mergecoll_0_0.txt mergecoll_0_2.txt
diff mergecoll_0_0.txt mergecoll_1_0.txt
diff mergecoll_0_0.txt mergecoll_1_2.txt
unset echo

$gtm_exe/mumps -run %XCMD 'set ^col="before gde change"'
echo "# At this point c.dat has collation $bcoll and ^col is already set above."
echo "# gde add -gblname c -col=1 followed by set ^col should fail with  ACTCOLLMISMTCH"
$GDE add -gblname col -col=1
$GTM << gtm_eof
	set ^col="should not work"
	set ^col="should not work"
	write \$get(^col)
gtm_eof

