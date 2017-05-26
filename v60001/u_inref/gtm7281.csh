#!/usr/local/bin/tcsh -f

echo "Compiling a file without error"
$gtm_dist/mumps $gtm_tst/$tst/inref/gtm7281_correct.m >&! error_correct_file.txt
echo "Return value:" $?

echo "Compiling both a file with error and without error"
$gtm_dist/mumps $gtm_tst/$tst/inref/gtm7281_incorrect.m $gtm_tst/$tst/inref/gtm7281_correct.m >&! error_both_files.txt 
echo "Return value:" $?
$gtm_tst/com/check_error_exist.csh error_both_files.txt "%GTM-E-INVCMD" >&! /dev/null

echo "Making sure xargs continues calling compiler on compile error"
echo "$gtm_tst/$tst/inref/gtm7281_incorrect.m $gtm_tst/$tst/inref/gtm7281_correct.m" | xargs $gtm_dist/mumps >& error_xargs.txt
$gtm_tst/com/check_error_exist.csh error_xargs.txt "%GTM-E-INVCMD" >&! /dev/null
# xargs should not have quitted 
$tail -n 1 error_xargs.txt | $grep "xargs"
