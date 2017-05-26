	; changes to replic trigger also affect trig2notrig.m
replictrigger
	do ^echoline
	do setup
	do updategbla
	do updategblb
	do updategblc
	do updategble
	do ^echoline
	quit

	; setup - load the triggers and print them
setup
	do item^dollarztrigger("tfile^replictrigger","replictrigger.trg.trigout")
	do text^dollarztrigger("ztwotfile^replictrigger","ztworeplictrigger.trg")
	do all^dollarztrigger
	quit

	; KILL ^fired, SET it to ensure that the receiver also sees the KILL
cleanup
	set ^fired="suicide"
	kill ^fired
	quit

	; testing SET, check that ztwormhole does not show up in the journal
updategbla
	write "Updates to ^a in a transaction",!
	set $ZTWOrmhole="Updates to ^a in a transaction do not show up without replication"
	TSTART ()
	for i=1:1:10 set $piece(^a(i),",",1)=i,$piece(^a(i),",",2)=i*5
	do writefired
	TCOMMIT
	write "Updates to ^a outside of a transaction",!
	set $ZTWOrmhole="Updates to ^a outside of a transaction do not show up without replication"
	for i=11:1:12 set $piece(x,",",1)=i,$piece(x,",",2)=i*5,^a(i)=x
	do writefired
	if $data(^a)  zwr ^a
	if $data(^b)  zwr ^b
	if $data(^c)  zwr ^c
	if $data(^d)  zwr ^d
	if $data(^e)  zwr ^e
	do ^echoline
	quit

updategblb
	write "ZKILL to ^b in a transaction",!
	set $ZTWOrmhole="ZKILLs to ^b in a transaction do not show up without replication"
	TSTART ()
	for i=1:2:10 zkill ^b(i)
	do writefired
	TCOMMIT
	if $data(^a)  zwr ^a
	if $data(^b)  zwr ^b
	if $data(^c)  zwr ^c
	if $data(^d)  zwr ^d
	if $data(^e)  zwr ^e
	do ^echoline
	quit

updategblc
	write "KILL to ^c in a transaction",!
	;set $ZTWOrmhole="ZTKILLs to ^c in a transaction do not show up without replication"
	set $ZTWOrmhole="KILLs to ^c in a transaction do not show up without replication"
	TSTART ()
	kill ^c
	do writefired
	TCOMMIT
	if $data(^a)  zwr ^a
	if $data(^b)  zwr ^b
	if $data(^c)  zwr ^c
	if $data(^d)  zwr ^d
	if $data(^e)  zwr ^e
	do ^echoline
	quit

updategble
	write "Updates to ^e outside of a transaction",!
	do file^dollarztrigger("ztworeplictrigger.trg",1)
	set $ZTWOrmhole="Updates to ^e in a transaction do not show up without replication"
	for i=2:2:10  set $piece(^e(i),",",1)=i,$piece(^e(i),",",3)=i*3
	set x=^e(12) set $piece(x,",",1)=i,$piece(x,",",3)=i*3 set ^e(12)=x
	do writefired
	;
	;
	;
	write !,"Updates to ^e inside a transaction",!
	TSTART ()
	set $ZTWOrmhole="Updates to ^e at the start of a transaction do not show up without replication"
	for i=1:2:5  set $piece(^e(i),",",1)=i,$piece(^e(i),",",3)=i*3
	for i=7:2:7  set $piece(^e(i),",",1)=i,$piece(^e(i),",",3)=i*3
	set $ZTWOrmhole="Updates to ^e show up in the middle of a transaction do not show up without replication"
	for i=9:2:10  set $piece(^e(i),",",1)=i,$piece(^e(i),",",3)=i*3
	; push the MAX ZTWOrmhole through the journal file
	set $ZTWOrmhole=$JUSTIFY("Updates to ^e should show up AGAIN in journal for replication only",15872)
	set x=^e(11) set $piece(x,",",1)=i,$piece(x,",",3)=i*3 set ^e(11)=x
	do writefired
	TCOMMIT
	;
	write !,"Kills of fictitious ^e variables should not show in journals even with replication",!
	zkill ^e(25)
	kill ^f
	write !,"Kills of fictitious ^e variables inside a transaction should not show in journals even with replication",!
	TSTART ()
	zkill ^e(50)
	kill ^y
	do writefired
	TCOMMIT
	;
	;
	write !,"Kills outside transaction ",!
	set $ZTWOrmhole="1 Fires for ZKills to ^e but not Kills outside a transaction do not show up without replication"
	for i=5:1:6 zkill ^a(75,i,i*5,i*3)
	set $ZTWOrmhole="1 Fires for ZKills to ^e but not Kills outside a transaction do not show up without replication NO SHOW"
	for i=5:1:6 kill ^a(75,i,i*5)
	do writefired
	;
	set $ZTWOrmhole="2 Fires for ZKills to ^e but not Kills outside a transaction do not show up without replication NO SHOW"
	for i=7:1:8 kill ^a(75,i,i*5)
	set $ZTWOrmhole="2 Fires for ZKills to ^e but not once the variables are already KILLed NOW SHOW"
	for i=7:1:8 zkill ^a(75,i,i*5,i*3)
	do writefired
	;
	;
	write !,"Kills inside transaction ",!
	;
	TSTART ():serial
	;	This first set is somewhat distracting.  I am 
	;		ZKILL'ing ^a(75,i,:)
	;		KILL'ing ^a(75,i,:,:)
	;	For this to work correctly, I have to ZKILL first and then KILL. Otherwise ZKILL would not fire
	;
	; Restore the original, we should NOT see ZTWOrmhole for this entry duplicated in the replicated journal
	set $ZTWOrmhole="Fires for ZKills to ^e but not Kills inside a transaction do not show up without replication"
	set i=9 zkill ^a(75,i,i*5)
	set $ZTWOrmhole="See this is a NO SHOW"
	set i=9 kill ^a(75,i,i*5,i*3)
	set $ZTWOrmhole="Fires for ZKills to ^e but not Kills inside a transaction do not show up without replication"
	set i=10 zkill ^a(75,i,i*5)
	set $ZTWOrmhole="See this is a NO SHOW"
	set i=10 kill ^a(75,i,i*5,i*3)
	do writefired
	TCOMMIT
	;
	TSTART ():serial
	;	This second set is somewhat distracting.  I am 
	;		ZKILL'ing ^a(75,i,:,:)
	;		KILL'ing ^a(75,i,:)
	;	For this to work correctly, I have to ZKILL first and then KILL. Otherwise ZKILL would not fire
	;
	; In this sequence, we change ZTWOrmhole several times during the transaction (A -> B -> A) to show that
	; ZTWOrmhole is recorded everytime it changes AND a trigger uses it
	; Restore the original, we should NOT see ZTWOrmhole for this entry duplicated
	set $ZTWOrmhole="Fires for ZKills to ^e but not Kills inside a transaction do not show up without replication"
	set i=1 zkill ^a(75,i,i*5,i*3)
	set $ZTWOrmhole="See this is a NO SHOW"
	set i=1 kill ^a(75,i,i*5)
	set $ZTWOrmhole="Fires for ZKills to ^e but not Kills inside a transaction do not show up without replication"
	set i=2 zkill ^a(75,i,i*5,i*3)
	set $ZTWOrmhole="See this is a NO SHOW"
	set i=2 kill ^a(75,i,i*5)
	;
	; Change ZTWOrmhole in the middle of transaction and then restore it to see the original duplicated with a UZTWORM entry
	set $ZTWOrmhole="Changes to ztwormhole in the middle of a transaction do not show up without replication"
	set i=3 zkill ^a(75,i,i*5,i*3)
	set $ZTWOrmhole="Fires for ZKills to ^e but not Kills inside a transaction do not show up without replication"
	set i=4 zkill ^a(75,i,i*5,i*3)
	for i=3:1:4 kill ^a(75,i,i*5)
	do writefired
	TCOMMIT
	;
	kill ^a(75)
	;
	;
	if $data(^a)  zwr ^a
	if $data(^b)  zwr ^b
	if $data(^c)  zwr ^c
	if $data(^d)  zwr ^d
	if $data(^e)  zwr ^e
	do ^echoline
	quit

