lab4;
	set cntmax=$G(cntmax)+1
	new lineno,totclr
	set ^lineno=$get(^lineno)+1
	set totclr=^lineno
	set begline=2
	set maxline=43
	for lineno=begline:1:maxline  do
	. zbreak zbmain+lineno^zbmain:"write ""$level="",$zlevel,"" $text="",$text(+lineno),!  zp @$zpos zc "
	;write "After break points set in lab4: Show the break points and stack:"  zshow "BS"
	;
	set ^zbmain=$GET(^zbmain)+1
	set ^caller=$ZPOS
	write "Test zbreak actions with action as zpos",!
	do ^zbmain
	quit
