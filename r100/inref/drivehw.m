	zwrite $zversion
	do
	. new $etrap
	. set $etrap="set $ecode="""" write ""This is an original GT.M release"",! quit"
	. xecute "zwrite $ZYRELEASE"
	do ^helloworld
	quit
