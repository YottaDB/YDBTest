unicodeReverse;
	for i=1:1:100 do
	. set str=$$^ulongstr(i*100)
	. set revstr=$reverse(str)
	. if $length(revstr)'=$length(str) write "failed in $length test",!
	. if $zlength(revstr)'=$zlength(str) write "failed in $zlength test",!
	. if $$verify(str,revstr)'=1 write "failed in verification test",!
	write "$reverse() test finished successfully",!
	quit

verify(str,revstr)
	new len,i,tmpstr
	set len=$length(revstr)
	set tmpstr=""
	for i=len:-1:1 do
	. set tmpstr=tmpstr_$extract(revstr,i)
	if tmpstr'=str quit 0
	quit 1
