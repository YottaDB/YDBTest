per0360	; ; ; per0360 - ZBreak on the last line of a zlinked program gives wrong position
	;
	Set pos="label+1^"_$Text(+0)_$Select($ZVersion["VMS":"A",1:"a")
	Set act="If $ZPOSITION'=pos  Set c=c+1  Write !,""expected : "",pos,!,""$ZPOSITION was: "",$ZPOSITION"
	ZBREAK label+1^per0360a:act
	Do @"^per0360a"
	Write !,$SELECT(c:"BAD result",1:"OK")," from test ZB on last line of a ZLinked routine"
	Quit
