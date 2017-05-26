#!/usr/local/bin/tcsh -f
echo "Begin of D9C08002194 subtest"
cp $gtm_tst/$tst/inref/test*.m .
$GTM << GTM_EOF
d ^test41
GTM_EOF
#
@ curcount = 0
@ numtests = 42
while ($curcount < $numtests)
	@ curcount = $curcount + 1
	if ($curcount < 10) then
		set numstr = "0$curcount"
	else
		set numstr = "$curcount"
	endif
	echo "-----------> mumps -run test$numstr <------------"
	#$gtm_dist/mumps -run test$numstr
	$gtm_exe/mumps -run test$numstr
	echo "================================================="
end
echo "End of D9C08002194 subtest"
