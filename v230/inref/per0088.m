per0088	; ; ; per0088 - Implement $ZPOSITION
	;
	Set pnm=$TEXT(+0)
	Set c=0
LABEL	If $ZPOSITION'=("LABEL^"_pnm)  Set c=c+1  Write !,"$ZPOSITION = ",$ZPOSITION," at label"
	If $ZPOSITION'=("LABEL+1^"_pnm)  Set c=c+1  Write !,"$ZPOSITION = ",$ZPOSITION," at label+1"
	Xecute "If $ZPOSITION'=(""LABEL+2^""_pnm) Set c=c+1 Write !,""$ZPOSITION = "",$ZPOSITION,"" in Xecute"""
	If @("$ZPOSITION'=(""LABEL+3^""_pnm)")  Set c=c+1  Write !,"$ZPOSITION = ",$ZPOSITION," in indirection"
	Xecute "If @(""$ZPOSITION'=(""""LABEL+4^""""_pnm)"") Set c=c+1 Write !,""$ZPOSITION = "",$ZPOSITION,"" in Xecute indirection"""
	Write !,$SELECT(c:"BAD result",1:"OK")," from test of simple $ZPOSITION"
	Quit
