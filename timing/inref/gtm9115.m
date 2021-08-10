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
; Moved from v63009 due to timing failures when other tests are run in parallel

; Performance checking routines

; The below routine checks the performance of the current %DO implementation with the pre-V6.3-009 implementation.
; Performance check is done for random input of exactly 16 digit and 20 digit length. Both implementations are run for a
; 2 second loop keeping track of the number of conversions done and this is compared to verify that the current implementation
; is faster. 16 digit and 20 digit inputs are used because they use different code paths in both versions of $DO.
compdectooct
	write "Comparing performance of current %DO implementation vs previous %DO implementation for 16 digit values",!
	set interval=200
   	set iend=$zgetjpi(0,"CPUTIM")+interval
   	set istart=1
	set ncnt=1
   	for  do  quit:iend<istart
   	 . set istart=$zgetjpi(0,"CPUTIM")
	 . set ncnt=$increment(ncnt)
   	 . quit:iend<istart
   	 . set i=$$getrandnumdecexactlen(16)
	 . set k=$$FUNC^%DO(i,16)
	; checking previous m implementation
	set iend=$zgetjpi(0,"CPUTIM")+interval
	set istart=1
        set ocnt=1
	for  do  quit:iend<istart
         . set istart=$zgetjpi(0,"CPUTIM")
         . set ocnt=$increment(ocnt)
         . quit:iend<istart
         . set i=$$getrandnumdecexactlen(16)
         . set k=$$FUNCPREVDECTOOCT(i,16)
	write "Performance: current ",ncnt," ","previous ",ocnt,!
	if (ncnt<(ocnt*.9)) write "FAILED as performance is less than 90% of previous implementation ","new count:",ncnt," ","previous count:",ocnt," ",!
	;
	write "Comparing performance of current %DO implementation vs previous %DO implementation for 20 digit values",!
        set iend=$zgetjpi(0,"CPUTIM")+interval
        set istart=1
        set ncnt=1
        for  do  quit:iend<istart
         . set istart=$zgetjpi(0,"CPUTIM")
         . set ncnt=$increment(ncnt)
         . quit:iend<istart
         . set i=$$getrandnumdecexactlen(20)
         . set k=$$FUNC^%DO(i,16)
        ; checking previous m implementation
        set iend=$zgetjpi(0,"CPUTIM")+interval
        set istart=1
        set ocnt=1
        for  do  quit:iend<istart
         . set istart=$zgetjpi(0,"CPUTIM")
         . set ocnt=$increment(ocnt)
         . quit:iend<istart
         . set i=$$getrandnumdecexactlen(20)
         . set k=$$FUNCPREVDECTOOCT(i,16)
	write "Performance: current ",ncnt," ","previous ",ocnt,!
        if (ncnt<ocnt*.9) write "FAILED as performance is less than 90% of previous implementation ","new count:",ncnt," ","previous count:",ocnt," ",!
	write "Completed",!
	quit

; The below routine checks the performance of the current %OD implementation with the pre-V6.3-009 implementation.
; Performance check is done for random input of exactly 20 digit length. Both implementations are run for a 2 second
; loop keeping track of the number of conversions done and this is compared to verify that the current implementation
; is faster. Only 20 digit inputs are used the code for less than 19 digits was not changed in V6.3-009 and the new
; implementation runs slightly slower for under 19 digits due to overhead but the new implementation runs faster for.
; larger inputs.
compocttodec
	write "Comparing performance of current %OD implementation vs previous %OD implementation for 20 digit values",!
	set interval=200
        set iend=$zgetjpi(0,"CPUTIM")+interval
        set istart=1
        set ncnt=1
        for  do  quit:iend<istart
         . set istart=$zgetjpi(0,"CPUTIM")
         . set ncnt=$increment(ncnt)
         . quit:iend<istart
         . set i=$$getrandnumoctexactlen(20)
         . set k=$$FUNC^%OD(i)
        ; checking previous m implementation
        set iend=$zgetjpi(0,"CPUTIM")+interval
        set istart=1
        set ocnt=1
        for  do  quit:iend<istart
         . set istart=$zgetjpi(0,"CPUTIM")
         . set ocnt=$increment(ocnt)
         . quit:iend<istart
         . set i=$$getrandnumoctexactlen(20)
         . set k=$$FUNCPREVOCTTODEC(i)
	write "Performance: current ",ncnt," ","previous ",ocnt,!
        if (ncnt<ocnt) write "FAILED as performance is less than previous implementation ","new count:",ncnt," ","previous count:",ocnt," ",!
	write "Completed",!
	quit

