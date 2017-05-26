; Release all locks held by this GT.CM client
;
;	Parameter
;	  none
;
;	Return value
;	  non-zero	successful
;	  0		unlock failed
;
unlockcl()
	new rval,rsp
	do send^tcp(OpType("Unlock client"),$$str2SS^cvt($J))
	s rval=1
	s rsp=$$receive^tcp()
;	i $l(rsp)=0 w "Unlock Client failed: TCP/IP I/O error",! do close^tcp q
	i Resp("Class")=1 Do
	. w "Unlock Client failed- ",Resp("Type"),": ",Error(Resp("Type")),!
	. i Resp("Fatal") Do
	. . do close^tcp,^connect(Server("ip"),Server("port"),Server("agent"),Server("pw"))
	. s rval=0
	q rval


