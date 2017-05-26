; badhandler
; This routine will trap to cont1 because the "open" exception handler is bad
BADLABEL
	zshow "d"
	set p="test"
	set $ztrap="goto cont0"
	; bad label
	open p:(shell="jjj":comm="cat":exception="g ADOPEN")::"pipe"
	use p:exception="G EOF" 
  	write "huh"
	quit

BADCOMMAND
	zshow "d"
	set p="test"
	set $ztrap="goto cont0"
	; bad command
	open p:(shell="jjj":comm="cat":exception="ga BADOPEN")::"pipe"
	use p:exception="G EOF" 
  	write "huh"
	quit

JUSTBADLABEL
	zshow "d"
	set p="test"
	set $ztrap="cont0"
	; bad command
	open p:(shell="jjj":comm="cat":exception="ADOPEN")::"pipe"
	use p:exception="G EOF" 
  	write "huh"
	quit

JUSTGOODLABEL
	zshow "d"
	set p="test"
	set $ztrap="cont1"
	; bad command
	open p:(shell="jjj":comm="cat":exception="BADOPEN")::"pipe"
	use p:exception="G EOF" 
  	write "huh"
	quit

cont0	u $p write $zstatus,!
cont1	u $p
	write "in cont1",!
	zshow "d"
	quit
EOF	u $p
  	write !,"here"
	quit 
BADOPEN	u $p
	write !,"badopen error",!
	write $zstatus,!
	zshow "d"
	quit 
