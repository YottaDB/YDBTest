zstep	;
	s $zt="do zthtosupportlonglabelnames78901"
	zstep over:"w x,!"
	w "zstep stops here",!
	w "$zstatus = ",$zs,!
	q

zthtosupportlonglabelnames78901	;
	w "ztrap called",!
	s x=$zl
	q
