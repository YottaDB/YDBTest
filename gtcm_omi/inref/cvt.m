;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; various conversion routines

; Convert mumps numeric into string containing binary representation
; and back.
num2SI(num)			; Byte
	q $c(num#256)

SI2num(str)
	q $a(str)

num2LI(num)			; Short
	q $c(num#256,num\256)

LI2num(str)
	q $a(str)+(256*$a(str,2))

num2VI(num)			; Int
	q $c(num#256,num\256#256,num\65536#256,num\16777216)

VI2num(str)
	q $a(str)+(256*$a(str,2))+(65536*$a(str,3))+(16777216*$a(str,4))

; Convert mumps string to string with binary representation of length
; prepended.
str2SS(str)			; Byte + String
	q $c($l(str))_str

SS2str(ss)
	q $e(ss,2,$a(ss)+1)

str2LS(str)			; Short + String
	q $$num2LI($l(str))_str

LS2str(ls)
	q $e(ls,3,$$LI2num(ls)+2)

str2VS(str)			; Int + String
	q $$num2VI($l(str))_str

VS2str(vs)
	q $e(vs,5,$$VI2num(vs)+4)

;
; gvn2ref - Convert global variable name to reference
;
gvn2ref(gvn)
	new ref,var,gvnsub,ndx,sub,qpos
	s ref=$$str2LS(Server("Environment"))
;	w gvn," --> (",Server("Environment")
;    w "gvn is : ",gvn,!
;    w "Server(Environment) is : ",Server("Environment"),!
	s var=$P(gvn,"(")
	s gvnsub=$E(gvn,$L(var)+2,$L(gvn)-1)
	s ref=ref_$$str2SS(var)
;	w ",",var
	i gvnsub="" q ref
	f ndx=1:1:Connect("Max Subscript") Do  q:gvnsub=""
	. if $E(gvnsub)="""" Do
	. . s sub=""
	. . F  s qpos=$F(gvnsub,"""",2)-1,sub=sub_$E(gvnsub,2,qpos-1),gvnsub=$E(gvnsub,qpos+1,$L(gvnsub)) q:$E(gvnsub)=","  q:gvnsub=""  zm:$E(gvnsub)'="""" GTMERR("YDB-E-NOTGBL"):gvn s sub=sub_""""
	. . s gvnsub=$E(gvnsub,2,$L(gvnsub))
	. e  s sub=$P(gvnsub,",",1) s gvnsub=$E(gvnsub,$L(sub)+2,$L(gvnsub))
	. s ref=ref_$$str2SS(sub)
;	w ")",!
	q ref

ref2gvn(ref)
	new env,pos,gvn,sub,qpos,sublen
	s env=$$LS2str(ref)
	s pos=$L(env)+SizeOf("LI")+1
	s gvn=$$SS2str($E(ref,pos,$L(ref)))
	s pos=pos+$L(gvn)+SizeOf("SI")
	i pos>$L(ref) q gvn
	s gvn=gvn_"("
	f  Do  q:pos>$L(ref)
	. s sub=$$SS2str($E(ref,pos,$L(ref)))
	. s sublen=$L(sub)
	. s qpos=0
	. f  s qpos=$F(sub,"""",qpos) q:qpos=0  s sub=$E(sub,1,qpos-1)_$C(34)_$E(sub,qpos,$L(sub)),qpos=qpos+1
	. s gvn=gvn_""""_sub_""""
	. s pos=pos+sublen+SizeOf("SI")
	. i pos>$L(ref) q
	. s gvn=gvn_","
	s gvn=gvn_")"
	q gvn



