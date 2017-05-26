time	; given two times and a ratio, calculate the point between the two times
	; i.e. given t1 t2 r return (in absolute time format) t1+r*(t2-t1)
	; the arguments are:
	; t1_abs_file t2_abs_file ratio
	;
	set f1=$P($ZCMDLINE," ",1),f2=$P($ZCMDLINE," ",2),ratio=$P($ZCMDLINE," ",3)
	o f1 u f1 r time1 c f1 u $P
	o f2 u f2 r time2 c f2 u $P
	set d1=$P(time1," ",1),t1=$P(time1," ",2)
	set d2=$P(time2," ",1),t2=$P(time2," ",2)
	;convert date/time to $H
	s d1h=$$FUNC^%DATE(d1),%TM=t1 d %CTN^%H s t1h=%TIM
	s d2h=$$FUNC^%DATE(d2),%TM=t2 d %CTN^%H s t2h=%TIM
	; calculate
	s ressec=((d2h-d1h)*86400)+(t2h-t1h) 	; 86400 seconds in a day
	s ressec=ressec*ratio+(d1h*86400)+t1h	; absolute time
	s ressec=ressec-(ressec#1) 		; round down to next second
	s f="timecalc.txt" o f:newversion u f w ressec c f 
	s resd=ressec\86400			; result DAY
	s rest=ressec#86400			; result TIME
	;w time1," ## ",time2," ## ",ratio," ## -> ## "
	w $ZDATE(resd_","_rest,"DD-MON-YEAR 24:60:SS"),!
	q
