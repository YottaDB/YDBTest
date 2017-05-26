longstr(x) ; create a long string (of length x)
	new (x)
	;do c33122
	do calpha
	set res="",$PIECE(res,stri,x\(cspan))=stri
	if x'=$l(res) set $PIECE(res,"",2)=$EXTRACT(stri,1,x-$LENGTH(res))
	quit res
calpha	; all alphabetical characters (for ease of string manipulation)
	set stri="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	set cspan=$l(stri)
	quit

c33122	; all characters between $C(33) and $C(122)
	;the string will be $C(33)$C(34)...$C(122)$C(33)$C(34...)
	;i.e. !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz
	set cfirst=33	; !
	set clast=122	; z
	set cspan=clast-cfirst+1	; length of one round
	set stri=""
	for c=cfirst:1:clast set stri=stri_$C(c)
	quit
