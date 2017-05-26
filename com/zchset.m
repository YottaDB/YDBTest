	; VMS/Unix proxy for $ZCHSET
	; 
	; Unix and VMS GT.M versions prior to V52000 don't support $zchset. Use
	; this routine to avoid INVSVN messages when called with prior versions
zchset()
	set chset="M"
	if $zv["VMS" quit chset ; always return M for VMS which does not support Unicode
	set version=$$^verno()
	quit:(version<52000) chset
	XECUTE "set chset=$zchset"
	quit chset
