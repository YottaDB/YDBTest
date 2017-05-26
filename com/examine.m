examine(computed,correct,text)
	If computed=correct  Quit
	Set errcnt=$get(errcnt)+1
	if 0=$DATA(text) set text="__NO_TEXT__"	; might be useful if caller is running with sstep on
	Write "** FAIL  ",text,!
	Write "   COMPUTED = """,computed,"""",!
	Write "   CORRECT  = """,correct,"""",!
	Quit
	;
multiequal(compare1,compare2,compare3,compare4,compare5,compare6,compare7,compare8,compare9,text) ; increase the list of arguments when necessary
	for cnt="compare9","compare8","compare7","compare6","compare5","compare4","compare3" if (0=$DATA(text))&(0'=$DATA(@cnt)) set text=@cnt kill @cnt
	; start comparisons
	for examinei=1:1:8 do
	. set arg="compare"_examinei,examinej=examinei+1
	. set nextarg="compare"_examinej
	. if 0'=$DATA(@nextarg) do
	. . if @arg'=@nextarg do
	. . . write "** FAIL  ",text,!
	. . . write @arg_" NOT EQUAL TO "_@nextarg,!
	. . . set examinei=8
	Quit
	;
notequal(computed,correct,text)
	If computed'=correct  Quit
	Set errcnt=$get(errcnt)+1
	if 0=$DATA(text) set text="__NO_TEXT__"	; might be useful if caller is running with sstep on
	Write "** FAIL - EXPECTED TO BE NOT EQUAL - ",text,!
	Write "   COMPUTED = """,computed,"""",!
	Write "   CORRECT  = """,correct,"""",!
	Quit
	;
