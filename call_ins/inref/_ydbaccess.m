	; This implements a small demonstration of an API created in YottaDB that
	; can be called from a C main() program.
	;
	; No claim of copyright is made with respect to this code. YottaDB
	; supplies this code to the public domain for people to copy and paste, so
	; that's why this code is specifically excluded from copyright. This code
	; is referenced from the YDBDoc project.
	;
	; This program is only a demonstration.  Please ensure that you have a
	; correctly configured YottaDB installation.
	;
%ydbaccess	; entry points to access YottaDB
	quit
	;
get(var,value)
	set value=@var
	quit
	;
kill(var)
	kill @var
	quit
	;
lock(var)
	lock @var
	quit
	;
order(var,value)
	set value=$order(@var)
	quit
	;
query(var,value)
	set value=$query(@var)
	quit
	;
set(var,value)
	set @var=value
	quit
	;
xecute(var,err)
	new $etrap,$estack set $etrap="quit:$estack  set $ecode="""",err=$zstatus quit:$quit +err quit"
	xecute var
	quit
	;