needwrite
	if $tlevel'=$ztlevel quit
writefired
	if $data(^fired) zwrite ^fired
	kill ^fired
	quit

	; cause restarts in the trigger routine
tlevelzero
	if $trestart<2 trestart
	quit

fired
	set ref=$reference
	set x=$increment(^fired($ZTNAme,$trestart,$ztriggerop))
	set x=$increment(^fired($ZTNAme,$trestart,$ztriggerop,ref))
	quit

tfile
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; SET & ZTRigger
	;+^a(subs=:) -command=S -xecute="do fired^replictrigger set (^c(subs),^b(subs))=$ZTVAlue ztrigger ^azt" -name=setCB
	;+^a(subs=:) -command=S -xecute="do fired^replictrigger set ^d(subs)=$ZTVAlue ztrigger ^azt" -name=setD
	;+^a(subs=:) -command=S -xecute="do fired^replictrigger set ^e(subs)=$ZTVAlue ztrigger ^azt" -name=setE
	;+^azt      -command=ZTR -xecute="do fired^replictrigger do needwrite^replictrigger" -name=ztrA
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; ZKILLs
	;+^b(subs=:) -command=K,ZK -xecute="do fired^replictrigger zkill ^a(subs)" -name=zkillAC
	;+^b(subs=:3;6:) -command=K,ZK -xecute="do fired^replictrigger zkill ^d(subs)" -name=zkillD
	;+^b(subs=:) -command=S -xecute="do fired^replictrigger do tlevelzero^replictrigger" -name=restart
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; ZTK, but for now KILL only
	;;+^c -command=ZTK -xecute="do fired^replictrigger kill ^b,^e set ^b=76" -name=ztkillBEsetB
	;+^c -command=K -xecute="do fired^replictrigger kill ^b set ^b=76" -name=killBsetB
	quit

ztwotfile
	;;load a trigger that will make $ztwormhole show up in the journal
	;+^e(:) -command=S -xecute="do fired^replictrigger set a=$ZTWOrmhole" -name=touchZTWO
	;+^e(:) -command=S -xecute="do fired^replictrigger set ^a(55,$incr(^a(55,""count"")))=$ztva set target=""^a(75,""_$ztva_"")"" set @target=$incr(^a(75,""count""))" -name=setA
	;+^a(75,:,:)   -command=K,ZK -xecute="do fired^replictrigger" 	-name=a75x2
	;+^a(75,:,:,:) -command=K,ZK -xecute="do fired^replictrigger" 	-name=a75x3
	;+^a(75,:,:)   -command=ZK   -xecute="set a=$ZTWOrmhole"	-name=a75x2ztwo
	;+^a(75,:,:,:) -command=ZK   -xecute="set a=$ZTWOrmhole"	-name=a75x3ztwo
	quit
