lab3;
	new lineno
	set begline=2
	set maxline=43
	for lineno=begline:1:maxline  do
	. zbreak zbmain+lineno^zbmain:"do lab4^zblab4 zcontinue"
	;write "After break points set in lab3: Show the break points and stack:"  zshow "BS"
	;
	set ^zbmain=$GET(^zbmain)+1
	set ^caller=$ZPOS
	;write "Test zbreak actions with action do lab4^zblab4",!
	do ^zbmain
	quit
