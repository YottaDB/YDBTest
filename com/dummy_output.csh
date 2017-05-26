#!/usr/local/bin/tcsh -f
if ( $#argv == 0 ) then
  echo USAGE:
  echo dummy_output.csh test_name the_number_in_submitted_tests_file \"names_of_the_reference_files\"
  echo "To generate the output file corresponding to a set of options, to use in generating the reference file"
  echo "Does not do the ##TEST_PATH##,etc. substitution, simply extracts the output depending on ##SUSPEND/ALLOW_OUTPUT's" 
  echo "the output will be in <file>_<test_no> file in the present directory , move to corresponding directory if you want to use it in unite.csh"
  echo "(the reference files need not be in the present directory, the output files will be in the present directory)"
  echo "you do not have to run all the tests to generate a proper submitted_tests, call newtest with the -- option, and write into submitted_tests, be careful about the numbering"
  echo "Does not handle PRO/DBG image flags"
  exit
endif

source $gtm_test/T990/com/set_specific.csh

if ("$2" == "" ) then
	echo "specify which number in the submitted_tests (i.e. options)"
	exit
endif
	
if (! -e submitted_tests) then
	echo "submitted_tests not found, cannot get the options for the test(s)"
	exit
endif

setenv files "$3"
if ("$3" == "" ) then
	echo "Using outref.txt"
	setenv files "outref.txt"
endif
	
foreach i ($files)
	set file = "`basename $i`"
	if (! -e $i ) then
		echo "cannot find input file ($i)"
		continue
	endif
	$tst_awk  -f $gtm_test/T990/com/dummy_output.awk -f $gtm_test/T990/com/process.awk -v the_test=$1 -v the_no=$2 submitted_tests $i > ${file}_$2
end

