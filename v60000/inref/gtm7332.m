;
; See how many exponentized values are screwed up (GTM-7332). Versions of op_exp (exponents) prior to
; V6.0-000 had an issue where results from exponentiation would create the correct numberic value but
; fail to set the mvtype flags correctly - specifically - failed to set MV_INT for GT.M pseudo-integer
; types (values that fit pic 999999.999). Testing for these broken types can be done with (x/1)'=x.
; Note this test also includes an accuracy test by squaring the sqrt value and rounding it to the same
; form the original base number had then comparing them.
;
; It is not possible to test all numerics so we try to take a representative sample of numeric types 
; with some concentration on the areas that were broken. At the time of this fix, V990 fails this test
; creating over 200 broken values before i reaches 6.3
;
; Test two ranges of low and high numbers.
;
	Set startlow=0.0001
	Set incrlow=0.0001
	Set endlow=100
	Set startmid=999000
	Set incrmid=1999
	Set endmid=3000000000
	Set starthigh=100000000000000000
	Set incrhigh=100000000000000000
	Set endhigh=100000000000000000000000
	Set expcnt=0
	Set brokephasemax=200	; No need to flood 
	Set broke=0
	Set lead0("0")=1	; Define chars to stop searching for significant digits
	Set lead0(".")=1
	Write !,"Starting low range test",!!
	Do runtst(startlow,incrlow,endlow,0)
	Write !,"Starting mid range test",!!
	Do runtst(startmid,incrmid,endmid,0)
	Write !,"Starting high range test",!!
	Do runtst(starthigh,incrhigh,endhigh,1)
	Write:(0'=broke) !,"FAIL - Total of ",broke," broken exponent values out of ",expcnt," evals - test fails",!
	Write:(0=broke) !,"PASS - Total expressions tested: ",expcnt,!
	Quit

;
; Test a given range to see if find bogus 
;
runtst(start,incr,end,noresquare)
	New i,brokesqrt,brokesqrd,brokeequ,sqrt,sqrd,sqrdcmp,decimals,brokephase,expphasecnt,strtexpcnt
	Set strtexpcnt=expcnt
	Set (brokephase,expphasecnt)=0
	For i=start:incr:end Do
	. Set (brokesqrt,brokesqrd,brokeequ)=0
	. Set expcnt=expcnt+1
	. Set expphasecnt=expphasecnt+1
	. Set sqrt=i**.5
	. Set sqrd=sqrt**2
	. Set:((sqrt/1)'=sqrt) brokesqrt=1	; This value is broken
	. Set:((sqrd/1)'=sqrd) brokesqrd=1
	. Set decimals=$Find(i,".")		; See if value has a decimal point
	. Set sqrdcmp=$FNumber(sqrd,"",$Select((0<decimals):$ZLength(i)-decimals+1,1:0))+0	; Round to same lvl as original value
	. Set:('noresquare&(sqrdcmp'=i)) brokeequ=1
	. Do:(brokesqrt!brokesqrd!brokeequ)
	. . Set broke=broke+1
	. . Set brokephase=brokephase+1
	. . Write:('noresquare) "Base ",i,?15,"sqrt: ",sqrt,?40,$Select(brokesqrt:"(broke)",1:""),?50,"sqrt**2: ",sqrd,?80,$Select(brokesqrd:" (broke)",1:"")
	. . Write:(noresquare) "Base ",i,?30,"sqrt: ",sqrt,?55,$Select(brokesqrt:"(broke)",1:""),?65,"sqrt**2: ",sqrd,?95,$Select(brokesqrd:" (broke)",1:"")
	. . Write:('noresquare&brokeequ) ?90,"(Broke base'=(sqrt**2) ",sqrdcmp,")"
	. . Write !
	. . View:(brokesqrt) "LVDMP":"sqrt"
	. . View:(brokesqrd) "LVDMP":"sqrd"
	. . Do:(brokephase>brokephasemax)
	. . . Write "Exceeded broken max (",brokephasemax,") - aborting further tests in this range",!
	. . . ZGoto -4	      ; Effectively return to caller
	Write:(0'=brokephase) !,"Total of ",brokephase," broken exponents this phase out of a total of ",expphasecnt," - exprs tested: start: ",start,"  incr: ",incr,"  end: ",end,!!
	Write:(0=brokephase) "PASS - phase complete no errors (",expcnt-strtexpcnt," base vars tested this phase)",!
	Quit
