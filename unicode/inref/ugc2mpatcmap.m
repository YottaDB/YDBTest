ugc2mpatcmap ; Tests mapping of Unicode General Categories (UGC) to M Patcodes (MPATC)
	d showpatcsc("Ā","Lu","A") ; 0100
	d showpatcsc("ā","Ll","A") ; 0101
	d showpatcsc("ǅ","Lt","A") ; 01C5
	d showpatcsc("ʻ","Lm","A") ; 02BB
	d showpatcsc("ٴ","Lo","A") ; 0674
	d showpatcsc("̀̀ ","Mn","P") ; 0300
	d showpatcsc("ो","Mc","P") ; 094B
	d showpatcsc("҈","Me","P") ; 0488
	if $ZPATN="UTF-8"  d showpatcsc("०","Nd","N") ; 0966
	else  d showpatcsc("०","Nd","A") ; 0966
	d showpatcsc("ᛮ","Nl","A") ; 16EE
	d showpatcsc("௰","No","A") ; 0BF0
	d showpatcsc("⁀","Pc","P") ; 2040
	d showpatcsc("‐","Pd","P") ; 2010
	d showpatcsc("⁽","Ps","P") ; 207D
	d showpatcsc("⁆","Pe","P") ; 2046
	d showpatcsc("‘","Pi","P") ; 2018
	d showpatcsc("’","Pf","P") ; 2019
	d showpatcsc(";","Po","P") ; 037E
	d showpatcsc("϶","Sm","P") ; 03F6
	d showpatcsc("¥","Sc","P") ; 00A5
	d showpatcsc("˃","Sk","P") ; 02C3
	d showpatcsc("؎","So","P") ; 060E
	d showpatcsc(" ","Zs","P") ; 2000
	d showpatcscp("2028","Zl","C"); 2028
	d showpatcscp("2029","Zp","C"); 2029
	d showpatcscp("009F","Cc","C"); 009F
	d showpatcscp("0600","Cf","C"); 0600

	q
showpatcsc(char,ugc,empatc) ; show the M patcodes for a character
	s codepoint=$a(char)
	w "UGC:",ugc," sample codepoint:0x",codepoint," expected MPATC:",empatc," actual MPATC:"
	i char?.A  w "A "  s amptc="A"
	i char?.N  w "N "  s amptc="N"
	i char?.P  w "P "  s amptc="P"
	i char?.C  w "C "  s amptc="C"
	i empatc=amptc w "PASSED "
	e   w "FAILED "
	w !
	q
showpatcscp(codepoint,ugc,empatc) ; show the M patcodes for a codepoint
	s char=$c($$FUNC^%HD(codepoint))
	w "UGC:",ugc," sample codepoint:0x",codepoint," expected MPATC:",empatc," actual MPATC:"
	i char?.A  w "A "  s amptc="A"
	i char?.N  w "N "  s amptc="N"
	i char?.P  w "P "  s amptc="P"
	i char?.C  w "C "  s amptc="C"
	i empatc=amptc w "PASSED "
	e   w "FAILED "
	w !
	q



