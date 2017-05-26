refzgoto
	do ^twork
	set homeframe=1+($ztlevel*2)
	zshow "s":lstack ; zwr lstack zwr lstack("S",homeframe)
	set saferef="saferef"
	set homeroutine=$piece(lstack("S",homeframe),"^",2)
	write:$ztlevel=4 "ZGOTOing back out of trigger levels from $ZTLEVEL=",$ZTLEVEL," and $ZLEVEL=",$ZLEVEL,!
	zgoto:$ztlevel=4 $zlevel-($ztlevel*2):@saferef^@homeroutine ; Two for each trigger level
	set ^b($ztlevel)=$GET(^b($ztlevel))+1
	write "Unexpected return to trigger norefzgoto at $zlevel=",$zlevel," and $ztlevel=",$ztlevel,!
	quit

	; zgoto while in a trigger
gotoloop
	write "$ZLevel",$zlevel,?16,"$ZTLEvel",$ZTLEvel,!
	zshow "s"
	merge ^c("b")=^b
	zgoto $zlevel:gotoloop+5^norefzgoto
	write "$ZLevel",$zlevel,?16,"$ZTLEvel",$ZTLEvel,!
	quit
