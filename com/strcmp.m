strcmp	; Compare two strings -- call with str1 and str2 as command line arguments
	; result is -1 if str1 < str2
	;	     0 if str1 = str2
	;	     1 if str1 > str2
	; Note: comparing strings with numbers uses "]]" ordering
	;
        s inp=$ZCMDLINE
        s str1=$P(inp," ",1),str2=$P(inp," ",2)
	i str1=str2 s cmp=0
	e  i str1]]str2 s cmp=1
	e  s cmp=-1
        u 0 w cmp,!
	q
	
