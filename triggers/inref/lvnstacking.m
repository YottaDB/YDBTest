	; test the stacking of the trigger local variables that are part
	; of the trigger specification
lvnstacking
	do ^echoline
	kill ^fired
	do text^dollarztrigger("tfile^lvnstacking","lvnstacking.trg")
	do file^dollarztrigger("lvnstacking.trg",1)
	set ^a(99)="99 red ballons"
	zwr ^fired(:,1:2)
	do ^echoline
	quit

test
	set ref=$reference
	set x=$increment(^fired($ZTNAme))
	set $piece(^fired($ZTNAme,x),$char(32),1)="$reference="_ref
	if $data(lvn) set $piece(^fired($ZTNAme,x),$char(32),2)="lvn="_lvn
	quit

tfile
	;+^a(lvn=:) -command=S -xecute="do test^lvnstacking set x=lvn,y=$increment(lvn) set (^b(x*10),^c(y))=$ztvalue do test^lvnstacking"
	;+^a(:) -command=S -xecute="do test^lvnstacking"
	;+^a(lvn=:) -command=S -xecute="do test^lvnstacking"
	;+^b(lvn=:) -command=S -xecute="do test^lvnstacking"
	;+^c(:) -command=S -xecute="do test^lvnstacking"
