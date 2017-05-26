uzblab1;
	new lineno
	set begline=2
	set maxline=43
	for lineno=begline:1:maxline  do
	. zbreak uzbmain+lineno^uzbmain:"do uzblab2^uzblab2 zcontinue"
	;write "After break points set in uzblab1: Show the break points and stack:"  zshow "BS"
	;
	set ^uzbmain=$GET(^uzbmain)+1
	set ^caller=$ZPOS
	;write "Test zbreak actions with action do uzblab2^uzblab2",!
	do ^uzbmain
	quit
