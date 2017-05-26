ebmuldiv(verbose)	; test extended precision multiply & divide
	New (verbose)
	Do begin^header($TEXT(+0))

	If verbose Write "PER tests:",!

; Test for PER 002137:
	Set errstep=errcnt
	; This pair of values was discovered by a customer to exercise a very
	; seldom-used path in the division algorithm.
	do div(9.759,(2050/15))
	If errstep=errcnt Write "   PASS - PER 002137",!
; End of PER 002137:

; Test for PER 002412:
	Set errstep=errcnt
	Set a=99995*99995/99995		; Caused an assert failure.
	Do ^examine(a,99995,"PER 002412 -  99995*99995/99995")
	If errstep=errcnt Write "   PASS - PER 002412",!
; End of PER 002412:

; Test for PER 002541
	s errstep=errcnt
	s a=320019.65*21910.809876/21910.809876
	d ^examine(a,320019.65,"PER 2541 - 320019.65*21910.809876/21910.809876")
	if errstep=errcnt w "   PASS - PER 002541",!
;End of PER 002541

	If verbose Write "Division tests:",!

	Set errstep=errcnt

	; This pair of values test whether the division operation preserves
	; all 18 digits.
	do div(800000000000000002,2)

	; This code is from one of our other test suites and exercises a very
	; seldom-used path in our integer division algorithm.
	Set d=33554432
	If verbose Write !
	For i=1:1:7  Do   Set d=d\16
	.  If verbose Write d,"  ",d#16+1,!
	.  Do ^examine(d,$$FUNC^%HD("2"_$EXTRACT("000000",1,7-i)),"d="_d)
	.  If i<7 Do ^examine(d#16+1,1,"d#16+1 where d="_d)
	.  If i=7 Do ^examine(d#16+1,3,"d#16+1 where d=2")

	If errstep=errcnt Write "   PASS - Division tests",!

	Set errstep=errcnt

	If verbose Write !,"Multiplication tests:",!

	; These tests exercise the 18-digit multiplication algorithm to ensure
	; no accuracy is lost.

	; Each value is represented to 18 digits as two 9-digit quantities of
	; which the high-order quantity is normalized.  Thus, if the two numbers
	; to be multiplied are
	;	v = (v1,v0) = v1*10**9 + v0 and
	;	u = (u1,u0) = u1*10**9 + u0,
	; then 10**8 <= v1 < 10**9 and 10**8 <= u1 < 10**9 and the product
	; before scaling will be:
	;	p = (p1,p0) = v1*u1*10**18 + (v1*u0 + v0*u1)*10**9 + v0*u0,
	; truncated to 18 digits.  Each of the pairs of values chosen below
	; is such that the high-order quantity in its representation is as
	; small as possible.  Because we know that
	;	10**8 <= v1,u1 < 10**9 and
	;	0     <= v0,u0 < 10**9,
	; we can show that p could be as small as 10**34 (v1,u1 = 10**8 and
	; v0,u0 = 0) before scaling and truncation.  In addition, because
	; the values of v0 and u0 could be as high as (10**9 - 1)**2 or
	; (10**18 - 2*10**9 + 1) which is between 10**17 and 10**18 and
	; which would affect the least significant digit of a value that was
	; on the order of 10**34.  In fact, we find that this is true as
	; long as the product of the two low-order 9-digit values is >= 10**17.
	
	; (100 000 000  900 000 000) ** 2
	do mult(1000000009,1000000009)

	; (100 000 000  999 999 999) ** 2
	do mult(100000000999999999,100000000999999999)

	; (100 000 000  200 000 000) * (100 000 000  500 000 000)
	do mult(1000000002,1000000005)

	; (100 000 000  500 000 000) * (100 000 000  200 000 000)
	do mult(1000000005,1000000002)

	; The following pairs of values are based on an approximation of
	; the square root of 10 which is .316227766... (to 9 digits).
	do mult(100000000316227766,100000000316227766)
	do mult(100000000316227766,100000000316227767)
	do mult(100000000316227767,100000000316227766)
	do mult(100000000316227767,100000000316227767)

	; Repeat the tests above, scaling down the operand size.
	do mult(1.000000009,1.000000009)
	do mult(1.00000000999999999,1.00000000999999999)
	do mult(1.000000002,1.000000005)
	do mult(1.000000005,1.000000002)
	do mult(1.00000000316227766,1.00000000316227766)
	do mult(1.00000000316227766,1.00000000316227767)
	do mult(1.00000000316227767,1.00000000316227766)
	do mult(1.00000000316227767,1.00000000316227767)

	If errstep=errcnt Write "   PASS - Multiplication tests",!

	Do end^header($TEXT(+0))
	quit

div(dividend,divisor)
	set quotient=dividend/divisor
	set product=divisor*quotient
	If verbose Write dividend,"/",divisor," = ",quotient,!

	; Now multiply it back to determine how close we can come to the
	; original value by applying the inverse operation.  The operation
	; definitions are such that the computed delta value should always
	; be non-negative; otherwise, there's a bug in one of the algorithms.
	If verbose Write divisor,"*",quotient," = ",product,!
	set delta=dividend-product
	If verbose write "round-trip delta = ",delta," (",(delta/dividend)*100,"%)",!
	If delta<0 Do
	.  If verbose Write " ERROR - round-trip delta should be >=0",!
	.  Do ^examine(delta,"0",dividend_"/"_divisor)
	If verbose Write !
	quit

mult(multcand,multplier)
	set product=multcand*multplier
	set quotient=product/multplier
	If verbose Write multcand,"*",multplier," = ",product,!

	; Now divide it back to determine how close we can come to the
	; original value by applying the inverse operation.  The operation
	; definitions are such that the computed delta value should always
	; be non-negative; otherwise, there's a bug in one of the algorithms.
	If verbose Write product,"/",multplier," = ",quotient,!
	set delta=multcand-quotient
	If verbose Write "round-trip delta = ",delta," (",(delta/multcand)*100,"%)",!
	If delta<0 Do
	.  If verbose Write " ERROR - round-trip delta should be >=0",!
	.  Do ^examine(delta,"0",multcand_"*"_multplier)
	If verbose Write !
	quit
