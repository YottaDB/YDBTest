; Kill a global variable
;
;	Parameter
;	  gvn		global variable to unlock.
;
;	Return value
;	  non-zero	successful
;	  0		unlock failed
;
kill(gvn)
	n ref,rval,rsp
	i $E(gvn,1,1)'="^" zm GTMERR("GTM-E-NOTGBL"):gvn
	s ref=$$gvn2ref^cvt(gvn)
	s rval=1
	do send^tcp(OpType("Kill"),$C(0)_$$str2LS^cvt(ref))
	s rsp=$$receive^tcp()
	s response=$$ref2gvn^cvt(ref)
;	w "response = ",response,!
	i Resp("Class")=1 Do
	. w "Kill failed- ",Resp("Type"),": ",Error(Resp("Type")),!
	. i Resp("Fatal") Do
	. . do close^tcp,^connect(Server("ip"),Server("port"),Server("agent"),Server("pw"))
	. s rval=0
	q rval


