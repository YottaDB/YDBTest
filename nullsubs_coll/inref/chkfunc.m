chkfunc;
	zwrite ^aglobalvar
	write "executing $ORDER function",!
	do callfunc("$ORDER")
	write "executing $NEXT function",!
	do callfunc("$NEXT")
	write "executing $QUERY function",!
	do callfunc("$QUERY")
	write "executing $ZPREVIOUS function",!
	do callfunc("$ZPREVIOUS")
	quit
callfunc(function);
	write function,!
	set expr=function_"(^aglobalvar(""""))"
	write @expr,!
	zwrite ^aglobalvar
	set null="",minusone=-1
	if function="$NEXT" set s2=minusone
	else  set s2=null
;
	if function="$ORDER" do
	. write "executing $ORDER in FORWARD direction",!
	. set s1=null FOR  set s1=$ORDER(^aglobalvar(s1),1) quit:s1=s2  write s1,!
	. write "executing $ORDER in REVERSE direction",!
	. set s1=null FOR  set s1=$ORDER(^aglobalvar(s1),-1) quit:s1=s2  write s1,!
;
	if function="$QUERY" do  quit
	. set s1="^aglobalvar" for  set s1=$QUERY(@s1) quit:s1=""  write s1,!
;
	set expr1="set s1=null FOR  set s1="_function_"(^aglobalvar(s1)) quit:s1=s2  write s1,!"
;
	write expr1,!
	xecute expr1
	quit