; The below routine checks the performance of the current %HO implementation with the pre-V6.3-009 implementation.
; Performance check is done for random input of exactly 14 digit and 16 digit length. Both implementations are run for a
; 2 second loop keeping track of the number of conversions done and this is compared to verify that the current
; implementation is faster. 14 digit and 16 digit inputs are used because they use different code paths in both versions of $HO.
; Since the 14 digit implementation runs virtually identical code and occasionally performs slightly worse than the old, it is
; compared to 90% of the old implementation's performance.
comphextooct
	write "Comparing performance of current %HO implementation vs previous %HO implementation for 14 digit values",!
	set interval=200
   	set iend=$zgetjpi(0,"CPUTIM")+interval
   	set istart=1
	set ncnt=1
   	for  do  quit:iend<istart
   	 . set istart=$zgetjpi(0,"CPUTIM")
	 . set ncnt=$increment(ncnt)
   	 . quit:iend<istart
   	 . set i=$$getrandnumhexexactlen(14)
	 . set k=$$FUNC^%HO(i)
	; starting previous m implementation
	set iend=$zgetjpi(0,"CPUTIM")+interval
	set istart=1
        set ocnt=1
	for  do  quit:iend<istart
         . set istart=$zgetjpi(0,"CPUTIM")
         . set ocnt=$increment(ocnt)
         . quit:iend<istart
         . set i=$$getrandnumhexexactlen(14)
	 . set k=$$FUNCPREVHEXTOOCT(i)
	write "Performance: current ",ncnt," ","previous ",ocnt,!
	write:(ncnt<(ocnt*0.9)) "FAILED as performance is less than 90% of previous implementation ","new count:",ncnt," ","previous count:",ocnt," ",!
	;
	write "Comparing performance of current %HO implementation vs previous %HO implementation for 16 digit values",!
        set iend=$zgetjpi(0,"CPUTIM")+interval
        set istart=1
        set ncnt=1
        for  do  quit:iend<istart
         . set istart=$zgetjpi(0,"CPUTIM")
         . set ncnt=$increment(ncnt)
         . quit:iend<istart
         . set i=$$getrandnumhexexactlen(16)
         . set k=$$FUNC^%HO(i)
        ; starting previous m implementation
        set iend=$zgetjpi(0,"CPUTIM")+interval
        set istart=1
        set ocnt=1
        for  do  quit:iend<istart
         . set istart=$zgetjpi(0,"CPUTIM")
         . set ocnt=$increment(ocnt)
         . quit:iend<istart
         . set i=$$getrandnumhexexactlen(16)
         . set k=$$FUNCPREVHEXTOOCT(i)
	write "Performance: current ",ncnt," ","previous ",ocnt,!
        write:(ncnt<ocnt) "FAILED as performance is less than previous implementation ","new count:",ncnt," ","previous count:",ocnt," ",!
	write "Completed",!
	quit

; The below routine checks the performance of the current %OH implementation with the pre-V6.3-009 implementation.
; Performance check is done for random input of exactly 16 digit and 20 digit lengths. Both implementations are run for
; a 2 second loop keeping track of the number of conversions done and this is compared to verify that the current
; implementation is faster. 16 digit and 20 digit inputs are used because they use different code paths in both versions of $OH.
; Since the 16 digit implementation runs virtually identical code and occasionally performs slightly worse than the old, it is
; compared to 90% of the old implementation's performance.
compocttohex
	write "Comparing performance of current %OH implementation vs previous %OH implementation for 16 digit values",!
	set interval=200
   	set iend=$zgetjpi(0,"CPUTIM")+interval
   	set istart=1
	set ncnt=1
   	for  do  quit:iend<istart
   	 . set istart=$zgetjpi(0,"CPUTIM")
	 . set ncnt=$increment(ncnt)
   	 . quit:iend<istart
   	 . set i=$$getrandnumoctexactlen(16)
	 . set k=$$FUNC^%OH(i)
	; starting previous m implementation
	set iend=$zgetjpi(0,"CPUTIM")+interval
	set istart=1
        set ocnt=1
	for  do  quit:iend<istart
         . set istart=$zgetjpi(0,"CPUTIM")
         . set ocnt=$increment(ocnt)
         . quit:iend<istart
         . set i=$$getrandnumoctexactlen(16)
	 . set k=$$FUNCPREVOCTTOHEX(i)
	write "Performance: current ",ncnt," ","previous ",ocnt,!
	write:(ncnt<(ocnt*0.9)) "FAILED as performance is less than 90% of previous implementation ","new count:",ncnt," ","previous count:",ocnt," ",!
	;
	write "Comparing performance of current %OH implementation vs previous %OH implementation for 20 digit values",!
        set iend=$zgetjpi(0,"CPUTIM")+interval
        set istart=1
        set ncnt=1
        for  do  quit:iend<istart
         . set istart=$zgetjpi(0,"CPUTIM")
         . set ncnt=$increment(ncnt)
         . quit:iend<istart
         . set i=$$getrandnumoctexactlen(20)
         . set k=$$FUNC^%OH(i)
        ; starting previous m implementation
        set iend=$zgetjpi(0,"CPUTIM")+interval
        set istart=1
        set ocnt=1
        for  do  quit:iend<istart
         . set istart=$zgetjpi(0,"CPUTIM")
         . set ocnt=$increment(ocnt)
         . quit:iend<istart
         . set i=$$getrandnumoctexactlen(20)
         . set k=$$FUNCPREVOCTTOHEX(i)
	write "Performance: current ",ncnt," ","previous ",ocnt,!
        write:(ncnt<ocnt) "FAILED as performance is less than previous implementation ","new count:",ncnt," ","previous count:",ocnt," ",!
	write "Completed",!
	quit

; Functions to generate random inputs

; This generates random numbers for the performance tests of length n where
; the first digit of the number is in the range 1-7 and the remaining digits
; are in the range 0-7. This ensures that the numbers are valid for all 3
; bases (octal, decimal and hexadecimal).

; This generates a random decimal number of up to n digits where the first digit
; is in the range 1-9 and the remaining digits are in the range 0-9. This ensures
; that the number will have no leading zeroes.
getrandnumdecexactlen(n)
	quit:n<2 $random(10) ; if n is less than 2, return a 1 digit number
	quit ($random(9)+1)_$random(10*(n-1))

; This generates a random octal number of length n where the first digit of the
; number is in the range 1-7 and the remaining digits are in the range 0-7.
; This ensures that the number has no leading zeroes
getrandnumoctexactlen(n)
	quit:n<2 $random(8) ; if n is less than 2, return a 1 digit number
	set num=$random(7)+1 ; ensure that the first digit is non-zero so the number will actually be length n
	for i=1:1:n-1  do
	. set num=num_$random(8)
	quit num

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
