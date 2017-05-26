zstep	; test $zstep
	write $zstep,!
	set $zstep="do zsteplabelforzstepwithoutparameter"
	zstep over:"w ""$zstep="",$zstep,!"
	zstep
	write x,!
	write "zstep stops here",!
	write "$zstatus = ",$zs,!
	quit

zsteplabelforzstepwithoutparameter ;
	write "zstep called",!
	set x=$zposition
	quit
