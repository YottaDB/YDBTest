#!/usr/local/bin/tcsh -f
if ($#argv == 0 ) then
	echo "USAGE:"
	echo "dummy_check_all.csh <name of test> <number of runs> [ <name of subtests>]"
	echo ""
	echo "to use dummy_output.csh to check many reference files"
	echo "the reference files are expected to be in the same directory, and name by the subtest (<subtest>.txt) for subtests and outstream.txt for the test itself"
	echo " The scipt will check <test>_1, <test>_2, ... "
	echo ""
	echo "*.txt files will be compared, rather than *.log files, so use either unite.csh or inref.csh to generate the *.txt files (i.e. ##TEST_PATH, etc. correction)"
	echo ""
	echo "Return values"
	echo "0: success"
	echo "1: at least one difference found"
	echo "2: at least one file was missing"
	exit
endif
	
set i = 1
set stat=0

while ($i <= $2 )
set current = $i
@ i = $i + 1
echo "----------------------------------- RUN " $current " -----------------------------------"
if ("$3" != "") then
	set x = 1
	foreach sub_test ($argv)
	if ($x > 2) then	 # easy way to get $3,$4,$5,...
		set sub_test = `basename $sub_test .txt`
		if (! -e $sub_test.txt) then
			echo "$sub_test.txt not found"
			echo "skipping subtest $sub_test"
			if !($stat) set stat=2
			continue
		endif
		echo $gtm_test/T990/com/dummy_output.csh $1 $current $sub_test.txt
		$gtm_test/T990/com/dummy_output.csh $1 $current $sub_test.txt
		if (! -e $1_$current/$sub_test/$sub_test.txt) then
			echo $1_$i/$sub_test/$sub_test.txt not found
			echo "skipping diff"
			if !($stat) set stat=2
			continue
		endif
		echo diff ${sub_test}.txt_$current $1_$current/$sub_test/$sub_test.txt
		diff ${sub_test}.txt_$current $1_$current/$sub_test/$sub_test.txt > /dev/null
		if !($status) then 
			echo "#$sub_test.txt $current same"
		else 
			echo "! $sub_test.txt $current DIFFERENT"
			set stat=1
		endif
	endif
	@ x = $x + 1
	end
endif

if !(-e outstream.txt) then
	echo "outstream.txt not found"
	echo "skipping outstream"
	if !($stat) set stat=2
	continue
endif
echo $gtm_test/T990/com/dummy_output.csh $1 $current outstream.txt
$gtm_test/T990/com/dummy_output.csh $1 $current outstream.txt

if !(-e $1_$current/outstream.txt) then
	echo "$1_$current/outstream.txt not found"
	echo "skipping diff"
	if !($stat) set stat=2
	continue
endif
echo diff outstream.txt_$current $1_$current/outstream.txt
diff outstream.txt_$current $1_$current/outstream.txt > /dev/null
if !($status) then
	echo "#outstream.txt $current same"
else 
	echo "! outstream.txt $current DIFFERENT"
	set stat=1
endif

end
exit $stat
