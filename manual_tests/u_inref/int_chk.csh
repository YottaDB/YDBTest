# this script is for manual test intrpt_recov to check journal file status after exiting from the debugger

set prev = mumps3.mjl
while ($prev != "")
	set cur = $prev
	set prev = `$gtm_test/T990/com/jnl_prevlink.csh -f $prev`
	echo "Previous generation of $cur is $prev"
	mupip journal -show=head -for -noverify $cur |& grep "Turn Around"
	mupip journal -show=head -for -noverify $cur |& grep "Recover interrupted"
end
