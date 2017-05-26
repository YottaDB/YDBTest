	; re-use components or replictrigger for the test
trig2notrig
	do ^echoline
	do item^dollarztrigger("tfile^replictrigger","replictrigger.trg.trigout")
	do item^dollarztrigger("tfile^trig2notrig","trig2notrig.trg.trigout")
	do updategbla^replictrigger
	do updategblb^replictrigger
	do updategblc^replictrigger
	do ^echoline
	quit

	; dummy update
initiator
	do ^echoline
	set ^a="dummy update to send across the to replicating instance"
	quit

	; kill the dummy update
kill
	kill ^a
	quit

tfile
	;; need to send ZTWOrmhole over to secondary to ensure that it is stripped
	;+^a(:) -command=S -xecute="set a=$ZTWOrmhole"
	;-^b(subs=:) -command=S -xecute="do tlevelzero^replictrigger"
	quit
