errcont;
	if $tlevel trollback
	new unix,us,savestat,mystat,prog,line,newprog
	set unix=$ZVersion'["VMS"
	if unix SET us="errcont" 
	else  SET us="ERRCONT"
	; if it's us we're done
	if $P($P($zstatus,",",2,2),"^",2,2)=us zshow "*" halt	
	SET ^errcnt=$GET(^errcnt)+1
	w "Error Number=",^errcnt,!
	SET savestat=$zstatus
	SET mystat=$P(savestat,",",2,100)
	SET prog=$P($zstatus,",",2,2)
	SET line=$P($P(prog,"+",2,2),"^",1,1)
	SET line=line+1
	SET newprog=$P(prog,"+",1)_"+"_line_"^"_$P(prog,"^",2,3)
	W "STAT=",mystat,!
	SET newprog=$ZLEVEL_":"_newprog
	ZGOTO @newprog
