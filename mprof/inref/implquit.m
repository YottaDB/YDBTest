implquit	; To test the time counting of quit (implicit or explicit) statements
		; since the time in an explicit quit will never be too much, I'll test this using 
		; implicit quits  we need to see that the line "implquit","implq",1 has non-zero 
		; time logged 
		;
		; If zero time is reported for the  implicit quit line (which is ^TRACE("ZMPROF16","implquit","implq",1))
		;  first check if it's due to the server's high speed by increasing the time explq2 takes.
		;
		K ^TRACE
		VIEW "TRACE":1:"^TRACE(""ZMPROF16"")"
		d explq1
		d implq
		VIEW "TRACE":0:"^TRACE(""ZMPROF16"")"
		w "The implicit quit line:",!
		s xn="^TRACE(""ZMPROF16"",""implquit"",""implq"",1)"
		s x=@xn
		f i=1:1:4 s xi="x"_i s @xi=$P(x,":",i)	; chop it up
		if x2=0 w "TEST-E-ZEROTIME ",xn," should have had non-zero time, but it has zero time: ",@xn,! zwr ^TRACE
		if x2>0 w "has user time greater than 0. PASS",!,@xn,!
		q
explq1		;	
		f i=1:1:10000 s xx=$J(i,100)
		q
explq2		;	
		f i=1:1:200000 s xx=$J(i,100)
		q
implq		;
		d explq2
