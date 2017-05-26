	; Replace one or more consecutive occurrences of input parameter
	; 'delim' with one 'newdelim' in parameter 'text' so that you can
	; use $piece on the result.
	; This lets us use $piece like AWK does
v53003flexpiece(text,delim,newdelim)
	new output,i,j
	if '$data(newdelim) set newdelim=$char(0)
	if '$data(delim) set delim=$char(32,32)
	set zdelim=$extract(delim,1,1)
	for i=1:1:$length(text,delim)  if $p(text,delim,i)'="" do
	.       set pi=$p(text,delim,i)
	.       set:$extract(pi,1,1)=zdelim $extract(pi,1,1)=""
	.       set $piece(output,newdelim,$i(j))=pi
	quit output
