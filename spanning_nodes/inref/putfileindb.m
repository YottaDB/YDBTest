; Puts values with the corresponding keys to database.
; The keys are read from filename ^keyfile and the values come from file ^valuefile.
; Called from basic.csh.
putfileindb
	open ^keyfile:readonly
	open ^valuefile:readonly
	for  use ^keyfile read key quit:$zeof=1  do
	.    use ^valuefile
	.    read val
	.    set ^tmpgbl(key)=val
	close ^keyfile
	close ^valuefile
	quit
