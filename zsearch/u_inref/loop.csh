#! /usr/local/bin/tcsh -f
set outfile = $3
if ($1 == 26 ) then
set string = "a b c d e f g h i j k l m n o p q r s t u v w x y z"
else 
set string = "1 2 3 4 5"
endif
foreach letter (1 2 3 4 5 6 7 8 9 10 11 12 13) 
	set no=0
	 foreach i ($string)
	 #foreach i (a b c d e f g h i j k l m n o p q r s t u v w x y z)
	  echo '	write "Hi Iam routine '$2/$i$letter.m'",!' > $2/$i$letter.m
	  @ no = $no + 1
	  if ($no == $1) then
	   break
	  endif
	end
	$GTM > & ! output << xyz
do ^D000837
halt
xyz
	set comp1=`$tail -n 2 output|$head -n 1`
	set comp2=`echo *.m|wc -w`
	if ("$comp1" == "$comp2") then
	 echo "$letter PASSED"
	else
	 echo "Comparison: $comp1 not equal to $comp2" | tee -a $outfile
	 echo "FAILED before $letter (resolution: $1) in directory $2"| tee -a $outfile
	 # save directory listing in $outfile
	 ls -al >> $outfile
	 if ($1 == 26 ) then
	 echo "Output in $outfile" 
	 endif
	 echo "Output follows">> ! $outfile
	 echo "**********" >> ! $outfile
	 cat output >> ! $outfile
	 echo "*********" >> ! $outfile
	 echo "End of output" >> ! $outfile
	 echo $letter 
	 exit 0
	endif
end
# We should not get here if $1 is 5 because it is the finer grained second pass because of a
# failure in the first pass.  If we do, however, check_dir.csh will use the status returned
# to omit the numeric calculations used to describe the expected failure.

# this section is to check whether we are able to run routines of max. length 255
set curlen=`echo $2 |wc|$tst_awk '{print $3+9}'`
echo "IAM $2/maxlen9.m AND MY CURRENT PATHLENGTH is $curlen"
echo '	write "I GET EXECUTED HERE",!' > maxlen9.m
$gtm_exe/mumps -run maxlen9
exit 1
