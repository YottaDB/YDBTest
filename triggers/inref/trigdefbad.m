trigdefbad
	set $ETRAP="goto errhandler"
	set ^a($increment(^a))=^a
	quit

errhandler
	set zt=$piece($zstatus,",",3,99)
	if zt["#LABEL" set $extract(zt,$length(zt))="##FILTERED##"
	write zt,!
	halt

init
	do text^dollarztrigger("tfile^trigdefbad","trigdefbad.trg")
	do file^dollarztrigger("trigdefbad.trg",1)
	do all^dollarztrigger
	quit

tfile
	;+^a(acn=:) -commands=SET -xecute="set ^a(acn,acn)=$ztval"
