zbdrive;   
	set section="###################################################################"
dozbbasic;
	write section," unizbbasic ",section,!
	set $ZTRAP="set $ZTRAP="""" goto ERROR^unizbdrive"
	do ^unizbbasic
	zbreak -*
dounicode;
	write section," dounicode ",section,!
	set $ZTRAP="set $ZTRAP="""" goto ERROR^unizbdrive"
	for lineno=3:1:4  do
	. zbreak testunicode+lineno^unizbbasic:"do dounicode^unizbbasic(""multi_ｂｙｔｅ_後漢書 string"")"
	write "Show the breakpoints for dounicode",! zshow "B"
	do testunicode^unizbbasic
	zbreak -*
	;
dollartext	; Test unicode data in $text
	write section," dollartext ",section,!
	set $ZTRAP="set $ZTRAP="""" goto ERROR^unizbdrive"
	for lineno=1:1:5 do
	. zbreak dodollartext+lineno^unizbbasic:"write ""$text= "",$text(testdollartext+"_lineno_"^unizbbasic),!" 
	write "Show the breakpoints for dollartext",! zshow "B"
	do dodollartext^unizbbasic
	zbreak -*
	quit
	;
ERROR	ZSHOW "*"
	quit
	;
