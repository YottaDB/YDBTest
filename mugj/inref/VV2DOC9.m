VV2DOC9	;VV2DOC V.7.1 -9-;TS,VV2DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-II
	;
	;     II-162. Lower case letter pattern code "n"
	;        II-162.1  repcount
	;        II-162.2  its mapping
	;        II-162.3  lvn?5c
	;     II-163. Lower case letter pattern code "u"
	;        II-163.1  repcount
	;        II-163.2  its mapping
	;        II-163.3  lvn?5c
	;     II-164. Lower case letter pattern code "l"
	;        II-164.1  repcount
	;        II-164.2  its mapping
	;        II-164.3  lvn?5c
	;     II-165. Lower case letter pattern code "a"
	;        II-165.1  repcount
	;        II-165.2  its mapping
	;        II-165.3  lvn?5c
	;     II-166. Lower case letter pattern code "e"
	;        II-166.1  repcount
	;        II-166.2  its mapping
	;        II-166.3  lvn?5c
	;
	;
	;$NEXT and $ORDER
	;     (VV2NO)
	;
	;       Although the usage of negative numeric subscripts is restricted
	;      in portability requirements 2.2.3, negative numeric subscripts
	;      are validated in $NEXT.
	;
	;     $NEXT(glvn)
	;
	;     II-167. Sequence from -1 when glvn is lvn
	;        II-167.1  subscript is a string
	;        II-167.2  subscript is one character (all graphic characters)
	;     II-168. Sequence from -1 when glvn is gvn
	;        II-168.1  subscript is a string
	;        II-168.2  subscript is one character (all graphic characters)
	;
	;     $ORDER(glvn)
	;
	;     II-169. Sequence from empty string when glvn is lvn
	;        II-169.1  subscript is a string
	;        II-169.2  subscript is one character (all graphic characters)
	;     II-170. Sequence from empty string when glvn is gvn
	;        II-170.1  subscript is a string
