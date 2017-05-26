lab	;
	s $zt="do zth"
	zb sub:"w x,!"
sub	w "break points reached",!
	w "$zstatus = ",$zs,!
 	q

zth	w "ztrap called",!
	s x=$zl
	q
