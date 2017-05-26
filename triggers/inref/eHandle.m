eHandle
	write $zlevel,$char(37),$text(+0),$char(37),$ECODE,!
	zshow "s"
	set $ECODE="",$etrap="halt",$ZTRAP=""
	quit
dispatch
	new $ZTRAP,$ETRAP set $ZTRAP=""
	write $zlevel,$char(35),$text(dispatch+0),$char(35),$ECODE,!
	set topecode=$ecode
	set $ECODE=""
	; need a switch style dispatch
	if "M9"=$piece(topecode,",",2) do divbyzero
	if "M39"=$piece(topecode,",",2) goto executed
	write "Don't know ",topecode,!,$zstatus,!
clearETdone
	set $ECODE=""
dispatchdone
	write $zlevel,$char(43),$text(dispatchdone+0),$char(43),$ECODE,!
	goto ^eHandle
divbyzero
	write $zlevel,$char(44),$text(divbyzero+0),$char(44),$ECODE,!
	set dest=$zlevel-1_":dispatchdone^eHandle"
	set $ECODE="",$etrap="halt"
	write dest,!
	zgoto @dest
	write "ERROR: zgoto should have worked",!
	halt
executed
	write $zlevel,$char(45),$text(executed+0),$char(45),$ECODE,!
	goto dispatchdone^eHandle
	write "ERROR: goto should have worked",!
	halt
