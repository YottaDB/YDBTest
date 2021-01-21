;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2019-2021 YottaDB LLC and/or its subsidiaries.  ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ; Conversion between DEC and HEX to get back the original input is
 ; performed here to test the correctness of the $ZCONVERT.
 ; DEC to HEX and HEX to DEC conversion is performed using random values of 18 digits as input.
 ; HEX to DEC and DEC to HEX is performed using random values of 16 digits as input
 ; Note: hex random values are generated by mapping numbers between 10 and 15 to 'A' and 'F'.
 ; 	 Both types of conversion are executed for 2 seconds.
 write "Checking DEC to HEX and HEX to DEC conversion of 18 digit random positive numbers for 2 seconds",!
 set interval=2000000 ; 2 seconds in mili seconds
 set iend=$zut+interval
 set istart=1
 set maxval=214748364
 for  do  quit:iend<istart
  . set istart=$zut
  . quit:iend<istart
  . set seed=$zut#maxval
  . quit:seed=0
  . set first=$random(seed),second=$random(seed)
  . ; need to skip iteration as $RANDOM generated 0 which results in input similar to 0123
  . ; which though being converted correctly to 123 fails in our check below
  . quit:first=0
  . set i=first_second
  . set k=$zconvert(i,"DEC","HEX")
  . set l=$zconvert(k,"HEX","DEC")
  . if i'=l do
  . . write "FAILED to convert input: ",i," ",k," ",l,!
  . . quit
 write "Completed",!,!
 ;
 write "Checking HEX to DEC and DEC to HEX conversion of 16 digit random values for 2 seconds",!
 set iend=$zut+interval
 set istart=1
 set inp=""
 set char=""
 set asciofa=$ascii("A")
 for  do  quit:iend<istart
 . set inp=$random(7)
 . ; As random generates 0 and conversion for 0123 give 123 though being correct
 . ; results in failure for not being same as input. Hence avoiding 0 as first digit.
 . set:inp=0 inp=1
 . for j=1:1:15  do
 . . set i=$random(15),char=i
 . . set:i>9 char=$char((i#10)+asciofa)	; ascii value of 'A' is added to the i#10 value resulting in characters 'A-F'
 . . set inp=inp_char
 . set istart=$zut
 . quit:iend<istart
 . set k=$zconvert(inp,"HEX","DEC")
 . set l=$zconvert(k,"DEC","HEX")
 . if inp'=l do
 . . write "FAILED to convert input: ",inp," ",k," ",l,!
 . . quit
 write "Completed",!,!
 quit

; The below routine checks the behavior of %HD and %DH for NULL input.
; Expected behavior: return 0 with default length, which is 1 for %HD and 8 for %DH.
nullvalinp
	write "Checking the behavior of utility functions %HD and %DH when null input is given",!
	set h=$$FUNC^%HD("") write:h'="0" "Failed, output expected is 0 but got ",h,!,!
	set h=$$FUNC^%DH("") write:h'="00000000" "Failed, output expected is 00000000 but got ",h,!
	write "Completed",!,!
	quit

; The below routine checks the behavior of %DH when length value is not specified as part of input.
; Expected behavior: the output has a length of 8
; Note: Input given ensures the computed value to have a length lesser than 8
; 	such that default 8 byte output value length can be observed.
defaultlenval
	write "Verifying default 8 byte output value length of %DH",!
	set h=$$FUNC^%DH(15,)
	write:$length(h)'=8 "Failed, output not 8 digits :",h,!
	write "Completed",!,!
	quit

; The below routine checks the behavior of $ZCONVERT, %DH and %HD for signed input.
; Expected behavior:
; 	$ZCONVERT's DEC to HEX conversion results in appropriate signed hex value
; 	%DH results in appropriate signed hex value (i.e 2's complement) with the length parameter determining the number of leading F's
; 	%HD results in 0 for +ve signed input
; 	%HD results in NULL for -ve signed input
signedvalinp
	write "Checking $ZCONVERT for signed value input",!
	set h=$zconvert("-7295","DEC","HEX")
	write:h'="E381" "Failed, expected output is E381 but got ",h,!
	set h=$zconvert("+7295","DEC","HEX")
	if h'="1C7F" do
	. write "Failed, expected output is 1C7F but got ",h,!,!
	write "Checking conversion utilities %DH and %HD for signed value input",!
	set h=$$FUNC^%DH(-7295,10)
	write:h'="FFFFFFE381" "Failed, expected output is FFFFFFE381 but got ",h,!
	set h=$$FUNC^%DH(+7295,10)
	write:h'="0000001C7F" "Failed, expected output is 0000001C7F but got ",h,!
	set h=$$FUNC^%HD("+E381")
	write:h'="0" "Failed, expected output is 0 but got ",h,!
	set h=$$FUNC^%HD("-E381")
	write:$length(h)'=0 "Failed, expected empty output but got ",h,!,!
	write "Completed",!,!
	quit

; The below routine checks the behavior of $ZCONVERT for input having mixed values like 123X234.
; Conversions checked DEC to HEX, HEX to DEC of +ve value and DEC to HEX of -ve value
; Expected behavior: verifies that the characters before the first invalid character are converted
mixedvalinp
	write "Checking conversion for values such as 18446744073709551615vjj444 and FFFFFFFFFFFFFFFFhhh were only characters before an occurence of invalid character needs to be considered",!
	set inp="18446744073709551615vjj444"
	set expout="18446744073709551615"
	set expnout="8000000000000001"
	set out=$zconvert(inp,"dec","hex")
	set out=out_"hhh"
	set out=$zconvert(out,"hex","dec")
	if out'=expout do
	. write "FAILED to convert inp ",inp," to ",expout," current result ",out,!
	write "Checking conversion of negative decimal value -9223372036854775807aaa expecting 8000000000000001",!
	set inp="-9223372036854775807aaa"
	set out=$zconvert(inp,"dec","hex")
	if out'=expnout do
	. write "FAILED to convert inp ",inp," to ",expnout," current result ",out,!
	write "Completed",!,!
	quit

; The below routine checks the behavior of $ZCONVERT's DEC to HEX and HEX to DEC conversion for maximum 64 bit and 32 bit values.
; Expected behavior: correct conversion verified by observing reproduction of same input value after dec to hex and hex to dec conversion
mxvalinp
	write "Checking DEC to HEX and HEX to DEC conversion of 64 bit value",!
	set maxvalue="9223372036854775807"
	set dtohrslt=$zconvert(maxvalue,"DEC","HEX")
	set htodrslt=$zconvert(dtohrslt,"HEX","DEC")
	write:maxvalue'=htodrslt "FAILED to convert 64 bit maximum value",maxvalue,!
	write "Checking DEC to HEX and HEX to DEC conversion of 32 bit value",!
	set maxvalue="4294967295"
	set dtohrslt=$zconvert(maxvalue,"DEC","HEX")
	set htodrslt=$zconvert(dtohrslt,"HEX","DEC")
	write:maxvalue'=htodrslt "FAILED to convert 32 bit maximum value",maxvalue,!
	write "Completed",!,!
	quit

; The below routine checks the behavior of current %HD to reject negative signed input and null return against the previous implementation results.
; It is necessary to have this check to compare behaviorial similarity from previous to current version.
; Expected behavior: previous and current version of conversion results in NULL output.
hdrejectsignedinput
	write "Checking if -ve signed input is rejected and null is returned",!
	set empty=""
	set inpval="-FFFF"
	set newhdres=$$FUNC^%HD(inpval)
	set prevhdres=$$FUNCPREVHEXTODEC(inpval)
	write:newhdres'=empty "FAILED as conversion of an empty input returned a value ",newhdres,!
	write:newhdres'=prevhdres "FAILED, prev and new value different for empty input string",!
	write "Completed",!,!
	quit

; The below routine checks the behavior of current %DH to be same as previous implementation for a 16 digit input.
correctnessdectohex
	write "Checking correctness of values produced by new utility function %DH by comparing with previous version",!
	set maxval=21474836
	set seed=$zut#maxval
	set:seed=0 seed=maxval
	set inpval=$random(seed)_$random(seed)
	set prevdhres=$$FUNCPREVDECTOHEX(inpval,$length(inpval))
	set newdhres=$$FUNC^%DH(inpval,$length(inpval))
	write:prevdhres'=newdhres "FAILED as conversion from dec to hex resulted in different values for previous and new implementation ",prevdhres," ",newdhres,!
	write "Completed",!,!
	quit

; The below routine checks the behavior of current %HD to be same as previous implementation for a 16 digit input.
correctnesshextodec
	write "Checking correctness of values produced by new utility function %HD by comparing with previous version",!
	set maxval=21474836
	set seed=$zut#maxval
	set:seed=0 seed=maxval
	set inpval=$random(seed)_$random(seed)
	set prevhdres=$$FUNCPREVHEXTODEC(inpval)
	set newhdres=$$FUNC^%HD(inpval)
	write:prevhdres'=newhdres "FAILED as conversion from dec to hex resulted in different values for previous and new implementation ",prevhdres," ",newhdres,!
	write "Completed",!,!
	quit

; The below routine checks the performance of %DH current implementation with previous implemenation.
; Performance check is being done for both 16 digit and 20 digit input.
; $Random is used to compute input values and that values are passed on to the conversion utility. Same procedure is run
; for 2 seconds in a loop keeping track of number of computations done.
; Expected behavior: current version has higher number of computations than the previous version.
compdectohex
	write "Comparing performance of current %DH implementation vs previous %DH implementation for 16 digit values",!
	set interval=2000000
   	set iend=$zut+interval
   	set istart=1
	set ncnt=1
	set seed=21474836 ; hard coded as this is a performance test
   	for  do  quit:iend<istart
   	 . set istart=$zut
	 . set ncnt=$increment(ncnt)
   	 . quit:iend<istart
   	 . set i=$random(seed)_$random(seed)
	 . set k=$$FUNC^%DH(i,)
	; checking previous m implementation
	set iend=$zut+interval
	set istart=1
        set ocnt=1
	for  do  quit:iend<istart
         . set istart=$zut
         . set ocnt=$increment(ocnt)
         . quit:iend<istart
         . set i=$random(seed)_$random(seed)
         . set k=$$FUNCPREVDECTOHEX(i,16)
	write "Performance: current ",ncnt," ","previous ",ocnt,!
	if (ncnt<ocnt) write "FAILED as performance is less than previous implementation ","new count:",ncnt," ","previous count:",ocnt," ",!
	;
	write "Comparing performance of current %DH implementation vs previous %DH implementation for 20 digit values",!
        set iend=$zut+interval
        set istart=1
        set ncnt=1
	; seed and seed2 hardcoded as this is a performance test
	set seed=1844674407
	set seed2=3709551615
        for  do  quit:iend<istart
         . set istart=$zut
         . set ncnt=$increment(ncnt)
         . quit:iend<istart
         . set i=$random(seed)_$random(seed2)
         . set k=$$FUNC^%DH(i,)
        ; checking previous m implementation
        set iend=$zut+interval
        set istart=1
        set ocnt=1
        for  do  quit:iend<istart
         . set istart=$zut
         . set ocnt=$increment(ocnt)
         . quit:iend<istart
         . set i=$random(seed)_$random(seed2)
         . set k=$$FUNCPREVDECTOHEX(i,16)
	write "Performance: current ",ncnt," ","previous ",ocnt,!
        if (ncnt<ocnt) write "FAILED as performance is less than previous implementation ","new count:",ncnt," ","previous count:",ocnt," ",!
	write "Completed",!,!
	quit

; The below routine checks the performance of current version %HD with previous version.
; Performance check is being done for both 14 digit input and 16 digit input as they both lead to different code paths.
; Random is used to compute input value and that value is passed on to the conversion utility. Same procedure is run
; for 2 seconds in a loop keeping track of number of computations done.
; Expected behavior: current version has higher number of computations than the previous version.
comphextodec
	write "Comparing performance of current %HD implementation vs previous %HD implementation with 14 digits",!
	set interval=2000000
   	set iend=$zut+interval
   	set istart=1
	set ncnt=1
	set seed=2147483 ; hard coded as this is a performance test
   	for  do  quit:iend<istart
   	 . set istart=$zut
	 . set ncnt=$increment(ncnt)
   	 . quit:iend<istart
   	 . set i=$random(seed)_$random(seed)
	 . set k=$$FUNC^%HD(i)
	; starting previous m implementation
	set iend=$zut+interval
	set istart=1
        set ocnt=1
	for  do  quit:iend<istart
         . set istart=$zut
         . set ocnt=$increment(ocnt)
         . quit:iend<istart
         . set i=$random(seed)_$random(seed)
	 . set k=$$FUNCPREVHEXTODEC(i)
	write "Performance: current ",ncnt," ","previous ",ocnt,!
	write:(ncnt<ocnt) "FAILED as performance is less than previous implementation ","new count:",ncnt," ","previous count:",ocnt," ",!
	;
	write "Comparing performance of current %HD implementation vs previous %HD implementation 16 digits",!
        set iend=$zut+interval
        set istart=1
        set ncnt=1
	set seed=21474836 ; hard coded as this is a performance test
        for  do  quit:iend<istart
         . set istart=$zut
         . set ncnt=$increment(ncnt)
         . quit:iend<istart
         . set i=$random(seed)_$random(seed)
         . set k=$$FUNC^%HD(i)
        ; starting previous m implementation
        set iend=$zut+interval
        set istart=1
        set ocnt=1
        for  do  quit:iend<istart
         . set istart=$zut
         . set ocnt=$increment(ocnt)
         . quit:iend<istart
         . set i=$random(seed)_$random(seed)
         . set k=$$FUNCPREVHEXTODEC(i)
	write "Performance: current ",ncnt," ","previous ",ocnt,!
        write:(ncnt<ocnt) "FAILED as performance is less than previous implementation ","new count:",ncnt," ","previous count:",ocnt," ",!
	write "Completed",!,!
	quit

; Create a bunch of different literals all with 0's so we get a big string of them to
; potentially throw off the zero leading zero cull in $ZCONVERT() from dec to hex.
; First need to fill our stringpool with zeroes to cause wonky issues with $ZCONVERT().
; Expected behavior: no errors if result length is > 0.
neglengthresult
        set x="0"
        for i=1:1:20 do
        . for j=1:1:19 do
        . . set x=x_x
        . set x="0"
        set y=$zconvert(x,"dec","hex")
	set z=$zconvert(x,"hex","dec")
	zwrite
        quit

;
; Previous implementation copied to below routines before change
;
FUNCPREVDECTOHEX(d,l)
	n isn,i,h,apnd
	s:'$l($g(l)) l=8
	s isn=0,i=0,h="",apnd="0"
	if d["-" do
	. s isn=1,d=$extract(d,2,$length(d))
	if ($l(d)<18) do
	. s h=$$FUNC^%DH(d,l)
	else  do
	. s h=$$CONVERTBASE^%CONVBASEUTIL(d,10,16)
	if (isn&(h'="0")) do
	. s h=$$CONVNEG^%CONVBASEUTIL(h,16)
	. s apnd="F"
	s i=$l(h)
	f  quit:i'<l  s h=apnd_h,i=i+1
	quit h

FUNCPREVHEXTODEC(h)
	quit:"-"=$ze(h,1) ""
	n d s d=$ze(h,1,2) s:("0x"=d)!("0X"=d) h=$ze(h,3,$zlength(h))
	quit:$l(h)<15 $$FUNC^%HD(h)
	s h=$tr(h,"abcdef","ABCDEF")
	quit $$CONVERTBASE^%CONVBASEUTIL(h,16,10)
