VV1DOC38	;VV1DOC V.7.1 -38-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;Logical operator -3.2- (!,&) and concatenation operator (_)
	;     (V1BOC2)
	;
	;       The main purpose of this routine is to validate truth value
	;       interpretation of MUMPS.
	;
	;     Or  (!)
	;
	;     I-150. expratoms are 0 or 1
	;       I-150.1  1!1
	;       I-150.2  1!0
	;       I-150.3  0!1
	;       I-150.4  0!0
	;     I-151. expratoms are numlit
	;       I-151.1  2!1000
	;       I-151.2  -8E-10!0.00E-3
	;       I-151.3  0!9E-12
	;       I-151.4  0.06E+12!-0.007
	;     I-152. expratoms are strlit
	;       I-152.1  "A3B3"!"ABC"
	;       I-152.2  "2E2A"!"2B2A"
	;     I-153. expratoms are empty string
	;     I-154. expratoms are lvn
	;       I-154.1  A!C
	;       I-154.2  B!%D
	;
	;     Nor  ('!)
	;
	;     I-155. expratoms are 0 or 1
	;       I-155.1  1'!1
	;       I-155.2  1'!0
	;       I-155.3  0'!1
	;       I-155.4  0'!0
	;     I-156. expratoms are numlit
	;       I-156.1  2'!1000
	;       I-156.2  -8E-10'!0.00E+6
	;       I-156.3  000000'!9E-12
	;       I-156.4  0.06E+12'!-0.007
	;     I-157. expratoms are strlit
	;       I-157.1  "A3B3"'!"ABC"
	;       I-157.2  "2E2A"'!"2B2A"
	;     I-158. expratoms are empty string
	;     I-159. expratoms are lvn
	;       I-159.1  A'!B
	;       I-159.2  B'!%D
