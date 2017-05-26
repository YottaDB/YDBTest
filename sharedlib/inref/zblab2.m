lab2;
	set begline=2
	set maxline=43
	new lineno
	for lineno=begline:1:maxline  do
	. zbreak zbmain+lineno^zbmain:"do lab3^zblab3 zcontinue"
	;write "After break points set in lab2: Show the break points and stack:"  zshow "BS"
	;
	set ^zbmain=$GET(^zbmain)+1
	set ^caller=$ZPOS
	;write "Test zbreak actions with action do lab3^zblab3",!
	do ^zbmain
	quit
