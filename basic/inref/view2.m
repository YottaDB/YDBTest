	; test
	;92p; 14-May-1993 12:13  Wyche  

view2(verbose)
	Do begin^header($TEXT(+0))

	Do zlink
	Set r="",ec=0
	Do loop
	If ec  Write "** FAIL",!
	If 'ec  Write "   PASS",!

	Do end^header($TEXT(+0))
	Quit

loop	Set r=$VIEW("rtnnext",r) Quit:r=""  
	Set x=$CHAR($a($EXTRACT(r,$LENGTH(r),$LENGTH(r)))-1)
	Set x=$EXTRACT(r,1,$LENGTH(r)-1)_x_$EXTRACT("ZZZZZZZZ",1,8-$LENGTH(r))
	If verbose Write !,"routine: ",r,?20,"$VIEW(""rtnnext"",""",x,""") = "
	Set y=$VIEW("rtnnext",x)
	If verbose Write y
	If '$LENGTH(y) Set ec=1
	GoTo loop

zlink	If verbose Write !,"zlinking"
	For i=1:1:20 Do
	. Set file="TEMP"_$CHAR(65+i)_".m"
	. Open file:(NEWV)  Use file
	. If verbose Write " ;program stub"
	. Close file
	. Zlink file
	. If verbose Write !?5,"zlinking: ",file
	Quit
