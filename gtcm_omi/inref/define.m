;	Perform a $D on a global
;
;	Parameter
;	  gvn		global variable to check
;
;	Return value
;	  non-zero	global exists
;	  0		global does not exist
;
define(gvn)
	n ref,rsp,define
	i $E(gvn,1,1)'="^" zm GTMERR("GTM-E-NOTGBL"):gvn
	s ref=$$gvn2ref^cvt(gvn)
	do send^tcp(OpType("Define"),$$str2LS^cvt(ref))
	s rsp=$$receive^tcp()
	i $l(rsp)=0 w "Define failed: TCP/IP I/O error",! do close^tcp q ""
	s define=$a(rsp)
	i Resp("Class")=1 Do
	. w "Define failed- ",Resp("Type"),": ",Error(Resp("Type")),!
	. i Resp("Fatal") Do
	. . do close^tcp,^connect(Server("ip"),Server("port"),Server("agent"),Server("pw"))
	q define


