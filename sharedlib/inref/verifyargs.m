verifyargs(max);
	new cnt
	for cnt=1:1:max do
	. do ^examine($get(@("arg"_cnt)),cnt,"arg"_cnt)
	write !,"Verify Done ",!
	quit
