D9C05002098	; ; ; test the job command
	;
	new (act,wait)
	if '$data(act) new act set act="write !,$zstatus"
	set $ecode=""
	new $etrap
	set $etrap="goto err^"_$text(+0)
	set seen=0
	if $zversion["VMS" do
	. set cat="type",jparm=":(startup=""startup.com"")",ls="dir",rm="delete *.mj*;*"  set:'$data(wait) wait=15
	else  set cat="cat",ls="ls",rm="rm *.mj*",jparm=""  set:'$data(wait) wait=30
	set cat=cat_" *.mj*",ls=ls_" *.mj* >& /dev/null"
	write !
	zsystem rm ; this normally produces output of rm: No match. but is nice for repeated running
	job @("noparm^D9C05002098"_jparm)		; OK
	do spit
	job @("noparm^D9C05002098(1,1)"_jparm)		; FMLLSTMISSING but not currently caught
	do spit
	job @("parm^D9C05002098"_jparm)			; OK - a do without parentheses
	do spit
	job @("parm^D9C05002098(1,""foo"",3)"_jparm)	; ACTLSTTOOLONG
	do spit
	job @("parm^D9C05002098(1,""foo"")"_jparm)	; OK - matching lists one integer one string
	do spit
	job @("parm^D9C05002098(1)"_jparm)		; OK - short list
	do spit
	job @("parm^D9C05002098(,""foo"")"_jparm)	; OK - missing argument
	do spit
	job @("parm^D9C05002098()"_jparm)		; OK - empty list
	do spit
exit	write !,$select($get(cnt):"FAIL",1:"COMPLETE")," from ",$text(+0)
	quit
	;
err	for i=$stack:-1:1 set loc=$stack(i,"PLACE") quit:loc[("^"_$text(+0))
	set next=$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set stat="\"_$piece($piece($zstatus,"-",3),",") 
	if $increment(cnt) xecute act
	set $ecode=""
	goto @next
	;
spit	for i=1:1:wait do  quit:seen&'alive  hang 1
	. set alive=$zgetjpi($zjob,"ISPROCALIVE")
	. if alive set seen=1
	. else  if 'seen zsystem ls if $select($zversion["VMS":1=$zsystem,1:0=$zsystem) set (alive,seen)=1
	if 'seen write !,"timed out with process ",$select(alive:"still",1:"not")," alive"
	zsystem cat,rm
	set seen=0
	quit
	;
noparm	write !,"this is noparm"
	quit
	;
parm(x,y)
	write !,"1st parm was passed: ",$get(x,"<*NOT-A-THING*>")
	write !,"2nd parm was passed: ",$get(y,"<*NOT-A-THING*>")
	quit
