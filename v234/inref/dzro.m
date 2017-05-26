dzro	; ; ; Set, then reset $ZCOMPILE and $ZROUTINES, then check them.
	;
	New tmp

	Set tmp=$ZCOMPILE
	Set $ZCOMPILE="/ignore/nolist/object/length=66/space=1"
	Set x=$ZCOMPILE
	Set $ZCOMPILE="/object"
	Write !,$SELECT(x="/ignore/nolist/object/length=66/space=1":"OK",1:"BAD")," from DZRO"
	Set $ZCOMPILE=tmp

	If $ZVERSION["VMS"  Set zroutinesvariable89012345678901="[]/src=([],in$dir:[inref],gtm$vrtpct),gtm$vrtpct"
	Else                Set zroutinesvariable89012345678901=".(. $gtm_tst/$tst/inref $gtm_exe) $gtm_exe"
	Set tmp=$ZROUTINES
	Set $ZROUTINES=zroutinesvariable89012345678901
	Set x=$ZROUTINES                                  
	Set $ZROUTINES=""
	Write !,$SELECT(x=zroutinesvariable89012345678901:"OK",1:"BAD")," from DZRO"
	Set $ZROUTINES=tmp

	Quit
