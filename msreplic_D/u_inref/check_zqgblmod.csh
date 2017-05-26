#!/usr/local/bin/tcsh -f
# This script could take a lost transaction file, and expected values for the
# $ZQGBLMOD output, and verify the expected value against the actual. But, the
# nature of our updates are very simplistic, so instead, let's have a simpler
# script that does:
#
#  do ^examine($ZQGBLMOD(^GBLA(1)),vcorr(1),"check $ZQGBLMOD(^GBLA(1)) == "_vcorr(1))
#
#  for all the subscripted globals involved. Let's initialize the vcorr arrays
#  (for the different cases) from the arguments passed in at the command line.
#Usage:
#$gtm_tst/$tst/u_inref/check_zqgblmod.csh 0:1-30 1:31-35
#
#which means $ZQGBLMOD(^GBLA(x)) 1<x<30 is expected to be 0, and
#which means $ZQGBLMOD(^GBLA(x)) 31<x<35 is expected to be 1
#
# note this script does not check the validity of the range (for example, overlaps)
#
echo "======================================================="
echo 'Checking $ZQGBLMOD values for the range:'$argv
cat << \EOF >! checkzq.m
checkzq	;
	set seti=$ZTRNLNM("setienv")
	set vali=$PIECE(seti,":",1)
	set rangei=$PIECE(seti,":",2)
	set ll=$PIECE(rangei,"-",1)
	set ul=$PIECE(rangei,"-",2)
	write "will now check the $ZQGBLMOD value for ^GBLA(x) for the range ",ll," < x < ",ul," and the expected value is ",vali,!
	for xx=ll:1:ul do
	. set vcorr(xx)=vali
	. write "examining ^examine($ZQGBLMOD(^GBLA(",xx,"),vcorr(",xx,"))) -> ^examine(",$ZQGBLMOD(^GBLA(xx)),",",vcorr(xx),")",!
	. do ^examine($ZQGBLMOD(^GBLA(xx)),vcorr(xx),"check $ZQGBLMOD(^GBLA("_xx_")) == "_vcorr(xx))
	halt
\EOF
$convert_to_gtm_chset checkzq.m
foreach seti ($argv)
	echo check $seti
	setenv setienv $seti
	$gtm_exe/mumps -run checkzq >&! checkzq${seti}.tmp
	cat checkzq${seti}.tmp
end
echo "======================================================="
