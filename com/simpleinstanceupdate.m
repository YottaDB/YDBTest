simpleinstanceupdate(wantlong);
		set counterfile="simpleinstanceupdate_counter.txt"
		if (wantlong) set loong=$$^longstr(1600*5)	; large updates
		else  set loong=""				; small updates
		do readcounter
		set ll=counter
		set ul=counter+noofupdates
		for vari=ll+1:1:ul  do
		. set ^GBL(instancename,vari)=vari_loong
		set counter=vari
		do writecounter
		quit    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readcounter	;read the current counter from counterfile
		if ""=$ZSEARCH(counterfile,1) set counter=0 quit
		open counterfile
		use counterfile
		read counter
		use $PRINCIPAL
		close counterfile
		quit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writecounter	;write the counter to counterfile
		open counterfile:(NEWVWERSION)
		use counterfile
		write counter,!
		close counterfile
		quit    

