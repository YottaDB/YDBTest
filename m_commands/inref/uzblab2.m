uzblab2;
	set begline=2
	set maxline=43
	new lineno
	for lineno=begline:1:maxline  do
	. zbreak uzbmain+lineno^uzbmain:"do uzblab3^uzblab3 zcontinue"
	;write "After break points set in uzblab2: Show the break points and stack:"  zshow "BS"
	;
	set ^uzbmain=$GET(^uzbmain)+1
	set ^caller=$ZPOS
	;write "Test zbreak actions with action do uzblab3^uzblab3",!
	do ^uzbmain
	quit
