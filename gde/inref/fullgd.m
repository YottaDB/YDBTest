fullgd	;test of gd
	;
	set mnamelen=31	; maximum length of a valid M name
	set zzzstr="" for i=1:1:mnamelen  set zzzstr=zzzstr_"z"
	set cnt=0,an="",x="^%"
	for  set x=$order(@x) quit:x=""  kill @x
	for i=48:1:57,65:1:90,97:1:122 set an=an_$char(i)
	set back="%"_an,i=0
	set frombeg=2,fromend=frombeg+mnamelen-1	; begin and end column #s of the "From" column in SHOW MAP output
	set uptobeg=fromend+2,uptoend=uptobeg+mnamelen-1 ; begin and end column #s of the "Up to" column in SHOW MAP output
	set regnmbeg=uptoend+3				; begin column # of the "Region / ..." column in the SHOW MAP output
	set regnmbeg=regnmbeg+$length("REG = ")		; skip past the string "REG = " to get the actual region name
	set regnmend=regnmbeg+mnamelen-1
	set finalstr="...",len=$length(finalstr),finalstr=finalstr_$extract(zzzstr,len+1,mnamelen)
	set sd="GDELOG.LOG" open sd:(read:rewind) use sd:exc="zgoto "_$zlevel_":eof"
	for  read rec quit:(rec["*** MAP ***")
	for  read rec quit:$extract(rec,1,3)="!% "
	for  do  if name(i-1)=finalstr kill name(i-1) quit
	.	set name(i)=$$stript($extract(rec,frombeg,fromend))
	.	set name(i+1)=$$back1($$stript($extract(rec,uptobeg,uptoend)))
	.	set (region(i),region(i+1))=$$stript($extract(rec,regnmbeg,regnmend))
	.	set i=(name(i)'=name(i+1))+i+1
	.	read rec	; skip "SEG = ..." line
	.	read rec	; skip "FILE = ..." line
	.	read rec 	; read "REG = ..." line for processing in next iteration
	;
eof	close sd set i=""
	for  set i=$order(name(i)) quit:i=""  do sat
	set x="^%"
	for i=1:1 set x=$order(@x) quit:x=""  do
	.	set i=$extract(x,2,9999),fnd(i)="" 
	.	if '$data(set(i)) set cnt=cnt+1 write !,"Name level $ORDER() failed - extra: ^",i
	set x="%"
	for  set x=$order(set(x)) quit:x=""  if '$data(fnd(x)) set cnt=cnt+1 write !,"Name level $ORDER() failed - missed: ^",x
	write !,$select(cnt:"BAD",1:"OK")," from fullgd"
	quit
	;
sat	;
	set x="^"_name(i),@x=name(i),set(name(i))=""
	if $data(@x)[0 set cnt=cnt+1 write !,"Undefined: ",x quit
	if @x'=name(i) set cnt=cnt+1 write !,x,?10,"- expected: ",name(i),!,?10,"contained: ",@x
	if $view("region",x)'=region(i) do
	.	set cnt=cnt+1 write !,x,?10,"should be in region: ",region(i),!,?16,"was in region: ",$view("region",x)
	quit
	;
stript(str); strip trailing white space from input string "str" and return stripped string
	for k=$l(str):-1:0 quit:$extract(str,k)'=" "
	quit $extract(str,1,k)
	;
back1(name); return the valid M name that immediately precedes the input "name"
	set len=$length(name)
	if $extract(name,len)="0" quit $extract(name,1,len-1)
	set name=$extract(name,1,len-1)_$translate($extract(name,len),an,back)
	if name="9" set name="%"
	quit name_$extract(zzzstr,len+1,mnamelen)
	;
