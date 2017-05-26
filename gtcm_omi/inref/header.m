hdrinit(user,group)
	s HdrDef("Class")=1		; Default for OMI
	s HdrDef("User")=user
	s HdrDef("Group")=group
	s HdrDef("Sequence")=0
	q

; header consists of
; ---------------------------------------------------------------------
; |len* | class**  |Type |   User   |  Group   | Sequence | Req. ID***|
; |<SI> | <LI>     |<SI> |   <LI>   |  <LI>    | <LI>     | <LI>      |
; |     |          |     |          |          |          |           |
; ---------------------------------------------------------------------
;  *len is fixed at 11
;  **class is fixed at 1
;  ***Req. ID is a place holder, filled in by the server, and is set to zero.
;
encode(type)
	s HdrDef("Sequence")=(HdrDef("Sequence")+1)#65536
	q $c(11,1,0,type)_$$num2LI^cvt(HdrDef("User"))_$$num2LI^cvt(HdrDef("Group"))_$$num2LI^cvt(HdrDef("Sequence"))_$C(0,0)

;
; Decode header created by encode (for debugging purposes only)
;
dechdr(str)
	new pos
 	s Header("Len")=$$SI2num^cvt(str)
 	i Header("Len")'=11 w "Invalid Header length",! s ^Error("Header","Len")=Header("Len") h
 	s pos=SizeOf("SI")+1
 	s Header("Class")=$$LI2num^cvt($E(str,pos,pos+SizeOf("LI")))
 	i Header("Class")'=1 w "Invalid Class ID",! s ^Error("Header","Class")=Header("Class") h
 	s pos=pos+SizeOf("LI")
 	s Header("Type")=$$SI2num^cvt($E(str,pos,pos+SizeOf("SI")))
 	s pos=pos+SizeOf("SI")
 	s Header("User")=$$LI2num^cvt($E(str,pos,pos+SizeOf("LI")))
 	s pos=pos+SizeOf("LI")
 	s Header("Group")=$$LI2num^cvt($E(str,pos,pos+SizeOf("LI")))
 	s pos=pos+SizeOf("LI")
 	s Header("Sequence")=$$LI2num^cvt($E(str,pos,pos+SizeOf("LI")))
 	s pos=pos+SizeOf("LI")
 	s Header("Request ID")=$$LI2num^cvt($E(str,pos,pos+SizeOf("LI")))
 	q


; Decode response header.
; ---------------------------------------------------------------------
; |len  | class    |Type | Modifier | Svr Stat | Sequence | Req. ID   |
; |<SI> | <LI>     |<SI> |   <LI>   |  <LI>    | <LI>     | <LI>      |
; |     |          |     |          |          |          |           |
; ---------------------------------------------------------------------

decode(str)
	new pos,x
	s Resp("Len")=$$SI2num^cvt(str)
	i Resp("Len")'=11 w "Invalid Response Hdr Length",! s ^Error("Resp","Len")=Resp("Len") h
	s pos=SizeOf("SI")+1
	s Resp("Class")=$$LI2num^cvt($E(str,pos,pos+SizeOf("LI")))
	i Resp("Class")'=0,Resp("Class")'=1 w "Invalid Class ID",! s ^Error("Resp","Class")=Resp("Class") b
	s pos=pos+SizeOf("LI")
	s Resp("Type")=$$SI2num^cvt($E(str,pos,pos+SizeOf("SI")))
	s pos=pos+SizeOf("SI")
	s Resp("Modifier")=$$LI2num^cvt($E(str,pos,pos+SizeOf("LI")))
	s pos=pos+SizeOf("LI")
	s Resp("Svr Stat")=$$LI2num^cvt($E(str,pos,pos+SizeOf("LI")))
	s pos=pos+SizeOf("LI")
	s Resp("Sequence")=$$LI2num^cvt($E(str,pos,pos+SizeOf("LI")))
	s pos=pos+SizeOf("LI")
	s Resp("Request ID")=$$LI2num^cvt($E(str,pos,pos+SizeOf("LI")))
	i Resp("Class")=1 s x=Resp("Type") s Resp("Fatal")=$S(x=11:1,x=14:1,x=21:1,x=22:1,x=23:1,1:0)
	q

;
; Encode response header (for debugging purposes only)
;
encrsp(class,errtyp,errmod,svrstat,reqid)
	q $c(11)_$$num2LI^cvt(class)_$c(errtyp)_$$num2LI^cvt(errmod)_$$num2LI^cvt(svrstat)_$$num2LI^cvt(HdrDef("Sequence"))_$$num2LI^cvt(reqid)

