; Set a global variable
;
;	Parameter
;	  gvn		global variable to set.
;	  val		value to assign to the global variable
;
;	Return value
;	  1		success
;	  0		failure
;
set(gvn,val)
	new ref,rsp,rval
	i $E(gvn,1,1)'="^" zm GTMERR("GTM-E-NOTGBL"):gvn
	s ref=$$gvn2ref^cvt(gvn)
	s val=$$str2LS^cvt(val)
	do send^tcp(OpType("Set"),$C(0)_$$str2LS^cvt(ref)_val)
	s rsp=$$receive^tcp()
	s response=$$ref2gvn^cvt(ref)
;	w "response = ",response,!
	s rval=1
	i Resp("Class")=1 Do
	. w "Set failed- ",Resp("Type"),": ",Error(Resp("Type")),!
	. i Resp("Fatal") Do
	. . do close^tcp,^connect(Server("ip"),Server("port"),Server("agent"),Server("pw"))
	. s rval=0
	q rval


