REVSORT(file)	;M Utility;Reverse sort a given file
	New revfile,index,revindex,input,savezs
	Set $ETRAP="Goto ERROR"
	Set revfile=file_".rev"
	Open file:read
	Use file
	For index=1:1 Quit:$zeof  Read input(index)
	Close file
	Open revfile:(noread:newv)
	Use revfile
	For revindex=index-2:-1:1 Write input(revindex),!
	Close revfile
	Quit
	;
ERROR
	Set $ECODE=""
	Set savezs=$ZSTATUS
	Close $IO
	Use $P
	Write !,savezs,!
	Quit
