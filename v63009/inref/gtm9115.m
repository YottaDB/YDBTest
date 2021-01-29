;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
; 								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ; Test the correctness of the conversion by converting between DEC and OCT to
 ; get back the original input.
 ; DEC to OCT and OCT to DEC conversion is performed using random values of 18 digits as input.
 ; OCT to DEC and DEC to OCT is performed using random values of 32 digits as input
 ; 	 Both types of conversion are executed for 2 seconds.
 write "Checking DEC to OCT and OCT to DEC conversion of 18 digit random positive numbers for 2 seconds",!
 set interval=2000000 ; 2 seconds in mili seconds
 set iend=$zut+interval
 set istart=1
 for  do  quit:iend<istart
  . set istart=$zut
  . quit:iend<istart
  . set i=$$getrandnumdecexactlen(18)
  . set k=$$FUNC^%DO(i)
  . set l=$$FUNC^%OD(k)
  . if i'=l do
  . . write "FAILED to convert input: ",i," ",k," ",l,!
  . . quit
 write "Completed",!
 ;
 write "Checking OCT to DEC and DEC to OCT conversion of 21 digit random values for 2 seconds",!
 set iend=$zut+interval
 set istart=1
 set inp=""
 ;set char=""
 for  do  quit:iend<istart
 . set inp=$$getrandnumoctexactlen(21)
 . set istart=$zut
 . quit:iend<istart
 . set k=$$FUNC^%OD(inp)
 . set l=$$FUNC^%DO(k)
 . if inp'=l do
 . . write "FAILED to convert input: ",inp," ",k," ",l,!
 . . quit
 write "Completed",!

 ; Test the correctness of the conversion by converting between HEX and OCT to
 ; get back the original input.
 ; HEX to OCT and OCT to HEX conversion is performed using random values of 16 digits as input.
 ; OCT to HEX and HEX to OCT is performed using random values of 32 digits as input
 ; Note: hex random values are generated by mapping numbers between 10 and 15 to 'A' and 'F'.
 ; 	 Both types of conversion are executed for 2 seconds.
 write "Checking HEX to OCT and OCT to HEX conversion of 16 digit random values for 2 seconds",!
 set iend=$zut+interval
 set istart=1
 set inp=""
 set char=""
 set asciofa=$ascii("A")
 for  do  quit:iend<istart
 . set inp=$$getrandnumhexexactlen(16)
 . set istart=$zut
 . quit:iend<istart
 . set k=$$FUNC^%HO(inp)
 . set l=$$FUNC^%OH(k)
 . if inp'=l do
 . . write "FAILED to convert input: ",inp," ",k," ",l,!
 . . quit
 write "Completed",!
;
 write "Checking OCT to HEX and HEX to OCT conversion of 21 digit random values for 2 seconds",!
 set iend=$zut+interval
 set istart=1
 set inp=""
 ;set char=""
 for  do  quit:iend<istart
 . set inp=$$getrandnumoctexactlen(21)
 . set istart=$zut
 . quit:iend<istart
 . set k=$$FUNC^%OH(inp)
 . set l=$$FUNC^%HO(k)
 . if inp'=l do
 . . write "FAILED to convert input: ",inp," ",k," ",l,!
 . . quit
 write "Completed",!
 quit

; The below routine checks the behavior of %HD and %DH for NULL input.
; Expected behavior: return 0 with default length, which is 1 for %HO/%OH/%OH and 8 for %DO.
nullvalinp
	write "Checking the behavior of utility functions %HO, %OH, %OD and %DO when null input is given",!
	set h=$$FUNC^%HO("") write:h'="0" "Failed, output expected is 0 but got ",h,!
	set h=$$FUNC^%OD("") write:h'="0" "Failed, output expected is 0 but got ",h,!
	set h=$$FUNC^%OH("") write:h'="0" "Failed, output expected is 0 but got ",h,!
	set h=$$FUNC^%DO("") write:h'="000000000000" "Failed, output expected is 000000000000 but got ",h,!
	write "Completed",!
	quit

; The below routine checks the behavior of %DO when length value is not specified as part of input.
; Expected behavior: the output has a length of 12
; Note: Input given ensures the computed value to have a length lesser than 12
; 	such that default 12 byte output value length can be observed.
defaultlenval
	write "Verifying default 12 byte output value length of %DO",!
	set o=$$FUNC^%DO(15,)
	write:$length(o)'=12 "Failed, output not 8 digits :",o,!
	write "Completed",!
	quit

