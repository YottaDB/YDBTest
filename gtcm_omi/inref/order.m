; Perform a $ORDER on a global variable
;
;	Parameter
;	  gvn		global variable to retrieve.
;
;	Return value
;	  result of $ORDER
;
order(gvn)
	new ref,rsp,value
	i $E(gvn,1,1)'="^" zm GTMERR("GTM-E-NOTGBL"):gvn
	s ref=$$gvn2ref^cvt(gvn)
	do send^tcp(OpType("Order"),$$str2LS^cvt(ref))
	s rsp=$$receive^tcp()
	i $l(rsp)=0 w "Order failed: TCP/IP I/O error",! do close^tcp q ""
	s value=$$SS2str^cvt(rsp)
	i Resp("Class")=1 Do
	. w "Order failed- ",Resp("Type"),": ",Error(Resp("Type")),!
	. i Resp("Fatal") Do
	. . do close^tcp,^connect(Server("ip"),Server("port"),Server("agent"),Server("pw"))
	. s value=""
	q value


