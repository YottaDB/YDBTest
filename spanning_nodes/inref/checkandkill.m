; Goes through two files. The first one contains keys, the second contains values in each line. A query with key from line x in the
; first file must return the value from the second file. Successful matches are deleted from database.
; This is called from basic.csh.
checkandkill
	open ^keyfile:readonly
	open ^valuefile:readonly	
	for i=1:1:^numpair do
	.   use ^keyfile
	.   read key
	.   use ^valuefile
	.   read val
	.   if ^tmpgbl(key)=val kill ^tmpgbl(key)
	.   else  write "Error! Value does not match what we have in file! Compare tmpgbl("_key_")",!
	close ^keyfile
	close ^valuefile
	if $data(^tmpgbl)'=0 write "^tmpgbl is not cleaned!",!
	quit
