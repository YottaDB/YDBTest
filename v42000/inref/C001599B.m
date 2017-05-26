C001599B	;
	Set $ZT="ZGoto "_$ZLEVEL_":nullsub^C001599B"
	View "NOLVNULLSUBS"

	For i=1:1:10 S a(i)=i

	Set a(1,"")="aa"

	Write "ERROR: Allowed to set null subscript",!
	Q

nullsub	;
	Set $ZT="B"
	;
	; Now that we've seen an error, try to collate through the local variable array "a"
	;
	Set x="a"
	For  Set x=$Query(@x) Quit:x=""  Write !,x,"=",@x
	Q
