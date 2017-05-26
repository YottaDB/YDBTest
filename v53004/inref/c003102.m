c003102	;
	; Test that pattern match works with non-ASCII literals on the right side (previously used to issue PATLIT error).
	;
	new index,x,str,i,xstr
	for index=128,228,255  do
	.	; -----------------------------------------------------------
	.	; Test case 1 : To test that non-ASCII literals in right side of pattern match operator work fine
	.	; This was provided by SourceForge.
	.	;
	.	set x=$c(index)
	.	write !,"Test 1 with $c("_index_") : "
	.	set str="D"_x_"twiler"
	.	set xstr="str?1""D"_x_""".E" write @xstr
	.	;
	.	; -----------------------------------------------------------
	.	; Test case 2 : Enhance Test case 1 to use DFA (i.e. where pattern includes . with an unbounded upper limit)
	.	;
	.	write !,"Test 2 with $c("_index_") : "
	.	set str="23"
	.	for i=1:1:255 s str=str_x
	.	set str=str_"1"
	.	set xstr="str?1N."""_x_"""1N"    write @xstr
	.	set xstr="str?."""_x_"""1N"      write @xstr
	.	set xstr="str?2N."""_x_""""      write @xstr
	.	set xstr="str?2N."""_x_"""1N"    write @xstr
	.	set xstr="str?2N100."""_x_"""1N" write @xstr
	.	set xstr="str?2N250."""_x_"""1N" write @xstr
	.	set xstr="str?2N255."""_x_"""1N" write @xstr
	.	set xstr="str?2N256."""_x_"""1N" write @xstr
	.	set xstr="str?2N300."""_x_"""1N" write @xstr
	write !!
	quit
