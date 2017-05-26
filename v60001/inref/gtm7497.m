gtm7497	;
	new
	new $etrap
	set $ecode="",$zstatus="",$etrap="goto etr"
	new $estack
	set expect=""
	set linestr="-------------------------------------------------------------------------"
	do test1
	do test2
	do test3
	quit
	;
etr	;
	if $estack zgoto -1:etr
	set loc=$stack($zlevel-1,"PLACE")
	set next=$zlevel_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus,stat="\"_$piece($piece(status,"-",3),",")
	if status'[$get(expect)!(""=$get(expect)) write !,$stack($stack,"MCODE"),!,$zstatus
	set $ecode="",$etrap="goto etr"
	zgoto @next
	halt
	;
I()	;
	write z				; hit an UNDEF error
	quit 0
	;
II()	;
	if j<N zgoto 3			; go back to test3
	quit 0
	;
III()	;
	if $trestart<1 trestart		; go back to test4
	quit 0
	;
trigdo	;
	set lcl=@"^Y($$III())"
	quit
	;
test1	;
	; An error (UNDEF in this case) within an indirect frame should be safe, no SIG-11's...
	;
	new (linestr,zl)
	set expect="UNDEF"
	write !,linestr,!,"Test 1 ",!
	set X(0)=1,Y=$get(@"X($$I)")
	zwrite X,Y
	quit
	;
test2	;
	; Same as test1, but without the indirection. Behavior should be the same.
	;
	new (linestr,zl)
	set expect="UNDEF"
	write !,linestr,!,"Test 2 ",!
	set X(0)=1,Y=$get(X($$I))
	zwrite X,Y
	quit
	;
test3	;
	; Repeated ZGOTO's within an indirect frame should not result in inappropriate INDNESTMAX errors.
	;
	new (linestr,zl)
	set expect=""
	write !,linestr,!,"Test 3 ",!
	set N=33,X(0)=1
	for j=1:1:N set Y=$get(@"x($$II)")
	zwrite X,Y
	quit
	;
test4	;
	; Restarts within indirection inside a trigger should also not result in inappropriate INDNESTMAX errors.
	; Executed only from trigger supporting platforms.
	; invoked by gtm7497_trig.csh
	;
	new (linestr,zl)
	new $etrap
	set $ecode="",$zstatus="",$etrap="goto etr"
	new $estack
	set expect=""
	set linestr="-------------------------------------------------------------------------"
	write !,linestr,!,"Test 4 ",!
	kill ^X,^Y
	set ^Y(0)=1
	set xstr="set %=$ztrigger(""item"",""+^X -command=Set -xecute=""""do trigdo^gtm7497"""""")"
	xecute xstr
	for j=1:1:50 set ^X=j
	zwrite ^X,^Y
	quit
	
