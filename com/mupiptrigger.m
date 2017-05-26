mupiptrigger
	write "This is an M routine wrapper around mupip",!
	write "you need to call mupiptrigger with args",!
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
file(file,resp,output)
	new i,pstr,pipe,line,device
	set pipe="mupiptrigger"
	set device=$IO

	if '$data(file) use $p write "mupiptrigger need file",! quit
	if $data(output) open output:(newversion:CHSET="M") set device=output
	
	set pstr=$$untext("cmd+1^mupiptrigger")_file_$char(34,41)
	open pipe:@(pstr)::"pipe"
	use pipe

	if '$data(resp) for  quit:$zeof  read line use device write line,! use pipe
	if $data(resp) for  quit:$zeof  read line set resp($increment(i))=line

	close pipe
	if $data(output) close output
	use $p
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
select(gvn,resp,output)
	new i,pstr,pipe,line,cmd
	set pipe="mupiptrigger",err="err",cmd=""

	if $data(gvn) set cmd="="_gvn
	if $data(output) set cmd=cmd_" "_output

	set pstr=$$untext^mupiptrigger("cmd+2^mupiptrigger")_cmd_$char(34,41)
	open pipe:@(pstr)::"pipe"
	use pipe

	if '$data(output) write !  ; need to give the file prompt an answer

	if '$data(resp) for  quit:$zeof  read line use $p write line,! use pipe
	if $data(resp) for  quit:$zeof  read line set resp($increment(i))=line

	close pipe
	use $p
	quit

nocycles(resp)
	new lineno,char
	if '$data(resp) quit
	set resp="" do select^mupiptrigger(,.resp)
	set lineno=0
	for  set lineno=$order(resp(lineno)) quit:lineno=""  do
	.	set char1=$extract(resp(lineno),1,1)
	.	if $select(char1="-":0,char1="+":0,1:1) zkill resp(lineno)
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; strip off the leading tab and semi-colon
untext(label)
	new x
	set x=$text(@label)
	set $extract(x,1,2)=""
	quit x

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmd
	;(command="$gtm_exe/mupip trigger -noprompt -triggerfile=
	;(command="$gtm_exe/mupip trigger -select
	;(stderr=err:command="$gtm_exe/mupip trigger -select
