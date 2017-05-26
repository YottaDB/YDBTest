lab1;
	;open "zbmain.o" close "zbmain.o":delete
	;zlink "zbmain"
	new lineno
	set begline=2
	set maxline=43
	for lineno=begline:1:maxline  do
	. zbreak zbmain+lineno^zbmain:"do lab2^zblab2 zcontinue"
	;write "After break points set in lab1: Show the break points and stack:"  zshow "BS"
	;
	set ^zbmain=$GET(^zbmain)+1
	set ^caller=$ZPOS
	;write "Test zbreak actions with action do lab2^zblab2",!
	do ^zbmain
	quit
