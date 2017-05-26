expr2	; Test the optional second argument in $ASCII
;	File modified by Hallgarth on  1-MAY-1986 11:57:57.57
	s str=""
	f i=1:1:10 s str=str_i w "str= ",str,! d lab1
	q
lab1	s str1="w $c(",a="$a(str,",rp=")"
	f k=1:1:$l(str) s str1=str1_a_k_rp q:k=$l(str)  s str1=str1_","
	s str1=str1_"),!"
	x str1
	q
