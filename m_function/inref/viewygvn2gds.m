;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
viewygn2gds	;* Test cases for $VIEW("YGVN2GDS") and $VIEW("YGDS2GVN")
	set $ztrap="goto errorAndCont^errorAndCont"
	write "# Test simple numeric subscripts",!
	set x=$VIEW("YGVN2GDS","^A(1,2)")  zwrite x
	set y=$VIEW("YGDS2GVN",x)  zwrite y

	write "# Test numeric + string subscripts",!
	set x=$VIEW("YGVN2GDS","^A(1,""abcd"")")  zwrite x
	set y=$VIEW("YGDS2GVN",x)  zwrite y

	write "# Test numeric + string subscripts with collation 1 way but not the other way",!
	set x=$VIEW("YGVN2GDS","^A(1,""abcd"")",1)  zwrite x
	set y=$VIEW("YGDS2GVN",x)  zwrite y

	write "# Test numeric + string subscripts with collation both ways",!
	set x=$VIEW("YGVN2GDS","^A(1,""abcd"")",1)  zwrite x
	set y=$VIEW("YGDS2GVN",x,1)  zwrite y

	write "# Test a few numeric subscripts",!
	set x=$VIEW("YGVN2GDS","^A(1.2345678901234567)")  d print(x)
	set y=$VIEW("YGDS2GVN",x)  zwrite y

	set x=$VIEW("YGVN2GDS","^A(1.23456789012345678)")  d print(x)
	set y=$VIEW("YGDS2GVN",x)  zwrite y

	write "# Test a few invalid or non-canonical numeric subscripts",!
	write $VIEW("YGVN2GDS","^A(1.23456789012345670)")
	write $VIEW("YGVN2GDS","^A(1.234567890123456789)")
	write $VIEW("YGVN2GDS","^A(1.2345678901234567890)")
	write $VIEW("YGVN2GDS","^A(1E3abcd)")

	write "# Test that numeric subscripts inside double-quotes are treated as string subscripts",!
	set x=$VIEW("YGVN2GDS","^A(1)")  zwrite x
	set y=$VIEW("YGDS2GVN",x)  zwrite y
	set x=$VIEW("YGVN2GDS","^A(""1"")")  zwrite x
	set y=$VIEW("YGDS2GVN",x)  zwrite y

	write "# Test $C() usages in string subscripts",!
	set x=$VIEW("YGVN2GDS","^A("""_$c(0,40,1)_""")")  zwrite x
	set y=$VIEW("YGDS2GVN",x)  zwrite y
	quit
print(x) ;
	zwrite x
	write $zlength(x),!
	quit
