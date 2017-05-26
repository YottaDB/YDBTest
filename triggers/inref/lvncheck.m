lvncheck(top)
	; this M routine validates that all subscript LVNs are avaiable
	; in trigger code
	if $data(lvn) write "FAIL: local varible 'lvn' exists in trigger context",!
	if $data(i) write "FAIL: local varible 'i' exists in trigger context",!
	if $data(l) write "FAIL: local varible 'l' exists in trigger context",!
	set lvn="lvn",valid=0
	for i=1:1:31 do
	.	set l=lvn_i
	.	if $data(@l) set $piece(lvns,$char(9),$increment(valid))=@l
	if valid'=top write "MISMATCH:",$reference,! zwrite valid,top
	else  write "PASS:",$reference,!,?8,lvns,!
	quit
