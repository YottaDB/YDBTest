	; update the same 35 keys of a global, in a sequence, i.e.:
	; ^GBLA( 1)=val1
	; ^GBLA( 2)=val1
	; ...
	; ^GBLA(35)=val1
	; ^GBLA( 1)=val2
	; ^GBLA( 2)=val2
	; ...
	; ^GBLA(35)=val2
	; ^GBLA( 1)=val3
	; ^GBLA( 2)=val3
	; ...
	; ^GBLA(35)=val3
	; ^GBLA( 1)=val4
	; ^GBLA( 2)=val4
	; ...
	; The values (val1, val2, ...) should be such that each global fits one block
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
simplegblupd(count)	;count shows how many set operations will be done
	set statfile="update_statm.txt"
	do readstat
	set maxgblsubs=35
	set pnt=startpnt
	set val=startval
	for vari=0:1:(count-1)  do
	. if (maxgblsubs=pnt) set val=val+1
	. set pnt=((vari+startpnt)#maxgblsubs)+1
	. set ^GBLA(pnt)=val_"_"_$$^longstr(980)
	. write "set ^GBLA(",pnt,")=",val,"_<...>",!
	do writestat
	quit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readstat	;read the current stat from statfile
	if ""=$ZSEARCH(statfile,1) set startpnt=0,startval=1 quit
	open statfile
	use statfile
	read line
	use $PRINCIPAL
	close statfile
	if (""=line) set startpnt=0,startval=1 quit
	set startpnt=$PIECE(line,",",1)
	set startval=$PIECE(line,",",2)
	quit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writestat	;write the stat to statfile
	open statfile:(NEWVWERSION)
	use statfile
	write pnt,",",val,!
	use $PRINCIPAL
	close statfile
	quit