; The below routine checks the behavior of %DO and %OD for signed input.
; Expected behavior:
; 	%OH results in appropriate signed hex value (i.e 2's complement) with the length parameter determining the number of leading 7's
; 	%OD results in appropriate signed hex value (i.e 2's complement) for positive signed input
; 	%OD results in NULL for negative signed input
signedvalinp
	write "Checking conversion utilities %DO and %OD for signed value input",!
	set o=$$FUNC^%DO(-7295,10)
	write:o'="7777761601" "Failed, expected output is 7777761601 but got ",o,!
	set o=$$FUNC^%DO(+7295,10)
	write:o'="0000016177" "Failed, expected output is 0000016177 but got ",o,!
	set o=$$FUNC^%OD("+161601")
	write:o'="58241" "Failed, expected output is 58241 but got ",o,!
	set o=$$FUNC^%OD("-161601")
	write:$length(o)'=0 "Failed, expected empty output but got ",o,!
	write "Completed",!
	quit

; The below routine checks the behavior of the conversion utilties for input with mixed values like 123X234.
; Conversions checked DEC to OCT to DEC of positive value, DEC to OCT of negative value and HEX to OCT to HEX
; Expected behavior: verifies that the characters before the first invalid character are converted
mixedvalinp
	write "Checking conversion for values such as 18446744073709551615vjj444, 177777777777777777777788 and FFFFFFFFFFFFFFFFhhh "
	write "where only characters prior to the first occurence of an invalid character need to be considered",!
	set inp="18446744073709551615vjj444"
	set exppout="18446744073709551615"
	set expnout="7000000000000000000001"
	set exphout="FFFFFFFFFFFFFFFF"
	write "Checking conversion of positive decimal number 18446744073709551615vjj444 expecting 18446744073709551615",!
	set out=$$FUNC^%DO(inp)
	set out=$$FUNC^%OD(out_"88")
	if out'=exppout do
	. write "FAILED to convert inp ",inp," to ",exppout," current result ",out,!
	write "Checking conversion of negative decimal value -9223372036854775807aaa expecting 7000000000000000000001",!
	set inp="-9223372036854775807aaa"
	set out=$$FUNC^%DO(inp)
	if out'=expnout do
	. write "FAILED to convert inp ",inp," to ",expnout," current result ",out,!
	write "Checking conversion of hexadecimal number FFFFFFFFFFFFFFFFhhh expecting FFFFFFFFFFFFFFFF",!
	set inp="FFFFFFFFFFFFFFFFhhh"
	set out=$$FUNC^%HO(inp)
	set out=$$FUNC^%OH(out_"88")
	if out'=exphout do
	. write "FAILED to convert inp ",inp," to ",exphout," current result ",out,!
	write "Completed",!
	quit

; The below routine checks the behavior of DEC to OCT, OCT to DEC, HEX to OCT and OCT to HEX conversion for maximum 64 bit and 32 bit values.
; Expected behavior: correct conversion verified by observing reproduction of same input value after dec to hex and hex to dec conversion
mxvalinp
	write "Checking DEC to OCT and OCT to DEC conversion of maximum 64 bit value",!
	set maxvalue="9223372036854775807"
	set DtoOrslt=$$FUNC^%DO(maxvalue)
	set OtoDrslt=$$FUNC^%OD(DtoOrslt)
	write:maxvalue'=OtoDrslt "FAILED to convert 64 bit maximum value from DEC->OCT->DEC",maxvalue,!
	write "Checking HEX to OCT and OCT to HEX conversion of maximum 64 bit value",!
	set maxvalue="7FFFFFFFFFFFFFFF"
	set HtoOrslt=$$FUNC^%HO(maxvalue)
	set OtoHrslt=$$FUNC^%OH(HtoOrslt)
	write:maxvalue'=OtoHrslt "FAILED to convert 64 bit maximum value from HEX->OCT->HEX",maxvalue,!
	write "Checking DEC to OCT and OCT to DEC conversion of maximum 32 bit value",!
	set maxvalue="4294967295"
	set DtoOrslt=$$FUNC^%DO(maxvalue)
	set OtoDrslt=$$FUNC^%OD(DtoOrslt)
	write:maxvalue'=OtoDrslt "FAILED to convert 32 bit maximum value from DEC->OCT->DEC",maxvalue,!
	write "Checking HEX to OCT and OCT to HEX conversion of maximum 64 bit value",!
	set maxvalue="FFFFFFFF"
	set HtoOrslt=$$FUNC^%HO(maxvalue)
	set OtoHrslt=$$FUNC^%OH(HtoOrslt)
	write:maxvalue'=OtoHrslt "FAILED to convert 32 bit maximum value from HEX->OCT->HEX",maxvalue,!
	write "Completed",!
	quit

; The below routine checks that %HO rejects negative signed input and returns null.
horejectsignedinput
	write "Checking if negative signed input to %HO is rejected and null is returned",!
	set empty=""
	set inpval="-FFFF"
	set newhores=$$FUNC^%HO(inpval)
	write:newhores'=empty "FAILED as conversion of an empty input returned a value ",newhores,!
	write "Completed",!
	quit

; Correctness checking routines

; The below routine checks that the current %DO implementation produces the same result as
; the pre-V6.3-009 implementation for up to a 16 digit input.
correctnessdectooct
	write "Checking that the new implementation of %DO produces the same values as the previous implementation",!
	set inpval=$$getrandnumdec(16)
	set prevdores=$$FUNCPREVDECTOOCT(inpval,$length(inpval))
	set newdores=$$FUNC^%DO(inpval,$length(inpval))
	write:prevdores'=newdores "FAILED as conversion from dec to oct produced different values for pre-V6.3-009 and current implementations ",prevdores," ",newdores,!
	write "Completed",!
	quit

; The below routine checks that the current %OD implementation produces the same result as
; the pre-V6.3-009 implementation for up to a 16 digit input.
correctnessocttodec
	write "Checking that the new implementation of %OD produces the same values as the previous implementation",!
	set inpval=$$getrandnumoct(16)
	set prevodres=$$FUNCPREVOCTTODEC(inpval)
	set newodres=$$FUNC^%OD(inpval)
	write:prevodres'=newodres "FAILED as conversion from dec to oct produced different values for pre-V6.3-009 and current implementations ",prevodres," ",newodres,!
	write "Completed",!
	quit

; The below routine checks that the current %HO implementation produces the same result as
; the pre-V6.3-009 implementation for up to a 16 digit input.
correctnesshextooct
	write "Checking that the new implementation of %HO produces the same values as the previous implementation",!
	set inpval=$$getrandnumhex(16)
	set prevhores=$$FUNCPREVHEXTOOCT(inpval)
	set newhores=$$FUNC^%HO(inpval)
	write:prevhores'=newhores "FAILED as conversion from hex to oct resulted in different values for previous and new implementation ",prevhores," ",newhores,!
	write "Completed",!
	quit

; The below routine checks that the current %OH implementation produces the same result as
; the pre-V6.3-009 implementation for up to a 16 digit input.
correctnessocttohex
	write "Checking that the new implementation of %OH produces the same values as the previous implementation",!
	set inpval=$$getrandnumoct(16)
	set prevohres=$$FUNCPREVOCTTOHEX(inpval)
	set newohres=$$FUNC^%OH(inpval)
	write:prevohres'=newohres "FAILED as conversion from dec to oct produced different values for pre-V6.3-009 and current implementations ",prevohres," ",newohres,!
	write "Completed",!
	quit

; Functions to generate random inputs

; This generates random numbers for the performance tests of length n where
; the first digit of the number is in the range 1-7 and the remaining digits
; are in the range 0-7. This ensures that the numbers are valid for all 3
; bases (octal, decimal and hexadecimal).

; This generates a random decimal number of up to n digits
getrandnumdec(n)
	quit:n<2 $random(10) ; if n is less than 2, return a 1 digit number
	quit $random(10*n)

; This generates a random decimal number of up to n digits where the first digit
; is in the range 1-9 and the remaining digits are in the range 0-9. This ensures
; that the number will have no leading zeroes.
getrandnumdecexactlen(n)
	quit:n<2 $random(10) ; if n is less than 2, return a 1 digit number
	quit ($random(9)+1)_$random(10*(n-1))

; This generates a random octal number of up to n digits
getrandnumoct(n)
	quit:n<2 $random(8) ; if n is less than 2, return a 1 digit number
	set num=$random(8)
	for i=1:1:n-1  do
	. set num=num_$random(8)
	quit num

; This generates a random octal number of length n where the first digit of the
; number is in the range 1-7 and the remaining digits are in the range 0-7.
; This ensures that the number has no leading zeroes
getrandnumoctexactlen(n)
	quit:n<2 $random(8) ; if n is less than 2, return a 1 digit number
	set num=$random(7)+1 ; ensure that the first digit is non-zero so the number will actually be length n
	for i=1:1:n-1  do
	. set num=num_$random(8)
	quit num

; This generates a random hexadecimal number of up to n digits
getrandnumhex(n)
	set asciofa=$ascii("A")
	set i=$random(16),char=i
	set:i>9 char=$char((i#10)+asciofa)	; ascii value of 'A' is added to the i#10 value resulting in characters 'A-F'
	set inp=char
	quit:n<2 inp
	for j=1:1:n-1  do
	 . set i=$random(16),char=i
	 . set:i>9 char=$char((i#10)+asciofa)	; ascii value of 'A' is added to the i#10 value resulting in characters 'A-F'
	 . set inp=inp_char
	quit inp

; This generates a random hexadecimal number of length n where the first digit of
; the number is in the range 1-F and the remaining digits are in the range 0-F.
; This ensures that the number has no leading zeroes.
getrandnumhexexactlen(n)
	set asciofa=$ascii("A")
	set i=$random(15)+1,char=i
	set:i>9 char=$char((i#10)+asciofa)	; ascii value of 'A' is added to the i#10 value resulting in characters 'A-F'
	set inp=char
	quit:n<2 inp
	for j=1:1:n-1  do
	 . set i=$random(16),char=i
	 . set:i>9 char=$char((i#10)+asciofa)	; ascii value of 'A' is added to the i#10 value resulting in characters 'A-F'
	 . set inp=inp_char
	quit inp

;
; Pre V6.3-009 implementations of %HO, %DO, %OD and %OH
; plus pre V6.3-009 implemenation of convbaseutil are
; copied below for comparisons with current versions

; pre-V6.3-009 %HO
FUNCPREVHEXTOOCTFM(h)
	n c,d,dg,o
	s d=0,h=$tr(h,"abcdef","ABCDEF"),o=""
	f c=1:1:$l(h) s dg=$f("0123456789ABCDEF",$e(h,c)) q:'dg  s d=(d*16)+(dg-2)
	f  q:'d  s o=d#8_o,d=d\8
	q:0<o o
	q 0
FUNCPREVHEXTOOCT(h)
	q:$tr(h,"E","e")<0 ""
; Need to retrofit this fix onto the old %HO for a fair performance comparison or the new %HO
; will be slower than the old for 14 digits because of this fix.
	new e set e=$zextract(h,1,2) set:("0x"=e)!("0X"=e) h=$zextract(h,3,$zlength(h))
	q:$l(h)<15 $$FUNCPREVHEXTOOCTFM(h)
	q $$PREVCONVERTBASE(h,16,8)

; pre-V6.3-009 %DO
FUNCPREVDECTOOCTFM(d,l)
	q:d=0 $e("000000000000",1,l)
	n o
	s o=""
	f  q:'d  s o=d#8_o,d=d\8
	q $e("000000000000",1,l-$l(o))_o
FUNCPREVDECTOOCT(d,l)
	n isn,i,h,apnd
	s:'$l($g(l)) l=12
	s isn=0,i=0,h="",apnd="0"
	if d["-" do
	. s isn=1,d=$extract(d,2,$l(d))
	if ($l(d)<18) do
	. s h=$$FUNCPREVDECTOOCTFM(d,l)
	else  do
	. s h=$$PREVCONVERTBASE(d,10,8)
	if (isn&(h'="0")) do
	. s h=$$PREVCONVNEG(h,8)
	. s apnd="7"
	s i=$l(h)
	f  q:i'<l  s h=apnd_h,i=i+1
	q h

; pre-V6.3-009 %OD
; fix for invalid input inconsistency retro-fitted for fair speed comparison
FUNCPREVOCTTODECFM(o)
	n d,dg,ex
	s d=0,o=+o
	f dg=1:1:$l(o) s ex=$find("01234567",$e(o,dg)) q:'ex  s d=(d*8)+(ex-2)
	q d
FUNCPREVOCTTODEC(o)
	q:"-"=$ze(o,1) ""
	q:$l(o)<19 $$FUNCPREVOCTTODECFM(o)
	q $$PREVCONVERTBASE(o,8,10)

; pre-V6.3-009 %OH
; fix for invalid input inconsistency retro-fitted for fair speed comparison
FUNCPREVOCTTOHEXFM(o)
	n d,dg,ex,h
	s d=0,h="",o=+o
	f dg=1:1:$l(o) s ex=$find("01234567",$e(o,dg)) q:'ex  s d=(d*8)+(ex-2)
	f  q:'d  s h=$e("0123456789ABCDEF",d#16+1)_h,d=d\16
	q h
FUNCPREVOCTTOHEX(o)
	q:o=0 0
	q:"-"=$ze(o,1) ""
	q:o'?1.N ""
	q:o[8!(o[9) ""
	q:$l(o)<19 $$FUNCPREVOCTTOHEXFM(o)
	q $$PREVCONVERTBASE(o,8,16)

; Previous convbaseutil.mpt with comments preserved so that above functions do not call
; the new convbaseutil

;Computes val1+val2 for any arbitrary-length val1 and val2 and for  base <= 16
PREVADDVAL(val1,val2,base)
	new carry,res,len,currsum,len1,len2,val1r,val2r,tmp1,tmp2,i,c,d,j,k
	for k=0:1:16 set:k<10 c($CHAR(k+48))=k SET:k'<10 c($CHAR(k+55))=k
	for j=0:1:16 set:j<10 d(j)=$CHAR(j+48) SET:j'<10 d(j)=$CHAR(j+55)
	set val1r=$reverse(val1),val2r=$reverse(val2)
	set carry=0,res="",len1=$length(val1r),len2=$length(val2r),len=len1
	set:len2>len1 len=len2
	for i=1:1:len do
	. set tmp1=0,tmp2=0
	. set:(i'>len1) tmp1=c(($extract(val1r,i))) set:(i'>len2) tmp2=c(($extract(val2r,i)))
	. set currsum=tmp1+tmp2+carry
	. set res=d((currsum#base))_res,carry=$piece((currsum/base),".")
	set:carry>0 res=carry_res
	quit res
;Computes num*x by using x*((num>>2^0)&&1)*2^0 + ((num>>2^1)&&1)*2^1 + ((num>>2^2)&&1)*2^2 +...)
;Will multiply two arbitrary-length numbers for base <= 10, but for base > 10 will only multiply
;single digit numbers
PREVMULTIPLYBYNUMBER(num,x,base)
	new res,k,c
	if ($find("ABCDEF",num)) do
	. for k=0:1:16 set:k<10 c($CHAR(k+48))=k SET:k'<10 c($CHAR(k+55))=k
	. set num=c(num)
	set res="0"
	for  quit:num=0  do
	. if (num#2>0) do
	.. set res=$$PREVADDVAL(res,x,base)
	. set num=$piece((num/2),"."),x=$$PREVADDVAL(x,x,base)
	quit res
PREVCONVERTBASE(val,frombase,tobase)
	new m,res,power
	set m=$$PREVVALIDLEN(val,frombase)
	set res="0",power=1
	for  quit:m<1  do
	. set res=$$PREVADDVAL(res,$$PREVMULTIPLYBYNUMBER($extract(val,m),power,tobase),tobase)
	. set power=$$PREVMULTIPLYBYNUMBER(frombase,power,tobase),m=$increment(m,-1)
	quit res
;Takes a base 16 or base 8 number and converts that number
;into its two's compliment representation (flip bits and add one)
PREVCONVNEG(v,base)
	new i,c,ns,charmap,pocharmap
	set charmap="0123456789ABCDEF"
	set:base=8 charmap="01234567"
	set pocharmap=($extract(charmap,2,$length(charmap)))_"0"
	set v=$translate(v,charmap,$reverse(charmap))
	set ns="",c="0"
	for i=0:1:$length(v)  quit:(c'="0")  set c=$extract(v,$length(v)-i),c=$translate(c,charmap,pocharmap),ns=c_ns
	set:i'=$length(v) ns=$extract(v,1,$length(v)-i)_ns
	set:$find(($extract(charmap,1,(base/2))),$extract(ns,1)) ns=($extract(charmap,$length(charmap)))_ns
	quit ns
;Returns length of string until which all characters are valid for the given base (works up to base 16)
PREVVALIDLEN(val,base)
	new i,valbasechar,invalidi,len
	set valbasechar=$extract("0123456789ABCDEF",1,base),len=$length(val)
	quit:'len 0
	for i=1:1:$length(val)  set invalidi='($find(valbasechar,($extract(val,i))))  quit:invalidi
	quit $select($get(invalidi):i-1,1:i)
