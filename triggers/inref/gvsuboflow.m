gvsuboflow
	set $ztrap="goto ^incrtrap"
	do ^echoline
	set x=$get(^a)			; open AREG first with small keysize of 10
	set X=$ztrigger("item","-*")	; run a ztrigger command that will cause DEFAULT to be opened
	;				; DEFAULT has a bigger keysize of 64
	; do an update to DEFAULT using a big keysize
	; this way we test that gv_currkey->top did not get restored back to AREG's small keysize
	; once the ztrigger was done and gv_currkey->base got restored.
	set subs=$justify(1,50)
	write "Updating ^X, this should NOT give a GVSUBOFLOW error",!
	set ^X(subs)=1  ; this should NOT give a GVSUBOFLOW error
	write "Updating ^a, this should give a GVSUBOFLOW error",!
	set ^a(subs)=1  ; this should give a GVSUBOFLOW error
	do ^echoline
	quit
