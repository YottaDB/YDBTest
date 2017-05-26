per2996	; ; ; test mailbox reads for timeout
	;
	n (act)
	i '$d(act) n act s act="s zp=$zpos"
	s cnt=0
	zsy "define/group perver "_$tr($p($zver," ",2),".-")
	s in="mbx",msg="hello",tmout=30
	s opnarg="in:tmpmbx",clsarg="in" d test
	s opnarg="in:prmmbx",clsarg="in:delete" d test
	w !,$s(cnt:"BAD",1:"OK")," from ",$t(+0)
	zsy "deassign/group perver"
	q
test	o @opnarg
	i $ztrnlnm("mbx")="" s cnt=cnt+1 x act
	u in
	w msg
	r y:5 
	e  s cnt=cnt+1 x act
	i y'=msg s cnt=cnt+1 x act
	r y:5
	i  s cnt=cnt+1 x act
	j notime^per2996(opnarg,clsarg):(process="NOTIME":startup="perversion.com")
	r y:tmout
	i  s cnt=cnt+1 x act
	e  zsy "mupip stop/name=notime"
	c @clsarg s io=$io,zio=$zio u $p
	i io'=$io s cnt=cnt+1 x act
	i zio'=$zio s cnt=cnt+1 x act
	i $ztrnlnm("mbx")'="" s cnt=cnt+1 x act
	q
notime(oa,ca)
	s in="mbx"
	o @oa u in
	r x
	w "This message should never be sent",!
	c @ca
	q
