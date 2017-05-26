#! /usr/local/bin/tcsh -f
echo "Testing with files under $1"
set outfile = $2
$gtm_tst/$tst/u_inref/loop.csh 26 $1 $outfile > & ! tmp_file
set stts = $status
cat tmp_file
set ltt = `$tail -n 1 tmp_file`
if ($stts == 0) then 
	echo "Will try to find a finer result than ("`expr $ltt - 1`"*26,$ltt*26) files">> $outfile 
	\rm $1/$ltt*
	$gtm_tst/$tst/u_inref/loop.csh 5 $1 $outfile > & ! tmp
	set stts2 = $status
	if ($stts2 == 0) then
		set fine = `$tail -n 1 tmp`
		@ res = 26 * ($ltt - 1 ) + 5 * ($fine )
		@ resmin = 26 * ($ltt - 1 ) + 5 * ($fine - 1 )
		echo "*****Failed between $resmin and $res files *****" >> $outfile
		echo ""|tee -a $outfile
	else
		echo "*****Expected failure did not occur" >> $outfile
		echo ""|tee -a $outfile
	endif
else
	echo "PASSED THE TEST FOR THE DIRECTORY $1" 
	echo -n
endif
