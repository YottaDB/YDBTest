#!/usr/local/bin/tcsh -f
if ("$argv" == "") then
	echo "" 
	echo "check.csh <test_name> <unite_or_not>"
	echo ""
	echo "simple checking for reference files"
	echo "if second argument is "unite" it will call unite first"
	echo "it will use $gtm_test/T990/com/dummy_otput.csh to create a reference file and"
	echo "compares it with outstream.txt in the test directory"
	echo "requires submitted_tests"
	exit
	endif
if ("$2" == "unite" ) ~/new_unite/unite.csh $1 |& grep -v grep
echo -n
echo Check $1
foreach i ({$1}_*)
	set no = `echo $i | awk -F_ '{print $NF}'`
	$gtm_test/T990/com/dummy_output.csh $1 $no outstream.txt
	diff $i/outstream.txt outstream.txt_$no
	if !($status) echo $1 $no is ok.
end
