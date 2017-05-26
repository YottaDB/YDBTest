	; this is an edge case test where we test updates to a GVN that are
	; the result of a trigger installation
ztriggvn
	set ^a=$ztrigger("item","+^a -command=S -xecute=""set x=1 do mrtn^ztriggvn"" -name=a1")
	zwrite ^fired kill ^fired
	do ^echoline
	set ^a=$ztrigger("item","+^a -command=S -xecute=""set x=2 do mrtn^ztriggvn"" -name=a2")
	zwrite ^fired kill ^fired
	do ^echoline
	write "a3 will not fire because ^a is set to 1 meaning the update did not change $ztupdate",!
	set ^a=$ztrigger("item","+^a -command=S -xecute=""set x=3 do mrtn^ztriggvn"" -name=a3 -delim=$c(9)")
	zwrite ^fired kill ^fired
	do ^echoline
	kill ^a
	write "Kill ^a. now all triggers a1 to a4 will fire",!
	set ^a=$ztrigger("item","+^a -command=S -xecute=""set x=4 do mrtn^ztriggvn"" -name=a4 -delim=$c(10)")
	zwrite ^fired kill ^fired
	do ^echoline
	set ^a=$ztrigger("item","+^a -command=S -xecute=""set x=5 do mrtn^ztriggvn"" -name=a5")
	zwrite ^fired kill ^fired
	do ^echoline
	set ^a=6
	zwrite ^fired kill ^fired
	do ^echoline
	set ^a=$ztrigger("select")
	zwrite ^fired kill ^fired
	do ^echoline
	set ^a=$ztrigger("item","-*")
	if $data(^fired) write "FAIL",!
	do ^echoline
	quit

mrtn
	set x=$increment(^fired($ZTNAme))
	quit
