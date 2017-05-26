	; compiling and linking a trigger should not affect $ZSOURCE
trigzsource
	set x=$increment(^zsrc(sub))
	write "$ZSOURCE=",$ZSOURCE,!
        quit

test
	do ^echoline
	write "trigger compile should not affect $zsource",!
	if '$ztrigger("item","+^src(sub=:) -commands=S -xecute=""do ^trigzsource""")
	write "$ZSOURCE=",$ZSOURCE,!
	for i=1:1:10  set x=$increment(^src(i))
	do ^echoline
	quit

