dollartx;
zbreak1;
	write "zprint zbreak1",!  zprint zbreak1
	set indlineno="lineno"
	set zbentlab="zbreak2"
	set zbentrtn="dollartx"
	set lineno=19	set zbcnt(lineno)=0
	set zbaction="set zbcnt("_lineno_")=zbcnt("_lineno_")+1  write ""zbreak action at="",$zpos,!"
	set indzbact="zbaction"
	zbreak @zbentlab^@zbentrtn:@indzbact
	write "@zbentlab^@zbentrtn",!  zprint @zbentlab^@zbentrtn
	set lineno=20	set zbcnt(lineno)=0
	set zbaction="set zbcnt("_lineno_")=zbcnt("_lineno_")+1  write ""zbreak action at="",$zpos,!"
	zbreak @zbentlab+@indlineno^@zbentrtn:@indzbact
	write "@zbentlab+@indlineno^@zbentrtn",!  zprint @zbentlab+@indlineno^@zbentrtn
	zshow "B"
zbreak2;
	write "zprint zbreak2",!  zprint zbreak2
	set maxlen=31
	set maxlab=500
	set maxrtn=5
	for lineno=31:1:75 do
	.  set zbcnt(lineno)=0
	.  set zbentlab="dollartx+"_lineno
	.  set zbentrtn=$text(+0)
	.  set zbaction="set zbcnt("_lineno_")=zbcnt("_lineno_")+1  zc"
	.  set indzbact="zbaction"
	.  zbreak +lineno^@zbentrtn:@indzbact
	.  ;zbreak @zbentlab^@zbentrtn:@indzbact
	zbreak -create+17^dollartx	; Clear break points for line affected by $random()
	zbreak -create+16^dollartx	; Clear break points for line affected by $random()
	zbreak -create+15^dollartx	; Clear break points for line affected by $random()
	zshow "B"
create;
	write "zprint create",!  zprint create
	for j=1:1:maxrtn do
	. set filebase="txt"_j
	. set filename=filebase_".m"
	. open filename:new
	. use filename
	. write filebase,";",!
	. write "      set txtsets(j)=","""",filebase,"""",!
	. write "      q",!
	. set expected(j)=filebase
	. for i=1:1:maxlab do
	. .  set labname=""
	. .  set labname="L"_i
	. .  for len=$length(labname):1:(1+$r(maxlen-1)) do
	. .  .  set char=$c(65+$random(26))  
	. .  .  set labname=labname_char
	. .  set expected(j,i)=labname
	. .  write labname,";",!
	. .  write "      set txtsets(j,i)=","""",labname,"""",!
	. .  write "      q",!
	. close filename
	zbreak -*
run;
	write "zprint run",!  zprint run
	for j=1:1:maxrtn do
	. set filebase="txt"_j
	. set filename=filebase_".m"
	. for i=1:1:maxlab do
	. . set lab=expected(j,i)_"+1" 
	. . set irtn=filebase
	. . set source=$text(@lab^@irtn)
	. . set lab=expected(j,i)
	. . ;write "do ",lab,"^",irtn,!
	. . do @lab^@irtn
	. do ^@irtn
	;
	write "do verify",!  do verify
	zwr zbcnt
	quit
	;
	;
	;
	;
	;
	;
	;
	;
verify
	write "zprint verify",!  zprint verify
	write "do verlines",!  
	set totline=maxlab*3+3
	for rtnno=1:1:maxrtn do
	. for lineno=1:1:totline do
	. . set lab="+"_lineno
	. . set srclines(rtnno,lineno)=$text(@lab^@expected(rtnno))
	. do verlines(rtnno,expected(rtnno))
	;
	;
	for j=1:1:maxrtn do
	. for i=1:1:maxlab do
	. . if $get(expected(j,i))'=$get(txtsets(j,i)) write "verify failed",!  zwr  halt
	;
	write $text(+0)," finished successfully",!
	quit
verlines(rtnno,filebase);
	new lineno,readline
	set fn=filebase_".m"	; To use indirection
	set devparm="readonly"
	set filelnamewithextension="fn"
	open @filelnamewithextension:@devparm
	use @filelnamewithextension
	set lnvar="readline(rtnno,lineno)"
	for lineno=1:1:totline do
	.  read @lnvar		; To exercise indirection code
	close @filelnamewithextension
	for lineno=1:1:totline do
	. if $get(readline(lineno))'=$get(srclines(lineno)) write "verify failed",!  zwr  halt
	q
