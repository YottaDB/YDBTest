gtm7292
	; Creates a number of globals to be used for mupip size testing
	; Fills the database in a random-ish manner to try to get a mix
	; of record counts among index blocks
	do createGlobal("^a",100000)
	do createGlobal("^b",500)
	do createGlobal("^c",10000)
	do createGlobal("^c2",8000)
	do createGlobal("^c3",15000)
	do createGlobal("^d",500)
	write !
	quit

createGlobal(gbl,gSize)
	write "Filling ",gbl," "
	set (j,k)=1
	for i=1:1:gSize set @gbl@(k)=$justify(k,40) set tmp=k,k=(j+k)#gSize,j=tmp
	quit
